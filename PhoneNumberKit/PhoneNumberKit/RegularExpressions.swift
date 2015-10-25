//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Match helpers

public func matchesEntirely(pattern: String, string: String) -> Bool {
    var matches : Bool = false
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        let stringRange = NSMakeRange(0, string.characters.count)
        let matchResult = currentPattern.firstMatchInString(string, options: NSMatchingOptions.Anchored, range: stringRange)
        if (matchResult != nil) {
            matches = NSEqualRanges(matchResult!.range, stringRange)
        }
    }
    catch {
        matches = false
    }
    return matches
}

public func matchesAtStart(pattern: String, string: String) -> Bool {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        let stringRange = NSMakeRange(0, string.characters.count)
        let matches = currentPattern.matchesInString(string, options: NSMatchingOptions.Anchored, range: stringRange)
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

public func matchFirst(pattern: String, string: String) -> NSTextCheckingResult? {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        let stringRange = NSMakeRange(0, string.characters.count)
        let matches = currentPattern.matchesInString(string, options: [], range: stringRange)
        if (matches.count > 0) {
            return matches.first
        }
        else {
            return nil
        }
    }
    catch {
        return nil
    }
}

public func matchesByRegex(pattern: String, string: String) -> [AnyObject]? {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        let stringRange = NSMakeRange(0, string.characters.count)
        let matches = currentPattern.matchesInString(string, options: [], range: stringRange)
        return matches
    }
    catch {
        return nil
    }
}

func stringPositionByRegex(pattern: String, string: String) -> Int {
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matchesInString(string,
            options: [], range: NSMakeRange(0, string.characters.count))
        if (results.count > 0) {
            let match = results.first
            return (match!.range.location)
        }
        return -1
    } catch {
        return -1
    }
}

// MARK: Regular expression

public func regularExpressionWithPattern(pattern: String) -> NSRegularExpression? {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions(rawValue: 0))
        return currentPattern
    }
    catch {
        return nil
    }
}

// MARK: String and replace

func replaceStringByRegex(pattern: String, string: String) -> NSString {
    var replacementResult : NSString = string
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matchesInString(string as String,
            options: [], range: NSMakeRange(0, string.characters.count))
        if (results.count == 1) {
            let range = regex.rangeOfFirstMatchInString(string, options: [], range: NSMakeRange(0, string.characters.count))
            if (range.location != NSNotFound) {
                replacementResult = regex.stringByReplacingMatchesInString(string.mutableCopy() as! String, options: [], range: range, withTemplate: "")
            }
            return replacementResult
        }
        else if (results.count > 1) {
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
        let regex = try NSRegularExpression(pattern: pattern, options: [])
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

func hasValue(value: NSString) -> Bool {
    let spaceCharSet = NSMutableCharacterSet(charactersInString: PNNonBreakingSpace)
    spaceCharSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    if (value.stringByTrimmingCharactersInSet(spaceCharSet).characters.count == 0) {
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








