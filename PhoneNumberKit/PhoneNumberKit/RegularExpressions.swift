//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Regular expression

func regexWithPattern(pattern: String) throws -> NSRegularExpression {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        return currentPattern
    }
    catch {
        throw PNRegexError.General
    }
}

func regexMatches(pattern: String, string: String) throws -> [NSTextCheckingResult] {
    do {
        let currentPattern =  try regexWithPattern(pattern)
        let stringRange = NSMakeRange(0, string.characters.count)
        let matches = currentPattern.matchesInString(string, options: [], range: stringRange)
        return matches
    }
    catch {
        throw PNRegexError.General
    }
}

// MARK: Match helpers

public func matchesAtStart(pattern: String, string: String) -> Bool {
    do {
        let matches = try regexMatches(pattern, string: string)
        for match in matches {
            if (match.range.location == 0) {
                return true
            }
        }
    }
    catch {
    }
    return false
}

func stringPositionByRegex(pattern: String, string: String) -> Int {
    do {
        let matches = try regexMatches(pattern, string: string)
        if (matches.count > 0) {
            let match = matches.first
            return (match!.range.location)
        }
        return -1
    } catch {
        return -1
    }
}


public func matchesEntirely(pattern: String?, string: String) -> Bool {
    if (pattern == nil) {
        return false
    }
    var matchesEntirely : Bool = false
    do {
        let matches = try regexMatches(pattern!, string: string)
        let matchResult = matches.first
        let stringRange = NSMakeRange(0, string.characters.count)
        if (matchResult != nil) {
            matchesEntirely = NSEqualRanges(matchResult!.range, stringRange)
        }
    }
    catch {
        matchesEntirely = false
    }
    return matchesEntirely
}

// MARK: String and replace

func replaceStringByRegex(pattern: String, string: String) -> String {
    var replacementResult = string
    do {
        let regex =  try regexWithPattern(pattern)
        let matches = regex.matchesInString(string,
            options: [], range: NSMakeRange(0, string.characters.count))
        if (matches.count == 1) {
            let range = regex.rangeOfFirstMatchInString(string, options: [], range: NSMakeRange(0, string.characters.count))
            if (range.location != NSNotFound) {
                replacementResult = regex.stringByReplacingMatchesInString(string.mutableCopy() as! String, options: [], range: range, withTemplate: "")
            }
            return replacementResult
        }
        else if (matches.count > 1) {
            replacementResult = regex.stringByReplacingMatchesInString(string.mutableCopy() as! String, options: [], range: NSMakeRange(0, string.characters.count), withTemplate: "")
        }
        return replacementResult
    } catch {
        return replacementResult
    }
}

func replaceFirstStringByRegex(pattern: String, string: String, templateString: NSString) -> NSString? {
    var replacementResult : NSString = string
    do {
        let regex = try regexWithPattern(pattern)
        let range = regex.rangeOfFirstMatchInString(string, options: [], range: NSMakeRange(0, string.characters.count))
        if (range.location != NSNotFound) {
            replacementResult = regex.stringByReplacingMatchesInString(string.mutableCopy() as! String, options: [], range: range, withTemplate: templateString as String)
        }
        return replacementResult
    } catch {
        return nil
    }
}

func stringByReplacingOccurrences(string: String, map : [String:String], removeNonMatches : Bool) -> String? {
    let targetString = NSMutableString ()
    let copiedString : NSString = string
    for var i = 0; i < string.characters.count; i++ {
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

// MARK: Validations

func hasValue(value: NSString?) -> Bool {
    if (value == nil) {
        return false
    }
    let spaceCharSet = NSMutableCharacterSet(charactersInString: PNNonBreakingSpace)
    spaceCharSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    if (value!.stringByTrimmingCharactersInSet(spaceCharSet).characters.count == 0) {
        return false
    }
    return true
}

func testStringLengthAgainstPattern(pattern: String, string: String) -> PNValidationResult {
    if (matchesEntirely(pattern, string: string)) {
        return PNValidationResult.IsPossible
    }
    if (stringPositionByRegex(pattern, string: string) == 0) {
        return PNValidationResult.TooLong
    }
    else {
        return PNValidationResult.TooShort
    }
}








