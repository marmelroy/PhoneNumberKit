//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class ParseManager {
    
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance
    
    private var multiParseArray = SynchronizedArray<PhoneNumber>()
    
    func parsePhoneNumber(rawNumber: String, region: String) throws -> PhoneNumber {
        let region = region.uppercaseString
        
        // Extract number
        var nationalNumber = rawNumber
        let matches = try self.regex.phoneDataDetectorMatches(rawNumber)
        if let phoneNumber = matches.first?.phoneNumber {
            nationalNumber = phoneNumber
        }
        
        // Extension parsing
        let extn = self.parser.stripExtension(&nationalNumber)
        
        // Country code parsing
        
        var regionMetaData =  self.metadata.metadataPerCountry[region]
        var countryCode: UInt64 = 0
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
        } catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
            } catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if (countryCode == 0) {
            countryCode = regionMetaData!.countryCode
        }
        
        // Nomralize
        nationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        
        
        // If country code is not default, grab countrycode metadata
        if countryCode != regionMetaData!.countryCode {
            regionMetaData = self.metadata.metadataPerCode[countryCode]
        }
        
        // National Prefix Strip
        self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData!)
        
        let generalNumberDesc = regionMetaData!.generalDesc
        if (self.regex.hasValue(generalNumberDesc!.nationalNumberPattern) == false || self.parser.isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc!) == false) {
            throw PNParsingError.NotANumber
        }
        let leadingZero = nationalNumber.hasPrefix("0")
        let finalNationalNumber = UInt64(nationalNumber)!
        let phoneNumber = PhoneNumber(countryCode: countryCode, leadingZero: leadingZero, nationalNumber: finalNationalNumber, numberExtension: extn, rawNumber: rawNumber)
        return phoneNumber
    }
    
    // Parse task
    func SingleParseTask(rawNumber: String, region: String) -> ParseOperation<PhoneNumber> {
        let operation = ParseOperation<PhoneNumber>()
        operation.onStart { asyncOp in
            let phoneNumber = try self.parsePhoneNumber(rawNumber, region: region)
            asyncOp.finish(with: phoneNumber)
        }
        return operation
    }
    
    func multiParse(rawNumbers: [String], region: String) -> [PhoneNumber] {
        self.multiParseArray = SynchronizedArray<PhoneNumber>()
        let queue = NSOperationQueue()
        var operationArray: [ParseOperation<PhoneNumber>] = []
        let completionOperation = ParseOperation<Bool>()
        completionOperation.onStart { asyncOp in
            asyncOp.finish(with: true)
        }
        completionOperation.whenFinished { asyncOp in
        }
        for rawNumber in rawNumbers {
            let parseTask = self.SingleParseTask(rawNumber, region:region)
            parseTask.whenFinished { operation in
                if let phoneNumber = operation.output.value {
                    self.multiParseArray.append(phoneNumber)
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
