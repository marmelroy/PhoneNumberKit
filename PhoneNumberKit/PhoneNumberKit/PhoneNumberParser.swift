//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

let PNNonBreakingSpace : String = "\u{00a0}"
let PNPlusChars : String = "+＋"
let PNValidDigitsString : String = "0-9０-９٠-٩۰-۹"
let PNRegionCodeForNonGeoEntity : String = "001"

let PNNANPACountryCode : Int = 1
let PNMinLengthForNSN : Int = 2
let PNMaxLengthForNSN : Int = 16
let PNMaxLengthCountryCode : Int = 3
let PNMaxInputStringLength : Int = 250


public enum PNParsingError :  ErrorType {
    case NotANumber
    case TooLong
    case InvalidCountryCode
}


public class PhoneNumberParser: NSObject {

    
    // MARK: PHONE NUMBER HELPERS


    
    public func extractPossibleNumber(number: NSString) -> String {
        var possibleNumber : NSString
        let validStartPattern = "[" + PNPlusChars + PNValidDigitsString + "]"
        let secondNumberStartPattern = "[\\\\\\/] *x";
        let unwantedEndPattern = "[^" + PNValidDigitsString + "A-Za-z#]+$";

        let start = stringPositionByRegex(number as String, pattern: validStartPattern)
        if (start >= 0)
        {
            possibleNumber = number.substringFromIndex(start)
            possibleNumber = replaceStringByRegex(possibleNumber, pattern: unwantedEndPattern)
            let secondNumberStart = stringPositionByRegex(number as String, pattern: secondNumberStartPattern)
            if (secondNumberStart > 0) {
                possibleNumber = possibleNumber.substringWithRange(NSMakeRange(0, secondNumberStart - 1))
            }
        }
        else
        {
            possibleNumber = "";
        }

        return possibleNumber as String
    }
    
    // MARK: STRING HELPERS

    public func normalizeNonBreakingSpace(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }

    
    
    func isViablePhoneNumber(number: String) -> Bool {
        let numberToParse = normalizeNonBreakingSpace(number)
        if (numberToParse.characters.count < PNMinLengthForNSN) {
            return false;
        }
        
        
        return matchesEntirely(PNMValidPhoneNumberPattern, string: number)
    }
    

    
    func checkRegionForParsing(rawNumber: String, defaultRegion: String) -> Bool {
        return (isValidRegionCode(defaultRegion) || (rawNumber.characters.count > 0 && matchesAtStart(PNPlusChars, string: rawNumber)))
    }
    
    func isValidRegionCode(regionCode: String) -> Bool {
        if (PhoneNumberKit().codeForCountry(regionCode) != nil) {
            return true
        }
        else {
            return false
        }
    }
    
    
    func maybeStripExtension(inout number: NSString) -> NSString? {
        let mStart = stringPositionByRegex(number as String, pattern: PNExtnPattern)
        if (mStart >= 0 && (isViablePhoneNumber(number.substringWithRange(NSMakeRange(0, mStart))))) {
            let firstMatch = matchFirst(PNExtnPattern, string: number as String)
            let matchedGroupsLength = firstMatch?.numberOfRanges
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
        return nil
    }
    
    func maybeStripInternationalPrefixAndNormalize(inout number: NSString, possibleIddPrefix: NSString) -> PNCountryCodeSource {
        if (matchesAtStart(PNLeadingPlusCharsPattern, string: number as String)) {
            number = replaceStringByRegex(number, pattern: PNLeadingPlusCharsPattern)
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
    
    func parsePrefixAsIdd(inout number: NSString, iddPattern: NSString) -> Bool {
        if (stringPositionByRegex(number as String, pattern: iddPattern as String) == 0) {
            let matched = matchesByRegex(iddPattern as String, string: number as String)?.first
            let matchedString = number.substringWithRange(matched!.range)
            let matchEnd = matchedString.characters.count
            let remainString : NSString = number.substringFromIndex(matchEnd)
            do {
                let capturingDigitPatterns = try NSRegularExpression(pattern: PNCapturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if (matchedGroups.count > 0 && matchedGroups.first != nil) {
                    let digitMatched = remainString.substringWithRange(matchedGroups.first!.range) as NSString
                    if (digitMatched.length > 0) {
                        let normalizedGroup =  stringByReplacingOccurrences(digitMatched as String, map: PNDigitMappings, removeNonMatches: true)
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

    func normalizePhoneNumber(number: String) -> String {
        let normalizedNumber = normalizeNonBreakingSpace(number)
        if (matchesEntirely(PNValidAlphaPhonePatternString, string: normalizedNumber)) {
            return stringByReplacingOccurrences(number, map: PNAllNormalizationMappings, removeNonMatches: true)!
        }
        else {
            return stringByReplacingOccurrences(number, map: PNDigitMappings, removeNonMatches: true)!
        }
    }
    
    func stringByReplacingOccurrences(source: String, map : [String:String], removeNonMatches : Bool) -> String? {
        let targetString = NSMutableString ()
        let copiedString : NSString = source
        for var i = 0; i < source.characters.count; i++ {
            var oneChar = copiedString.characterAtIndex(i)
            let keyString = NSString(characters: &oneChar, length: 1) as String
            let mappedValue = map[keyString.uppercaseString]
            if (mappedValue != nil) {
                targetString.appendString(mappedValue!)
            }
            else if (removeNonMatches == false) {
                targetString.appendString(keyString as String)
            }
        }
        return targetString as String
    }
    
    func maybeExtractCountryCode(number: NSString, inout nationalNumber: NSString, metadata: MetadataTerritory) throws -> UInt {
        var fullNumber = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let countryCodeSource = maybeStripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix!)
        if (countryCodeSource != .DefaultCountry) {
            if (fullNumber.length <= PNMinLengthForNSN) {
                return 0
            }
            let potentialCountryCode = extractCountryCode(fullNumber, nationalNumber: &nationalNumber)
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
                var potentialNationalNumber : NSString = fullNumber.substringFromIndex(defaultCountryCode.characters.count) as NSString
                let validNumberPattern = metadata.generalDesc?.nationalNumberPattern
                var carrierCode : NSString = NSString()
                maybeStripNationalPrefixAndCarrierCode(&potentialNationalNumber, metadata: metadata, carrierCode: &carrierCode)
                let potentialNationalNumberStr = potentialNationalNumber.copy()
                let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern
                if ((!matchesEntirely(validNumberPattern!, string: fullNumber as String) && matchesEntirely(validNumberPattern!, string: potentialNationalNumberStr as! String)) || testStringLengthAgainstPattern(fullNumber as String, pattern: possibleNumberPattern!) == PNValidationResult.TooLong) {
                        nationalNumber = potentialNationalNumberStr as! NSString
                    return UInt(defaultCountryCode)!
                }
            }
        }
        return 0
    }

    
    func maybeStripNationalPrefixAndCarrierCode(inout number: NSString, metadata: MetadataTerritory, inout carrierCode: NSString) -> Bool {
        if (metadata.nationalPrefixForParsing != nil) {
            let possibleNationalPrefix = metadata.nationalPrefixForParsing!
            let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
            let currentPattern = regularExpressionWithPattern(prefixPattern)
            if (currentPattern != nil) {
                let prefixMatcher = currentPattern!.matchesInString(number as String, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, number.length))
                if (!prefixMatcher.isEmpty) {
                    let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                    let firstMatch = prefixMatcher.first
                    let firstMatchString = number.substringWithRange(firstMatch!.range)
                    let numOfGroups = firstMatch!.numberOfRanges - 1
                    let transformRule = metadata.nationalPrefixTransformRule
                    var transformedNumber : NSString = NSString()
                    let firstRange = firstMatch?.rangeAtIndex(numOfGroups)
                    let firstMatchStringWithGroup = (firstRange!.location != NSNotFound && firstRange!.location < number.length) ? number.substringWithRange(firstRange!) :  ""
                    let noTransform = (transformRule == nil || transformRule?.characters.count == 0 || hasValue(firstMatchStringWithGroup))
                    if (noTransform ==  true) {
                        transformedNumber = number.substringFromIndex(firstMatchString.characters.count)
                    }
                    else {
                        transformedNumber = replaceFirstStringByRegex(number, pattern: prefixPattern, templateString: transformRule!)!
                        
                    }
                    if (hasValue(nationalNumberRule!) && matchesEntirely(nationalNumberRule!, string: number as String)){
                        return false
                    }
                    if ((noTransform && numOfGroups > 0 && hasValue(firstMatchStringWithGroup)) || (!noTransform && numOfGroups > 1)) {
                        if (carrierCode.length > 0) {
                            carrierCode = carrierCode.stringByAppendingString(firstMatchStringWithGroup)
                        }
                        else if ((noTransform && numOfGroups > 0 && hasValue(firstMatchString)) || (!noTransform && numOfGroups > 1)) {
                            if (carrierCode.length > 0) {
                                carrierCode = carrierCode.stringByAppendingString(firstMatchString)
                            }
                        }
                        number = transformedNumber
                        return true
                    }
                }
            }
        }
        return false
    }

    func extractCountryCode(var fullNumber: NSString, inout nationalNumber: NSString) -> UInt? {
        fullNumber = normalizeNonBreakingSpace(fullNumber as String) as NSString
        if ((fullNumber.length == 0) || (fullNumber.substringToIndex(1) == "0")) {
            return 0
        }
        let numberLength = fullNumber.length
        var maxCountryCode = PNMaxLengthCountryCode
        if (fullNumber.hasPrefix("+")) {
            maxCountryCode = PNMaxLengthCountryCode + 1
        }
        for var i = 1; i <= maxCountryCode && i <= numberLength; i++ {
            let stringRange = NSMakeRange(0, i)
            let subNumber = fullNumber.substringWithRange(stringRange)
            let potentialCountryCode = UInt(subNumber)
            let regionCodes = PhoneNumberKit().countriesForCode(potentialCountryCode!)
            if (regionCodes.count > 0) {
                nationalNumber = fullNumber.substringFromIndex(i)
                return potentialCountryCode
            }
        }
        return 0
    }
    
}

