//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parser. Contains parsing functions. 
*/
class PhoneNumberParser {
    let metadata = Metadata.sharedInstance
    let regex = RegularExpressions.sharedInstance
        
    // MARK: Normalizations
    
    /**
    Normalize a phone number (e.g +33 612-345-678 to 33612345678).
    - Parameter number: Phone number string.
    - Returns: Normalized phone number string.
    */
    func normalizePhoneNumber(number: String) -> String {
        return regex.stringByReplacingOccurrences(number, map: PNAllNormalizationMappings, removeNonMatches: true)!
    }

    // MARK: Extractions
    
    /**
    Extract country code (e.g +33 612-345-678 to 33).
    - Parameter number: Number string.
    - Parameter nationalNumber: National number string - inout.
    - Parameter metadata: Metadata territory object.
    - Returns: Country code is UInt64.
    */
    func extractCountryCode(number: String, inout nationalNumber: String, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix)
        if (countryCodeSource != .DefaultCountry) {
            if (fullNumber.characters.count <= PNMinLengthForNSN) {
                throw PNParsingError.TooShort
            }
            let potentialCountryCode = extractPotentialCountryCode(fullNumber, nationalNumber: &nationalNumber)
            if (potentialCountryCode != 0) {
                return potentialCountryCode!
            }
            else {
                return 0
            }
        }
        else {
            let defaultCountryCode = String(metadata.countryCode)
            if (fullNumber.hasPrefix(defaultCountryCode)) {
                let nsFullNumber = fullNumber as NSString
                var potentialNationalNumber = nsFullNumber.substringFromIndex(defaultCountryCode.characters.count)
                let validNumberPattern = metadata.generalDesc?.nationalNumberPattern
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = potentialNationalNumber.copy()
                let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern
                if ((!regex.matchesEntirely(validNumberPattern!, string: fullNumber as String) && regex.matchesEntirely(validNumberPattern!, string: potentialNationalNumberStr as! String)) || regex.testStringLengthAgainstPattern(possibleNumberPattern!, string: fullNumber as String) == PNValidationResult.TooLong) {
                    nationalNumber = potentialNationalNumberStr as! String
                    return UInt64(defaultCountryCode)!
                }
            }
        }
        return 0
    }
    
    /**
    Extract potential country code (e.g +33 612-345-678 to 33).
    - Parameter fullNumber: Full number string.
    - Parameter nationalNumber: National number string.
    - Returns: Country code is UInt64. Optional.
    */
    func extractPotentialCountryCode(fullNumber: String, inout nationalNumber: String) -> UInt64? {
        let nsFullNumber = fullNumber as NSString
        if ((nsFullNumber.length == 0) || (nsFullNumber.substringToIndex(1) == "0")) {
            return 0
        }
        let numberLength = nsFullNumber.length
        let maxCountryCode = PNMaxLengthCountryCode
        var startPosition = 0
        if (fullNumber.hasPrefix("+")) {
            if (nsFullNumber.length == 1) {
                return 0
            }
            startPosition = 1
        }
        for var i = 1; i <= maxCountryCode && i <= numberLength; i++ {
            let stringRange = NSMakeRange(startPosition, i)
            let subNumber = nsFullNumber.substringWithRange(stringRange)
            if let potentialCountryCode = UInt64(subNumber)
                where metadata.metadataPerCode[potentialCountryCode] != nil {
                    nationalNumber = nsFullNumber.substringFromIndex(i)
                    return potentialCountryCode
            }
        }
        return 0
    }
    
    // MARK: Validations
    
    /**
    Check number type (e.g +33 612-345-678 to .Mobile).
    - Parameter nationalNumber: National number string.
    - Parameter countryCode:  International country code (e.g 44 for the UK).
    - Returns: Country code is UInt64.
    */
    func checkNumberType(nationalNumber: String, countryCode: UInt64) -> PNPhoneNumberType {
        let metadata: MetadataTerritory =  Metadata.sharedInstance.metadataPerCode[countryCode]!
        let generalNumberDesc = metadata.generalDesc!
        if (regex.hasValue(generalNumberDesc.nationalNumberPattern) == false || isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            return .Unknown
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.fixedLine)) {
            if metadata.fixedLine?.nationalNumberPattern == metadata.mobile?.nationalNumberPattern {
                return .FixedOrMobile
            }
            else if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
                return .FixedOrMobile
            }
            else {
                return .FixedLine
            }
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
            return .Mobile
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.premiumRate)) {
            return .PremiumRate
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.tollFree)) {
            return .TollFree
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.sharedCost)) {
            return .SharedCost
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voip)) {
            return .VOIP
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.personalNumber)) {
            return .PersonalNumber
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.pager)) {
            return .Pager
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.uan)) {
            return .UAN
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voicemail)) {
            return .Voicemail
        }
        return .Unknown
    }
    
    /**
     Checks if number matches description.
     - Parameter nationalNumber: National number string.
     - Parameter numberDesc:  MetadataPhoneNumberDesc of a given phone number type.
     - Returns: True or false.
     */
    func isNumberMatchingDesc(nationalNumber: String, numberDesc: MetadataPhoneNumberDesc?) -> Bool {
        if (numberDesc == nil) {
            return false
        }
        let metadataDesc = numberDesc!
        if (regex.hasValue(metadataDesc.possibleNumberPattern) == false || metadataDesc.possibleNumberPattern == "NA") {
            return regex.matchesEntirely(metadataDesc.nationalNumberPattern, string: nationalNumber)
        }
        if (regex.hasValue(metadataDesc.nationalNumberPattern) == false || metadataDesc.nationalNumberPattern == "NA") {
            return regex.matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber)
        }
        return regex.matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber) || regex.matchesEntirely(metadataDesc.nationalNumberPattern, string: nationalNumber)
    }
    
    /**
    Checks and strips if prefix is international dialing pattern.
    - Parameter number: Number string.
    - Parameter iddPattern:  iddPattern for a given country.
    - Returns: True or false and modifies the number accordingly.
    */
    func parsePrefixAsIdd(inout number: String, iddPattern: String) -> Bool {
        if (regex.stringPositionByRegex(iddPattern, string: number) == 0) {
            do {
                let nsString = number as NSString
                let matched = try regex.regexMatches(iddPattern as String, string: number as String).first
                let matchedString = number.substringWithNSRange(matched!.range)
                let matchEnd = matchedString.characters.count
                let remainString: NSString = nsString.substringFromIndex(matchEnd)
                let capturingDigitPatterns = try NSRegularExpression(pattern: PNCapturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if (matchedGroups.count > 0 && matchedGroups.first != nil) {
                    let digitMatched = remainString.substringWithRange(matchedGroups.first!.range) as NSString
                    if (digitMatched.length > 0) {
                        let normalizedGroup =  regex.stringByReplacingOccurrences(digitMatched as String, map: PNAllNormalizationMappings, removeNonMatches: true)
                        if (normalizedGroup == "0") {
                            return false
                        }
                    }
                }
                number = remainString as String
                return true
            }
            catch {
                return false
            }
        }
        return false
    }

    // MARK: Strip helpers
    
    /**
    Strip an extension (e.g +33 612-345-678 ext.89 to 89).
    - Parameter number: Number string.
    - Returns: Modified number without extension and optional extension as string.
    */
    func stripExtension(inout number: String) -> String? {
        do {
            let matches = try regex.regexMatches(PNExtnPattern, string: number)
            if let match = matches.first {
                let adjustedRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                let matchString = number.substringWithNSRange(adjustedRange)
                let stringRange = NSMakeRange(0, match.range.location)
                number = number.substringWithNSRange(stringRange)
                return matchString
            }
            return nil
        }
        catch {
            return nil
        }
    }
    
    /**
    Strip international prefix.
    - Parameter number: Number string.
    - Parameter possibleIddPrefix:  Possible idd prefix for a given country.
    - Returns: Modified normalized number without international prefix and a PNCountryCodeSource enumeration.
    */
    func stripInternationalPrefixAndNormalize(inout number: String, possibleIddPrefix: String?) -> PNCountryCodeSource {
        if (regex.matchesAtStart(PNLeadingPlusCharsPattern, string: number as String)) {
            number = regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: number as String)
            return .NumberWithPlusSign
        }
        number = normalizePhoneNumber(number as String)
        if (possibleIddPrefix != nil) {
            let prefixResult = parsePrefixAsIdd(&number, iddPattern: possibleIddPrefix!)
            if (prefixResult == true) {
                return .NumberWithIDD
            }
            else {
                return .DefaultCountry
            }
        }
        return .NumberWithoutPlusSign
    }
    
    /**
     Strip national prefix.
     - Parameter number: Number string.
     - Parameter metadata:  Final country's metadata.
     - Returns: Modified number without national prefix.
     */
    func stripNationalPrefix(inout number: String, metadata: MetadataTerritory) {
        if (metadata.nationalPrefixForParsing != nil) {
            let possibleNationalPrefix = metadata.nationalPrefixForParsing!
            let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
            do {
                let matches = try regex.regexMatches(prefixPattern, string: number)
                if (matches.isEmpty == false) {
                    let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                    let firstMatch = matches.first
                    let firstMatchString = number.substringWithNSRange(firstMatch!.range)
                    let numOfGroups = firstMatch!.numberOfRanges - 1
                    let transformRule = metadata.nationalPrefixTransformRule
                    var transformedNumber: String = String()
                    let firstRange = firstMatch?.rangeAtIndex(numOfGroups)
                    let firstMatchStringWithGroup = (firstRange!.location != NSNotFound && firstRange!.location < number.characters.count) ? number.substringWithNSRange(firstRange!):  String()
                    let noTransform = (transformRule == nil || transformRule?.characters.count == 0 || regex.hasValue(firstMatchStringWithGroup) == false)
                    if (noTransform ==  true) {
                        let index = number.startIndex.advancedBy(firstMatchString.characters.count)
                        transformedNumber = number.substringFromIndex(index)
                    }
                    else {
                        transformedNumber = regex.replaceFirstStringByRegex(prefixPattern, string: number, templateString: transformRule!)
                    }
                    if (regex.hasValue(nationalNumberRule!) && regex.matchesEntirely(nationalNumberRule!, string: number) && regex.matchesEntirely(nationalNumberRule!, string: transformedNumber) == false){
                        return
                    }
                    number = transformedNumber
                    return
                }
            }
            catch {
                return
            }
        }
    }
    
}

