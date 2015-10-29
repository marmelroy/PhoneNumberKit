//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public class PhoneNumberParser: NSObject {
    
    // MARK: Normalizations

    // Normalize phone number
    func normalizePhoneNumber(number: String) -> String {
        return stringByReplacingOccurrences(number, map: PNAllNormalizationMappings, removeNonMatches: true)!
    }

    // Normalize non breaking space
    func normalizeNonBreakingSpace(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }

    // MARK: Extractions
    
    // Extract possible number from string
    func extractPossibleNumber(number: NSString) -> NSString {
        var possibleNumber : NSString = ""
        let start = stringPositionByRegex(PNValidStartPattern, string: number as String)
        if (start >= 0)
        {
            possibleNumber = number.substringFromIndex(start)
            possibleNumber = replaceStringByRegex(PNUnwantedEndPattern, string: possibleNumber as String)
            let secondNumberStart = stringPositionByRegex(PNSecondNumberStartPattern, string: number as String)
            if (secondNumberStart > 0) {
                possibleNumber = possibleNumber.substringWithRange(NSMakeRange(0, secondNumberStart - 1))
            }
        }
        return possibleNumber
    }

    // Extract potential country code
    func extractPotentialCountryCode(var fullNumber: NSString, inout nationalNumber: NSString) -> UInt64? {
        fullNumber = normalizeNonBreakingSpace(fullNumber as String) as NSString
        if ((fullNumber.length == 0) || (fullNumber.substringToIndex(1) == "0")) {
            return 0
        }
        let numberLength = fullNumber.length
        var maxCountryCode = PNMaxLengthCountryCode
        if (fullNumber.hasPrefix("+")) {
            maxCountryCode = PNMaxLengthCountryCode + 1
        }
        let phoneNumberKit = PhoneNumberKit.sharedInstance
        for var i = 1; i <= maxCountryCode && i <= numberLength; i++ {
            let stringRange = NSMakeRange(0, i)
            let subNumber = fullNumber.substringWithRange(stringRange)
            let potentialCountryCode = UInt64(subNumber)
            let regionCodes = phoneNumberKit.countriesForCode(potentialCountryCode!)
            if (regionCodes.count > 0) {
                nationalNumber = fullNumber.substringFromIndex(i)
                return potentialCountryCode
            }
        }
        return 0
    }
    
    // Extract country code
    func extractCountryCode(number: NSString, inout nationalNumber: NSString, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix!)
        if (countryCodeSource != .DefaultCountry) {
            if (fullNumber.length <= PNMinLengthForNSN) {
                return 0
            }
            let potentialCountryCode = extractPotentialCountryCode(fullNumber, nationalNumber: &nationalNumber)
            if (potentialCountryCode != 0) {
                return potentialCountryCode!
            }
            else {
                throw PNParsingError.InvalidCountryCode
            }
        }
        else {
            let defaultCountryCode = String(metadata.countryCode)
            if (fullNumber.hasPrefix(defaultCountryCode)) {
                var potentialNationalNumber = fullNumber.substringFromIndex(defaultCountryCode.characters.count)
                let validNumberPattern = metadata.generalDesc?.nationalNumberPattern
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = potentialNationalNumber.copy()
                let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern
                if ((!matchesEntirely(validNumberPattern!, string: fullNumber as String) && matchesEntirely(validNumberPattern!, string: potentialNationalNumberStr as! String)) || testStringLengthAgainstPattern(possibleNumberPattern!, string: fullNumber as String) == PNValidationResult.TooLong) {
                    nationalNumber = potentialNationalNumberStr as! NSString
                    return UInt64(defaultCountryCode)!
                }
            }
        }
        return 0
    }
    
    func extractNumberType(nationalNumber: NSString, metadata: MetadataTerritory) -> PNPhoneNumberType {
        let generalNumberDesc = metadata.generalDesc!
        if (hasValue(generalNumberDesc.nationalNumberPattern) == false || !isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc)) {
            return PNPhoneNumberType.Unknown
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.premiumRate)) {
            return PNPhoneNumberType.PremiumRate
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.tollFree)) {
            return PNPhoneNumberType.TollFree
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.sharedCost)) {
            return PNPhoneNumberType.SharedCost
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voip)) {
            return PNPhoneNumberType.VOIP
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.personalNumber)) {
            return PNPhoneNumberType.PersonalNumber
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.pager)) {
            return PNPhoneNumberType.Pager
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.uan)) {
            return PNPhoneNumberType.UAN
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voicemail)) {
            return PNPhoneNumberType.Voicemail
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.fixedLine)) {
            return PNPhoneNumberType.FixedLine
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
            return PNPhoneNumberType.Mobile
        }

        return PNPhoneNumberType.Unknown
    }
    
    func isNumberMatchingDesc(nationalNumber: NSString, numberDesc: MetadataPhoneNumberDesc?) -> Bool {
        if (numberDesc == nil) {
            return false
        }
        let metadataDesc = numberDesc!
        if (hasValue(metadataDesc.possibleNumberPattern) == false || metadataDesc.possibleNumberPattern == "NA") {
            return matchesEntirely(metadataDesc.nationalNumberPattern, string: nationalNumber as String)
        }
        if (hasValue(metadataDesc.nationalNumberPattern) == false || metadataDesc.nationalNumberPattern == "NA") {
            return matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber as String)
        }
        return matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber as String) && matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber as String)
    }

    
    // MARK: Validations

    // Check if number is viable
    func isViablePhoneNumber(number: String) -> Bool {
        let numberToParse = normalizeNonBreakingSpace(number)
        if (numberToParse.characters.count < PNMinLengthForNSN) {
            return false;
        }
        return matchesEntirely(PNValidPhoneNumberPattern, string: number)
    }
    
    // Check region is valid for parsing
    func checkRegionForParsing(rawNumber: NSString, defaultRegion: String) -> Bool {
        let phoneNumberKit = PhoneNumberKit.sharedInstance
        return (phoneNumberKit.codeForCountry(defaultRegion) != nil || (rawNumber.length > 0 && matchesAtStart(PNPlusChars, string: rawNumber as String)))
    }
    
    // MARK: Parse
    
    // Try and parse prefix as IDD
    func parsePrefixAsIdd(inout number: NSString, iddPattern: NSString) -> Bool {
        if (stringPositionByRegex(iddPattern as String, string: number as String) == 0) {
            do {
                let matched = try regexMatches(iddPattern as String, string: number as String).first
                let matchedString = number.substringWithRange(matched!.range)
                let matchEnd = matchedString.characters.count
                let remainString : NSString = number.substringFromIndex(matchEnd)
                let capturingDigitPatterns = try NSRegularExpression(pattern: PNCapturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if (matchedGroups.count > 0 && matchedGroups.first != nil) {
                    let digitMatched = remainString.substringWithRange(matchedGroups.first!.range) as NSString
                    if (digitMatched.length > 0) {
                        let normalizedGroup =  stringByReplacingOccurrences(digitMatched as String, map: PNAllNormalizationMappings, removeNonMatches: true)
                        if (normalizedGroup == "0") {
                            return false
                        }
                    }
                }
                number = remainString
                return true
                
            }
            catch {
                return false
            }
        }
        return false
    }

    // MARK: Strip helpers
    
    // Strip extension
    func stripExtension(inout number: NSString) -> String? {
        let mStart = stringPositionByRegex(PNExtnPattern, string: number as String)
        if (mStart >= 0 && (isViablePhoneNumber(number.substringWithRange(NSMakeRange(0, mStart))))) {
            do {
                let firstMatch = try regexMatches(PNExtnPattern, string: number as String).first
                let matchedGroupsLength = firstMatch!.numberOfRanges
                for var i = 1; i < matchedGroupsLength; i++ {
                    let curRange = firstMatch?.rangeAtIndex(i)
                    if (curRange?.location != NSNotFound && curRange?.location < number.length) {
                        let matchString = number.substringWithRange(curRange!)
                        let stringRange = NSMakeRange(0, mStart)
                        number = number.substringWithRange(stringRange)
                        return matchString
                    }
                }
            }
            catch {
            }
        }
        return nil
    }
    
    // Strip international prefix
    func stripInternationalPrefixAndNormalize(inout number: NSString, possibleIddPrefix: NSString) -> PNCountryCodeSource {
        if (matchesAtStart(PNLeadingPlusCharsPattern, string: number as String)) {
            number = replaceStringByRegex(PNLeadingPlusCharsPattern, string: number as String)
            return .NumberWithPlusSign
        }
        number = normalizePhoneNumber(number as String)
        let prefixResult = parsePrefixAsIdd(&number, iddPattern: possibleIddPrefix)
        if (prefixResult == true) {
            return .NumberWithIDD
        }
        else {
            return .DefaultCountry
        }
    }
    
    // Strip national prefix and carrier code
    func stripNationalPrefix(inout number: String, metadata: MetadataTerritory) -> Bool {
        if (metadata.nationalPrefixForParsing != nil) {
            let adjustedNumber : NSString = number as NSString
            let possibleNationalPrefix = metadata.nationalPrefixForParsing!
            let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
            do {
                let currentPattern =  try regexWithPattern(prefixPattern)
                let prefixMatcher = currentPattern.matchesInString(number as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, number.characters.count))
                if (!prefixMatcher.isEmpty) {
                    let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                    let firstMatch = prefixMatcher.first
                    let firstMatchString = adjustedNumber.substringWithRange(firstMatch!.range)
                    let numOfGroups = firstMatch!.numberOfRanges - 1
                    let transformRule = metadata.nationalPrefixTransformRule
                    var transformedNumber : NSString = NSString()
                    let firstRange = firstMatch?.rangeAtIndex(numOfGroups)
                    let firstMatchStringWithGroup = (firstRange!.location != NSNotFound && firstRange!.location < adjustedNumber.length) ? adjustedNumber.substringWithRange(firstRange!) :  ""
                    let noTransform = (transformRule == nil || transformRule?.characters.count == 0 || hasValue(firstMatchStringWithGroup))
                    if (noTransform ==  true) {
                        transformedNumber = adjustedNumber.substringFromIndex(firstMatchString.characters.count)
                    }
                    else {
                        transformedNumber = replaceFirstStringByRegex(prefixPattern, string: number, templateString: transformRule!)!
                        
                    }
                    if (hasValue(nationalNumberRule!) && matchesEntirely(nationalNumberRule!, string: number)){
                        return false
                    }
                    number = transformedNumber as String
                    return true
                }
            }
            catch {
            }

        }
        return false
    }

    
}

