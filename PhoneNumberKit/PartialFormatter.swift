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

    func getAvailableFormats(regionMetadata: MetadataTerritory) -> [MetadataPhoneNumberFormat] {
        var possibleFormats = [MetadataPhoneNumberFormat]()
        let formatList = regionMetadata.numberFormats
        for format in formatList {
            if isFormatEligible(format) {
                possibleFormats.append(format)
            }
        }
        return possibleFormats
    }
    
    func isFormatEligible(format: MetadataPhoneNumberFormat) -> Bool {
        guard let pattern = format.pattern else {
            return false
        }
        do {
            let fallBackMatches = try regex.regexMatches(PNEligibleAsYouTypePattern, string: pattern)
            return (fallBackMatches.count == 0)
        }
        catch {
            return false
        }
    }
    
    struct NationalNumberPrefixExtract {
        let prefix: String
        let nationalNumer: String
    }
    
    func extractNationalNumberPrefix(rawNumber: String, regionMetadata: MetadataTerritory, countryCodeSource: PNCountryCodeSource) -> NationalNumberPrefixExtract {
        do {
            let matches = try regex.regexMatches(String(regionMetadata.countryCode), string: rawNumber)
            guard let firstMatch = matches.first else {
                return NationalNumberPrefixExtract(prefix: String(), nationalNumer: rawNumber)
            }
            let range = firstMatch.range
            let adjustedRange = NSMakeRange(0, range.location + range.length)
            let nationalNumberPrefix: String = rawNumber.substringWithNSRange(adjustedRange)
            let nationalNumber = rawNumber.substringWithNSRange(NSMakeRange(adjustedRange.length, rawNumber.characters.count - adjustedRange.length))
            if let iddPattern = regionMetadata.internationalPrefix where countryCodeSource == PNCountryCodeSource.NumberWithIDD {
                let matched = try regex.regexMatches(iddPattern as String, string: rawNumber as String).first
                if let matchedRange = matched?.range {
                    let character = " " as Character
                    var numberPrefix = nationalNumberPrefix
                    let index = nationalNumberPrefix.startIndex.advancedBy(matchedRange.location).advancedBy(matchedRange.length)
                    numberPrefix.insert(character, atIndex: index)
                    return NationalNumberPrefixExtract(prefix: numberPrefix, nationalNumer: nationalNumber)

                }
            }
            return NationalNumberPrefixExtract(prefix: nationalNumberPrefix, nationalNumer: nationalNumber)
        }
        catch {
            return NationalNumberPrefixExtract(prefix: String(), nationalNumer: rawNumber)
        }

    }
    
    
    /**
     Partial number formatter
     - Parameter rawNumber: Phone number object.
     - Parameter region: Default region code.
     - Returns: Modified national number ready for display.
     */
    func formatPartial(rawNumber: String, region: String) throws -> String {
        let startsWithPlus = regex.matchesAtStart(PNLeadingPlusCharsPattern, string: rawNumber)
        let preNormalized = self.normalizePhoneNumber(rawNumber)
        if preNormalized.characters.count <= 3 || (rawNumber.characters.first != "0" && startsWithPlus == false) {
            return preNormalized
        }
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercaseString
        // Extract number (2)
        var nationalNumber = rawNumber
        var nationalNumberPrefix = String()
        // Country code parse (3)
        if (self.metadata.metadataPerCountry[region] == nil) {
            throw PNParsingError.InvalidCountryCode
        }
        var regionMetaData =  self.metadata.metadataPerCountry[region]!
        var extractedCountryCode: ExtractedCountryCode
        do {
            extractedCountryCode = try self.parser.extractCountryCode(nationalNumber, metadata: regionMetaData)
        }
        catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                extractedCountryCode = try self.parser.extractCountryCode(plusRemovedNumberString, metadata: regionMetaData)
            }
            catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        
        // Apply extracted country code, prepare prefix and select format (5)
        nationalNumber = extractedCountryCode.nationalNumber
        var countryCode = extractedCountryCode.countryCode
        var format = PNNumberFormat.National
        if (countryCode == 0) {
            if extractedCountryCode.countryCodeSource == .DefaultCountry {
            countryCode = regionMetaData.countryCode
            }
            else {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if extractedCountryCode.countryCodeSource != .DefaultCountry {
            format = PNNumberFormat.International
        }

        // Account for a potential IDD prefix (4)
        
        
        // Nomralized number (5)
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetaData.countryCode {
            regionMetaData = self.metadata.metadataPerCode[countryCode]!
        }
        
        let extractedPrefix = extractNationalNumberPrefix(preNormalized, regionMetadata: regionMetaData, countryCodeSource: extractedCountryCode.countryCodeSource)
        
        nationalNumberPrefix = extractedPrefix.prefix
        nationalNumber = extractedPrefix.nationalNumer
        
        // National Prefix Strip (7)
        if (nationalNumber.characters.count > 0) {
            nationalNumber = self.normalizePhoneNumber(nationalNumber)
            self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData)
            guard let firstFormat = self.getAvailableFormats(regionMetaData).first, let pattern = firstFormat.pattern else {
                throw PNParsingError.InvalidCountryCode
            }
            let array = try regex.matchedStringByRegex(pattern, string: PNLongPhoneNumber)
            guard let chosenFormat = array.first else {
                throw PNParsingError.InvalidCountryCode
            }
            let formatter = Formatter()
            let formattedNationalNumber = formatter.formatNationalNumber(chosenFormat, regionMetadata: regionMetaData, formatType: format)
            if formattedNationalNumber == "NA" {
                throw PNParsingError.NotANumber
            }
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
            rebuiltString = rebuiltString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
            if nationalNumberPrefix.characters.count > 0 {
                return "\(nationalNumberPrefix) \(rebuiltString)"
            }
            return rebuiltString
        }
        else {
            return self.normalizePhoneNumber(rawNumber)
        }
    }
    
    
    func normalizePhoneNumber(number: String) -> String {
        if let result = regex.stringByReplacingOccurrences(number, map: PNPartialFormatterNormalizationMappings, removeNonMatches: true) {
            return result
        }
        return number
    }

}
