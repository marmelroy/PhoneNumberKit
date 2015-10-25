//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public func matchesEntirely(pattern: String, string: String) -> Bool {
    var matches : Bool = false
    if (pattern == "NA") {
        return matches
    }
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

func replaceFirstStringByRegex(source: NSString, pattern: String, templateString: NSString) -> NSString? {
    var replacementResult : NSString = source
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let range = regex.rangeOfFirstMatchInString(source as String, options: [], range: NSMakeRange(0, source.length))
        if (range.location != NSNotFound) {
            replacementResult = regex.stringByReplacingMatchesInString(source.mutableCopy() as! String, options: [], range: range, withTemplate: templateString as String)
        }

        return replacementResult
    } catch {
        return nil
    }
}

func hasValue(value: NSString) -> Bool {
    let spaceCharSet = NSMutableCharacterSet(charactersInString: PNNonBreakingSpace)
    spaceCharSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    if (value.stringByTrimmingCharactersInSet(spaceCharSet).characters.count == 0) {
        return false
    }
    return true
}


func stringPositionByRegex(source: String, pattern: String) -> Int {
    do {
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let results = regex.matchesInString(source as String,
            options: [], range: NSMakeRange(0, source.characters.count))
        if (results.count > 0) {
            let match = results.first
            return (match!.range.location)
        }
        return -1
    } catch {
        return -1
    }
}



func testStringLengthAgainstPattern(source: String, pattern: String) -> PNValidationResult {
    if (matchesEntirely(pattern, string: source)) {
        return PNValidationResult.IsPossible
    }
    if (stringPositionByRegex(source, pattern: pattern) == 0) {
        return PNValidationResult.TooLong
    }
    else {
        return PNValidationResult.TooShort
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





