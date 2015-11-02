//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class ParseManager {
        
    let regex = RegularExpressions.sharedInstance
    
    let metadata = Metadata.sharedInstance
    
    let parser = PhoneNumberParser()
    
    private var multiParseArray = SynchronizedArray<PhoneNumber>()
    
    class InternalPhoneNumber {
        var countryCode: UInt64?
        var nationalNumber: UInt64?
        var rawNumber: String?
        var leadingZero: Bool = false
        var numberExtension: String?
    }
    
    func parsePhoneNumber(rawNumber: String, region: String) throws -> InternalPhoneNumber {
        let region = region.uppercaseString
        let phoneNumber = InternalPhoneNumber()
        phoneNumber.rawNumber = rawNumber
        
        // Extract number
        var nationalNumber = rawNumber
        let matches = try self.regex.phoneDataDetectorMatches(rawNumber)
        if let phoneNumber = matches.first?.phoneNumber {
            nationalNumber = phoneNumber
        }
        
        // Extension parsing
        let extn = self.parser.stripExtension(&nationalNumber)
        if let numberExtension = extn {
            phoneNumber.numberExtension = numberExtension
        }
        
        // Country code parsing
        
        var regionMetaData =  self.metadata.metadataPerCountry[region]
        var countryCode: UInt64 = 0
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
            phoneNumber.countryCode = countryCode
        } catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
                phoneNumber.countryCode = countryCode
            } catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if (countryCode == 0) {
            phoneNumber.countryCode = regionMetaData!.countryCode
        }
        
        // Nomralize
        nationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        
        
        // If country code is not default, grab countrycode metadata
        if let cCode = phoneNumber.countryCode {
            if cCode != regionMetaData!.countryCode {
                regionMetaData = self.metadata.metadataPerCode[cCode]
            }
        }
        
        // National Prefix Strip
        self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData!)
        
        let generalNumberDesc = regionMetaData!.generalDesc
        if (self.regex.hasValue(generalNumberDesc!.nationalNumberPattern) == false || self.parser.isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc!) == false) {
            throw PNParsingError.NotANumber
        }
        
        phoneNumber.leadingZero = nationalNumber.hasPrefix("0")
        phoneNumber.nationalNumber = UInt64(nationalNumber)!

        return phoneNumber
    }
    
    func multiParse(rawNumbers: [String], region: String) -> [PhoneNumber] {
        self.multiParseArray = SynchronizedArray<PhoneNumber>()
        let queue = NSOperationQueue()
        var operationArray: [ParseOperation<InternalPhoneNumber>] = []
        let completionOperation = ParseOperation<Bool>()
        completionOperation.onStart { asyncOp in
            asyncOp.finish(with: true)
        }
        
        completionOperation.whenFinished { asyncOp in
        }
        for rawNumber in rawNumbers {
            let parseTask = SingleParseTask(rawNumber, region:region)
            parseTask.whenFinished { operation in
                if let internalPhoneNumber = operation.output.value {
//                    let phoneNumber = PhoneNumber(rawNumber: rawNumber, countryCode: internalPhoneNumber.countryCode, nationalNumber: internalPhoneNumber.nationalNumber, leadingZero: internalPhoneNumber.leadingZero, numberExtension: internalPhoneNumber.numberExtension)
//                    self.multiParseArray.append(phoneNumber)
                }
            }
            operationArray.append(parseTask)
            completionOperation.addDependency(parseTask)
        }
        queue.addOperations(operationArray, waitUntilFinished: false)
        queue.addOperations([completionOperation], waitUntilFinished: true)
        let localMultiParseArray = self.multiParseArray
        return localMultiParseArray.array
    }
    
    // Parse task
    func SingleParseTask(rawNumber: String, region: String) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        operation.onStart { asyncOp in
            let phoneNumber = try self.parsePhoneNumber(rawNumber, region: region)
            asyncOp.finish(with: phoneNumber)
        }
        return operation
    }

}


public class SynchronizedArray<T> {
    public var array: [T] = []
    private let accessQueue = dispatch_queue_create("SynchronizedArrayAccess", DISPATCH_QUEUE_SERIAL)
    
    public func append(newElement: T) {
        dispatch_async(self.accessQueue) {
            self.array.append(newElement)
        }
    }
    
    public subscript(index: Int) -> T {
        set {
            dispatch_async(self.accessQueue) {
                self.array[index] = newValue
            }
        }
        get {
            var element: T!
            
            dispatch_sync(self.accessQueue) {
                element = self.array[index]
            }
            
            return element
        }
    }
}
