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

    // MARK: PARSER

//    public func parse(rawNumber: String, defaultRegion: String) -> PhoneNumber {
//        let numberToParse = normalizeNonBreakingSpace(rawNumber)
//        let nationalNumber = buildNationalNumber(numberToParse)
//        
//    }
    

    
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
            let firstMatch = matchFirst(number, pattern: PNExtnPattern)
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
    
    
}

