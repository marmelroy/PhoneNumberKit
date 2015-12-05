//
//  PartialFormatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class PartialFormatter {
    
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance

    /**
     Partial number formatter
     - Parameter rawNumber: Phone number object.
     - Parameter region: Default region code.
     - Returns: Modified national number ready for display.
     */
    func formatPartial(rawNumber: String, region: String) throws -> String {
        if rawNumber.characters.count <= 3 {
            return rawNumber
        }
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercaseString
        // Extract number (2)
        var nationalNumber = rawNumber
        var finalString = ""
        // Country code parse (3)
        if (self.metadata.metadataPerCountry[region] == nil) {
            throw PNParsingError.InvalidCountryCode
        }
        var regionMetaData =  self.metadata.metadataPerCountry[region]!
        var countryCode: UInt64 = 0
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData)
        }
        catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetaData)
            }
            catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        var format = PNNumberFormat.National
        if (countryCode == 0) {
            countryCode = regionMetaData.countryCode
        }
        else {
            finalString = "+\(countryCode)"
            format = PNNumberFormat.International
        }
        // Nomralized number (5)
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetaData.countryCode {
            regionMetaData = self.metadata.metadataPerCode[countryCode]!
        }
        
        // National Prefix Strip (7)
        if (nationalNumber.characters.count > 0) {
            nationalNumber = self.normalizePhoneNumber(nationalNumber)
            self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData)
            
            let array = try regex.matchedStringByRegex((regionMetaData.generalDesc?.nationalNumberPattern)!, string: PNLongPhoneNumber)
            let formatter = Formatter()
            let formattedNationalNumber = formatter.formatNationalNumber(array.first!, regionMetadata: regionMetaData, formatType: format)
            
            var rebuiltString = String()
            var rebuiltIndex = 0
            for character in formattedNationalNumber.characters {
                if character == "9" {
                    if rebuiltIndex < nationalNumber.characters.count {
                        let nationalCharacterIndex = nationalNumber.startIndex.advancedBy(rebuiltIndex)
                        rebuiltString.append(nationalNumber[nationalCharacterIndex])
                        rebuiltIndex++
                    }
                }
                else {
                    rebuiltString.append(character)
                }
            }
            if rebuiltIndex < nationalNumber.characters.count {
                let nationalCharacterIndex = nationalNumber.startIndex.advancedBy(rebuiltIndex)
                let remainingNationalNumber: String = nationalNumber.substringFromIndex(nationalCharacterIndex)
                rebuiltString.appendContentsOf(remainingNationalNumber)
            }
            rebuiltString = rebuiltString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            if finalString.characters.count > 0 {
                finalString = finalString + " " + rebuiltString
                return finalString
            }
            return rebuiltString
        }
        else {
            return self.normalizePhoneNumber(rawNumber)
        }
    }
    
    
    func normalizePhoneNumber(number: String) -> String {
        return regex.stringByReplacingOccurrences(number, map: PNPartialFormatterNormalizationMappings, removeNonMatches: true)!
    }

}
