//
//  PhoneNumberParseOperation.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 31/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Custom NSOperation for phone number parsing that supports throwing closures.
*/
class ParseOperation<OutputType>: Operation {
    typealias OperationClosure = (_ parseOp: ParseOperation<OutputType>) -> Void
    typealias OperationThrowingClosure = (_ parseOp: ParseOperation<OutputType>) throws -> Void
    override final var isExecuting: Bool { return state == .executing }
    override final var isFinished: Bool { return state == .finished }
    fileprivate var completionHandler: OperationClosure?
    fileprivate var implementationHandler: OperationThrowingClosure?
    fileprivate(set) var output: ParseOperationValue<OutputType> = .none(PhoneNumberError.generalError)
    fileprivate var state = ParseOperationState.initial {
        willSet {
            if newValue != state {
                willChangeValueForState(newValue)
                willChangeValueForState(state)
            }
        }
        didSet {
            if oldValue != state {
                didChangeValueForState(oldValue)
                didChangeValueForState(state)
            }
        }
    }
    
    // MARK: Lifecycle
    
    /**
    Start operation, perform implementation or finish with errors.
    */
    override func start() {
        if !isCancelled {
            main()
        }
        else {
            finish(with: .none(.generalError))
        }
    }
    
    /**
    Main operation, tries to perform the implementation handler.
    */
    override func main() {
        func main_performImplementation() {
            if let implementationHandler = self.implementationHandler {
                self.implementationHandler = nil
                do {
                    try implementationHandler(self)
                }
                catch {
                    finish(with: .generalError)
                }
            }
            else {
                finish(with: .generalError)
            }
        }
        autoreleasepool {
            main_performImplementation() // happy path
        }
    }
}

extension ParseOperation {
    /**
    Provide implementation handler for operation
    - Parameter implementationHandler: Potentially throwing implementation closure.
    */
    func onStart(_ implementationHandler: @escaping OperationThrowingClosure) {
        self.implementationHandler = implementationHandler
    }
    
    /**
    Provide completion handler for operation
    - Parameter completionHandler: Completion closure.
    */
    func whenFinished(whenFinishedQueue completionHandlerQueue: OperationQueue = OperationQueue.main, completionHandler: @escaping OperationClosure) {
        guard self.completionHandler == nil else { return }
        self.completionHandler = completionHandler
    }
    
    /**
    Send a did change value for key notification
    - Parameter state: ParseOperationState.
    */
    func didChangeValueForState(_ state: ParseOperationState) {
        guard let key = state.key else { return }
        didChangeValue(forKey: key)
    }
    
    /**
    Send a will change value for key notification
    - Parameter state: ParseOperationState.
    */
    func willChangeValueForState(_ state: ParseOperationState) {
        guard let key = state.key else { return }
        willChangeValue(forKey: key)
    }
    
    /**
    Finish with an output value
    - Parameter value: Output of valid type.
    */
    final func finish(with value: OutputType) {
        finish(with: .some(value))
    }
    
    /**
    Finish with a parsing error
    - Parameter parseOperationValueError: Parsing error.
    */
    final func finish(with parseOperationValueError: PhoneNumberError) {
        finish(with: .none(parseOperationValueError))
    }
    
    /**
    Process operation finish
    - Parameter parseOperationValue: Output type or error.
    */
    func finish(with parseOperationValue: ParseOperationValue<OutputType>) {
		guard self.state != .finished else { return }
		
		self.output = parseOperationValue
		guard let completionHandler = self.completionHandler else { return }
		self.completionHandler = nil
		self.implementationHandler = nil
		completionHandler(self)
		self.state = .finished
    }
}


/**
ParseOperationValue enumeration, can contain a valuetype or an error.
- None: Value representing a parsing error.
- Some: Any operationvalue.
- ProvidedInputValueType: Alias for any operationvalue.
*/
enum ParseOperationValue<ValueType>: ParseOperationValueProvider {
    case none(PhoneNumberError)
    case some(ValueType)
    typealias ProvidedInputValueType = ValueType
}

extension ParseOperationValue {
    /**
    Get value, can return a value type or throw an error.
    */
    func getValue() throws -> ValueType {
        switch self {
        case .none:
            throw PhoneNumberError.generalError
        case .some(let value):
            return value
        }
    }
    
    /**
    Access value, can return a value type or nil (can't throw).
    */
    var value: ValueType? {
        switch self {
        case .none:
            return nil
        case .some(let value):
            return value
        }
    }
    
    /**
    Access error, can return an error or nil (can't throw).
    */
    var noneError: PhoneNumberError? {
        switch self {
        case .none(let error):
            return error
        case .some:
            return nil
        }
    }
}

/**
Value provider protocol.
*/
public protocol ParseOperationValueProvider {
    associatedtype ProvidedInputValueType
}

/**
Operation state enum.
*/
enum ParseOperationState {
    case initial
    case executing
    case finished
    var key: String? {
        switch self {
        case .executing:
            return "isExecuting"
        case .finished:
            return "isFinished"
        case .initial:
            return nil
        }
    }
}
