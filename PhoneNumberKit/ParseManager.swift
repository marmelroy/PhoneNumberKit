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
        
        
        //
        //
        //

        queue.addOperations([extractNumber], waitUntilFinished: true)
        
        //
        //        // Nomralize (4)
        //        nationalNumber = normalizePhoneNumber(nationalNumber)
        //
        //        // If country code is not default, grab countrycode metadata (5)
        //        if let cCode = phoneNumber.countryCode {
        //            if cCode != regionMetaData!.countryCode {
        //                let countryMetadata = metadata.metadataPerCode[cCode]
        //                if  (countryMetadata == nil) {
        //                    throw PNParsingError.InvalidCountryCode
        //                }
        //                regionMetaData = countryMetadata
        //            }
        //        }
        //
        //        // National Prefix Strip (6)
        //        stripNationalPrefix(&nationalNumber, metadata: regionMetaData!)
        //
        //        // Validate format (7)
        //        try checkValidPattern(nationalNumber, metadata: regionMetaData)
        //
        //        // Leading Zero (8)
        //        phoneNumber.leadingZero = nationalNumber.hasPrefix("0")
        //        // UInt casting (8)
        //        phoneNumber.nationalNumber = UInt64(nationalNumber)!
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
        }
        return operation
    }

    // Country code parsing (3)
    func ParseCountryCode(phoneNumber : InternalPhoneNumber) -> ParseOperation<InternalPhoneNumber> {
        let operation = ParseOperation<InternalPhoneNumber>()
        
        operation.onStart { asyncOp in
            var regionMetaData =  self.metadata.metadataPerCountry[phoneNumber.parsingRegion!]
            var countryCode : UInt64 = 0
            do {
                countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
                phoneNumber.countryCode = countryCode
            } catch {
                do {
                    let plusRemovedNumberString = regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                    countryCode = try extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
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
            asyncOp.finish(with: phoneNumber)
        }
        
        operation.whenFinished { operation in
            print(operation.output)
        }
        return operation
    }
    
}

