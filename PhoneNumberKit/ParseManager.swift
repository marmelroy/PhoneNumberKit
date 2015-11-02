//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class ParseManager {
    
    static let sharedInstance = ParseManager()
    
    let regex = RegularExpressions.sharedInstance
    
    let metadata = Metadata.sharedInstance
    
    let parser = PhoneNumberParser()
    
    var startTime =  NSDate()
    
    private var multiParseArray = SynchronizedArray<PhoneNumber>()
    
    class InternalPhoneNumber {
        var countryCode: UInt64?
        var nationalNumber: UInt64?
        var rawNumber: String?
        var leadingZero: Bool = false
        var numberExtension: String?
        private var parsingNationalNumber: String?
        private var parsingRegion: String?

    }
    
    func parsePhoneNumber(rawNumber: String, region: String) throws -> InternalPhoneNumber {
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
        var countryCode : UInt64 = 0
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
                let countryMetadata = self.metadata.metadataPerCode[cCode]
                if  (countryMetadata == nil) {
                    throw PNParsingError.InvalidCountryCode
                }
                regionMetaData = countryMetadata
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
    
    func multiParse(rawNumbers: [String], region : String) -> [PhoneNumber] {
        let queue = NSOperationQueue()
        var operationArray : [ParseOperation<InternalPhoneNumber>] = []
        ParseManager.sharedInstance.startTime =  NSDate()
        for rawNumber in rawNumbers {
            let parseTask = SingleParseTask(rawNumber, region:region)
            parseTask.whenFinished { operation in
                print("output")
                if let internalPhoneNumber = operation.output.value {
                    let phoneNumber = PhoneNumber(rawNumber: rawNumber, countryCode: internalPhoneNumber.countryCode, nationalNumber: internalPhoneNumber.nationalNumber, leadingZero: internalPhoneNumber.leadingZero, numberExtension: internalPhoneNumber.numberExtension)
                    self.multiParseArray.append(phoneNumber)
                    let endTime = NSDate()
                    let timeInterval = endTime.timeIntervalSinceDate(ParseManager.sharedInstance.startTime)
                    print("count \(self.multiParseArray.array.count), date \(timeInterval)")

                }
            }
            operationArray.append(parseTask)
        }
        queue.addOperations(operationArray, waitUntilFinished: false)
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


