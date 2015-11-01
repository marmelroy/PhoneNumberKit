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

    var queue = NSOperationQueue()
    
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
        phoneNumber.parsingRegion = region

        let extractNumber = ParseExtractNumber(phoneNumber)
        
        queue.addOperations([extractNumber], waitUntilFinished: false)
        
        //
        //        // Validate format (6)
        //        try checkValidPattern(nationalNumber, metadata: regionMetaData)
        //
        //        // Leading Zero (7)
        //        phoneNumber.leadingZero = nationalNumber.hasPrefix("0")
        return phoneNumber
    }
    
    // Extract number (1)
    func ParseExtractNumber(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            do  {
                var nationalNumber = phoneNumber.rawNumber
                let matches = try self.regex.phoneDataDetectorMatches(nationalNumber!)
                if let phoneNumber = matches.first?.phoneNumber {
                    nationalNumber = phoneNumber
                }
                phoneNumber.parsingNationalNumber = nationalNumber
                asyncOp.finish(with: phoneNumber)
            }
            catch {
                throw PNParsingError.NotANumber
            }
        }
        
        operation.whenFinished { operation in
            print("OUTPOT EXTRACT NUMBER")
            print(operation.output)
            if let phoneNumber = operation.output.value {
                let extractExtensions = self.ParseExtractExtensions(phoneNumber)
                self.queue.addOperation(extractExtensions)
            }
        }
        return operation
        
    }
    
    // Extension parsing (2)
    func ParseExtractExtensions(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            var tempNumber = phoneNumber.parsingNationalNumber
            let extn = self.parser.stripExtension(&tempNumber!)
            if let numberExtension = extn {
                phoneNumber.numberExtension = numberExtension
            }
            asyncOp.finish(with: phoneNumber)
        }
        
        operation.whenFinished { operation in
            print("OUTPOT EXTRACT EXTENSIONS")
            print(operation.output)
            if let phoneNumber = operation.output.value {
                let countryCodeParse = self.ParseCountryCode(phoneNumber)
                self.queue.addOperation(countryCodeParse)
            }

        }
        return operation
    }

    // Country code parsing (3)
    func ParseCountryCode(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            let regionMetaData =  self.metadata.metadataPerCountry[phoneNumber.parsingRegion!]
            var nationalNumber = phoneNumber.parsingNationalNumber!
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
            var tempNumber = phoneNumber.parsingNationalNumber
            let extn = self.parser.stripExtension(&tempNumber!)
            if let numberExtension = extn {
                phoneNumber.numberExtension = numberExtension
            }
            phoneNumber.parsingNationalNumber = nationalNumber
            asyncOp.finish(with: phoneNumber)
        }
        
        operation.whenFinished { operation in
            print("OUTPOT COUNTRY PARSE")
            if let output = operation.output.value {
                let normalize = self.ParseNormalize(phoneNumber)
                self.queue.addOperation(normalize)
                print("country code")
                print(output.countryCode)
                print("national number")
                print(output.parsingNationalNumber)
            }
        }
        return operation
    }
    
    // Normalize (4)
    func ParseNormalize(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            let tempNumber = phoneNumber.parsingNationalNumber
            phoneNumber.parsingNationalNumber = self.parser.normalizePhoneNumber(tempNumber!)
            asyncOp.finish(with: phoneNumber)
        }
        
        operation.whenFinished { operation in
            print("OUTPOT NORMALIZE")
            let output = operation.output.value
            print("national number")
            print(output!.parsingNationalNumber)
        }
        return operation
    }
    
    // National Prefix Strip (5)
    func ParseNationalPrefixStrip(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            let regionMetaData =  self.metadata.metadataPerCode[phoneNumber.countryCode!]!
            var nationalNumber = phoneNumber.parsingNationalNumber!
            self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData)
            phoneNumber.parsingNationalNumber = nationalNumber
            phoneNumber.nationalNumber = UInt64(nationalNumber)!
            asyncOp.finish(with: phoneNumber)
        }
        
        operation.whenFinished { operation in
            print("OUTPOT STRIP NATIONAL PREFIX")
            let output = operation.output.value
            print("national number")
            print(output!.parsingNationalNumber)
        }
        return operation
    }


    
}

