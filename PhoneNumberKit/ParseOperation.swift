//
//  PhoneNumberParseOperation.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 31/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

//enum PhoneNumberParseOperationType {
//    case InitialValidate
//    case PossibleExtract
//    case Viable
//    case CheckRegion
//    case StripExtension
//    case CountryCodeParse
//    case LengthValidations
//    case RefreshMetadata
//    case StripPrefix
//    case ExtractNumberType
//    case LeadingZero
//    case NationalNumber
//}

//class operationInitialValidate : ParseOperation {
//    
////    private var completion: ((valid : Bool, error: PNParsingError?) -> Void)?
////    private var rawNumber : String
////
////    init(rawNumber: String, completion: ((valid : Bool, error: PNParsingError?) -> Void)?) {
////        self.rawNumber = rawNumber
////        self.completion = completion
////        super.init()
////    }
////    
////    override func start() {
////
////        if cancelled {
////            finish(.Failure)
////            return
////        }
////        
////        var error : PNParsingError?
////
////        if (rawNumber.isEmpty) {
////            error = PNParsingError.NotANumber
////        } else if (rawNumber.characters.count > PNMaxInputStringLength) {
////            error = PNParsingError.TooLong
////        }
////        
////        if let errorExists = error {
////            self.completion?(valid: false, error: errorExists)
////            self.finish(.Failure)
////        }
////        else {
////            self.completion?(valid: true, error: nil)
////            self.finish(.Success)
////        }
////
////    }
//}

class ParseOperation<InputType, OutputType> : NSOperation {
    
    typealias OpClosure = (parseOp: ParseOperation<InputType, OutputType>) -> Void
    typealias OpThrowingClosure = (parseOp: ParseOperation<InputType, OutputType>) throws -> Void
    
    private var implementationHandler: OpThrowingClosure?
    private var completionHandler: OpClosure?
    private var cancellationHandler: OpClosure?

    private var whenFinishedOnceToken: dispatch_once_t = 0
    private var completionHandlerQueue: NSOperationQueue?
    private var finishOnceToken: dispatch_once_t = 0
    private var cancelOnceToken: dispatch_once_t = 0

    var input: AsyncOpValue<InputType> = .None(PNParsingError.TechnicalError)
    
    private(set) var output: AsyncOpValue<OutputType> = .None(PNParsingError.TechnicalError)

    required override init() {
        super.init()
    }
    
    override  func start() {
        if !cancelled {
            main()
        } else {
            finish(with: .None(.TechnicalError))
        }
    }
    
    override func main() {
        func main_performImplementation() {
            if let implementationHandler = self.implementationHandler {
                self.implementationHandler = nil
                do {
                    try implementationHandler(parseOp: self)
                } catch {
                    finish(with: error)
                }
            } else {
                finish(with: PNParsingError.TechnicalError)
            }
        }
        
        autoreleasepool {
            main_performImplementation() // happy path
        }
    }

    
    override func cancel() {
        dispatch_once(&cancelOnceToken) {
            super.cancel()
            self.cancellationHandler?(parseOp: self)
            self.cancellationHandler = nil
        }
    }
    
}

public protocol AsyncOpInputProvider {
    typealias ProvidedInputValueType
    func provideAsyncOpInput() -> AsyncOpValue<ProvidedInputValueType>
}

public enum AsyncOpValue<ValueType>: AsyncOpInputProvider {
    case None(PNParsingError)
    case Some(ValueType)
    
    public typealias ProvidedInputValueType = ValueType
    public func provideAsyncOpInput() -> AsyncOpValue<ProvidedInputValueType> {
        return self
    }
}

extension ParseOperation {
    
    func onStart(implementationHandler: OpThrowingClosure) {
        self.implementationHandler = implementationHandler
    }
    
    func whenFinished(whenFinishedQueue completionHandlerQueue: NSOperationQueue = NSOperationQueue.mainQueue(), completionHandler: OpClosure) {
        dispatch_once(&whenFinishedOnceToken) {
            guard self.completionHandler == nil else { return }
            if self.finished {
                completionHandlerQueue.addOperationWithBlock {
                    completionHandler(parseOp: self)
                }
            } else {
                self.completionHandlerQueue = completionHandlerQueue
                self.completionHandler = completionHandler
            }
        }
    }
    
    func onCancel(cancellationHandler: OpClosure) {
        self.cancellationHandler = cancellationHandler
    }
   
    final func finish(with value: OutputType) {
        finish(with: .Some(value))
    }
    
    final func finish(with asyncOpValueError: PNParsingError) {
        finish(with: .None(asyncOpValueError))
    }
    
    final func finish(with failureError: ErrorType) {
        finish(with: .None(PNParsingError.TechnicalError))
    }
    
    func finish(with asyncOpValue: AsyncOpValue<OutputType>) {
        guard executing else { return }
        dispatch_once(&finishOnceToken) {
            self.output = asyncOpValue
            guard let completionHandler = self.completionHandler else { return }
            self.completionHandler = nil
            self.implementationHandler = nil
            self.cancellationHandler = nil
            guard let completionHandlerQueue = self.completionHandlerQueue else { return }
            self.completionHandlerQueue = nil
            completionHandlerQueue.addOperationWithBlock {
                completionHandler(parseOp: self)
            }
        }
    }
    
}

extension AsyncOpValue {
    
    public func getValue() throws -> ValueType {
        switch self {
        case .None:
            throw PNParsingError.TechnicalError
        case .Some(let value):
            return value
        }
    }
    
    public var value: ValueType? {
        switch self {
        case .None:
            return nil
        case .Some(let value):
            return value
        }
    }
    
    public var noneError: PNParsingError? {
        switch self {
        case .None(let error):
            return error
        case .Some:
            return nil
        }
    }
    
}

public enum ParseOperationResultStatus {
    case Pending
    case Succeeded
    case Cancelled
    case Failed
}