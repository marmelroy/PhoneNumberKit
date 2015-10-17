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

        let start = self.stringPositionByRegex(number, pattern: validStartPattern)
        if (start >= 0)
        {
            possibleNumber = number.substringFromIndex(start)
            possibleNumber = replaceStringByRegex(possibleNumber, pattern: unwantedEndPattern)
            let secondNumberStart = self.stringPositionByRegex(number, pattern: secondNumberStartPattern)
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

    func stringPositionByRegex(source: NSString, pattern: String) -> Int {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matchesInString(source as String,
                options: [], range: NSMakeRange(0, source.length))
            if (results.count > 0) {
                let match = results.first
                return (match!.range.location)
            }
            return -1
        } catch {
            return -1
        }
    }
    
    func replaceStringByRegex(source: NSString, pattern: String) -> NSString {
        var replacementResult : NSString = source
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let results = regex.matchesInString(source as String,
                options: [], range: NSMakeRange(0, source.length))
            if (results.count == 1) {
                let range = regex.rangeOfFirstMatchInString(source as String, options: [], range: NSMakeRange(0, source.length))
                if (range.location != NSNotFound) {
                    replacementResult = regex.stringByReplacingMatchesInString(source.mutableCopy() as! String, options: [], range: range, withTemplate: "")
                }
                return replacementResult
            }
            else if (results.count > 1) {
                replacementResult = regex.stringByReplacingMatchesInString(source.mutableCopy() as! String, options: [], range: NSMakeRange(0, source.length), withTemplate: "")
            }
            return replacementResult
        } catch {
            return replacementResult
        }
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
    
    
    func maybeStripExtension(number: String) -> (modifiedNumber: String, extn: String?) {
        let copiedNumber : NSString = number
        let mStart = stringPositionByRegex(copiedNumber, pattern: PNExtnPattern)
        if (mStart >= 0 && (isViablePhoneNumber(copiedNumber.substringWithRange(NSMakeRange(0, mStart))))) {
            let firstMatch = matchFirst(PNExtnPattern, string: number)
            let matchedGroupsLength = firstMatch?.numberOfRanges
            for var i = 1; i < matchedGroupsLength; i++ {
                let curRange = firstMatch?.rangeAtIndex(i)
                if (curRange?.location != NSNotFound && curRange?.location < number.characters.count) {
                    let matchString = copiedNumber.substringWithRange(curRange!)
                    let stringRange = NSMakeRange(0, mStart)
                    let tokenedString = copiedNumber.substringWithRange(stringRange)
                    return (tokenedString as String, matchString)
                }
            }
        }
        return (number, nil)
    }
    
    func maybeStripInternationalPrefixAndNormalize(number: String, possibleIddPrefix: String) -> (modifiedNumber: String, countryCodeSource: PNCountryCodeSource) {
        var copiedNumber : NSString = number
        if (matchesAtStart(number, string: PNLeadingPlusCharsPattern)) {
            copiedNumber = replaceStringByRegex(copiedNumber, pattern: PNLeadingPlusCharsPattern)
            return (copiedNumber as String, .NumberWithPlusSign)
        }
        let normalizedNumber = normalizePhoneNumber(number)
        let prefixResult = parsePrefixAsIdd(normalizedNumber, iddPattern: possibleIddPrefix)
        if (prefixResult.fromNumberWithIDD == true) {
            return (prefixResult.modifiedNumber, .NumberWithIDD)
        }
        else {
            return (prefixResult.modifiedNumber, .DefaultCountry)
        }
    }
    
    func parsePrefixAsIdd(source: String, iddPattern: String) -> (modifiedNumber: String, fromNumberWithIDD: Bool) {
        var copiedNumber : NSString = source
        if (self.stringPositionByRegex(source, pattern: iddPattern) == 0) {
            let matched = matchesByRegex(iddPattern, string: source)?.first
            let matchedString = copiedNumber.substringWithRange(matched!.range)
            let matchEnd = matchedString.characters.count
            let remainString : NSString = copiedNumber.substringFromIndex(matchEnd)
            do {
                let capturingDigitPatterns = try NSRegularExpression(pattern: PNCapturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if (matchedGroups.count > 0 && matchedGroups.first != nil) {
                    let digitMatched = remainString.substringWithRange(matchedGroups.first!.range) as NSString
                    if (digitMatched.length > 0) {
                        let normalizedGroup =  stringByReplacingOccurrences(digitMatched as String, map: PNDigitMappings, removeNonMatches: true)
                        if (normalizedGroup == "0") {
                            return (source, false)
                        }
                    }
                }
                copiedNumber = remainString
                return (copiedNumber as String, true)

            }
            catch {
                return (source, false)
            }
        }
        return (source, false)
    }

    func normalizePhoneNumber(number: String) -> String {
        let normalizedNumber = normalizeNonBreakingSpace(number)
        if (matchesEntirely(PNValidAlphaPhonePatternString, string: normalizedNumber)) {
            return stringByReplacingOccurrences(number, map: PNAllNormalizationMappings, removeNonMatches: true)!
        }
        else {
            return stringByReplacingOccurrences(number, map: PNDigitMappings, removeNonMatches: true)!
        }
        return number
    }
    
    func stringByReplacingOccurrences(source: String, map : [String:String], removeNonMatches : Bool) -> String? {
        let targetString = NSMutableString ()
        let copiedString : NSString = source
        for var i = 1; i < source.characters.count; i++ {
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
    
    func maybeExtractCountryCode(number: String, metadata: MetadataTerritory) -> (modifiedNumber: String, countryCode: UInt?) {
        var copiedNumber : NSString = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let result = maybeStripInternationalPrefixAndNormalize(number, possibleIddPrefix: possibleCountryIddPrefix!)
        copiedNumber = result.modifiedNumber as NSString
        let countryCodeSource = result.countryCodeSource
        if (countryCodeSource != .DefaultCountry) {
            if (copiedNumber.length <= PNMinLengthForNSN) {
                return (copiedNumber as String, 0)
            }
            
//            let potentialCoutryCode =
        }
        return (number, nil)
    }

    
    
//
//        if (countryCodeSource != NBECountryCodeSourceFROM_DEFAULT_COUNTRY) {
//
//            NSNumber *potentialCountryCode = [self extractCountryCode:fullNumber nationalNumber:nationalNumber];
//            
//            if (![potentialCountryCode isEqualToNumber:@0]) {
//                (*phoneNumber).countryCode = potentialCountryCode;
//                return potentialCountryCode;
//            }
//            
//            // If this fails, they must be using a strange country calling code that we
//            // don't recognize, or that doesn't exist.
//            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"INVALID_COUNTRY_CODE:%@", potentialCountryCode]
//                forKey:NSLocalizedDescriptionKey];
//            if (error != NULL) {
//                (*error) = [NSError errorWithDomain:@"INVALID_COUNTRY_CODE" code:0 userInfo:userInfo];
//            }
//            
//            return @0;
//        } else if (defaultRegionMetadata != nil) {
//            // Check to see if the number starts with the country calling code for the
//            // default region. If so, we remove the country calling code, and do some
//            // checks on the validity of the number before and after.
//            NSNumber *defaultCountryCode = defaultRegionMetadata.countryCode;
//            NSString *defaultCountryCodeString = [NSString stringWithFormat:@"%@", defaultCountryCode];
//            NSString *normalizedNumber = [fullNumber copy];
//            
//            if ([normalizedNumber hasPrefix:defaultCountryCodeString]) {
//                NSString *potentialNationalNumber = [normalizedNumber substringFromIndex:defaultCountryCodeString.length];
//                NBPhoneNumberDesc *generalDesc = defaultRegionMetadata.generalDesc;
//                
//                NSString *validNumberPattern = generalDesc.nationalNumberPattern;
//                // Passing null since we don't need the carrier code.
//                [self maybeStripNationalPrefixAndCarrierCode:&potentialNationalNumber metadata:defaultRegionMetadata carrierCode:nil];
//                
//                NSString *potentialNationalNumberStr = [potentialNationalNumber copy];
//                NSString *possibleNumberPattern = generalDesc.possibleNumberPattern;
//                // If the number was not valid before but is valid now, or if it was too
//                // long before, we consider the number with the country calling code
//                // stripped to be a better result and keep that instead.
//                if ((![self matchesEntirely:validNumberPattern string:fullNumber] &&
//                    [self matchesEntirely:validNumberPattern string:potentialNationalNumberStr]) ||
//                    [self testNumberLengthAgainstPattern:possibleNumberPattern number:fullNumber] == NBEValidationResultTOO_LONG) {
//                        (*nationalNumber) = [(*nationalNumber) stringByAppendingString:potentialNationalNumberStr];
//                        if (keepRawInput) {
//                            (*phoneNumber).countryCodeSource = [NSNumber numberWithInt:NBECountryCodeSourceFROM_NUMBER_WITHOUT_PLUS_SIGN];
//                        }
//                        (*phoneNumber).countryCode = defaultCountryCode;
//                        return defaultCountryCode;
//                }
//            }
//        }
//        // No country calling code present.
//        (*phoneNumber).countryCode = @0;
//        return @0;
    
}

