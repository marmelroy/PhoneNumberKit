//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public let PNMValidPhoneNumberPattern : String = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*]*[0-9０-９٠-٩۰-۹]){3,}[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*A-Za-z0-9０-９٠-٩۰-۹]*(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘ#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$"

public let PNLeadingPlusCharsPattern = "^[+＋]+"

public let PNCapturingDigitPattern = "([" + PNValidDigitsString + "])"


public let PNExtnPattern = "(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)$)$"

public let PNValidAlphaPhonePatternString = "(?:.*?[A-Za-z]){3}.*"

public let PNDigitMappings : [String: String] = ["0":"0", "1":"1", "2":"2", "3":"3", "4":"4", "5":"5", "6":"6", "7":"7", "8":"8", "9":"9", "\u{FF10}":"0", "\u{FF11}":"1", "\u{FF12}":"2", "\u{FF13}":"3", "\u{FF14}":"4", "\u{FF15}":"5", "\u{FF16}":"6", "\u{FF17}":"7", "\u{FF18}":"8", "\u{FF19}":"9", "\u{0660}":"0", "\u{0661}":"1", "\u{0662}":"2", "\u{0663}":"3", "\u{0664}":"4", "\u{0665}":"5", "\u{0666}":"6", "\u{0667}":"7", "\u{0668}":"8", "\u{0669}":"9", "\u{06F0}":"0", "\u{06F1}":"1", "\u{06F2}":"2", "\u{06F3}":"3", "\u{06F4}":"4", "\u{06F5}":"5", "\u{06F6}":"6", "\u{06F7}":"7", "\u{06F8}":"8", "\u{06F9}":"9"]

public let PNAllNormalizationMappings : [String: String] = ["0":"0", "1":"1", "2":"2", "3":"3", "4":"4", "5":"5", "6":"6", "7":"7", "8":"8", "9":"9", "\u{FF10}":"0", "\u{FF11}":"1", "\u{FF12}":"2", "\u{FF13}":"3", "\u{FF14}":"4", "\u{FF15}":"5", "\u{FF16}":"6", "\u{FF17}":"7", "\u{FF18}":"8", "\u{FF19}":"9", "\u{0660}":"0", "\u{0661}":"1", "\u{0662}":"2", "\u{0663}":"3", "\u{0664}":"4", "\u{0665}":"5", "\u{0666}":"6", "\u{0667}":"7", "\u{0668}":"8", "\u{0669}":"9", "\u{06F0}":"0", "\u{06F1}":"1", "\u{06F2}":"2", "\u{06F3}":"3", "\u{06F4}":"4", "\u{06F5}":"5", "\u{06F6}":"6", "\u{06F7}":"7", "\u{06F8}":"8", "\u{06F9}":"9", "A":"2", "B":"2", "C":"2", "D":"3", "E":"3", "F":"3", "G":"4", "H":"4", "I":"4", "J":"5", "K":"5", "L":"5", "M":"6", "N":"6", "O":"6", "P":"7", "Q":"7", "R":"7", "S":"7", "T":"8", "U":"8", "V":"8", "W":"9", "X":"9", "Y":"9", "Z":"9"]

public enum PNValidationResult :  ErrorType {
    case Unknown
    case IsPossible
    case InvalidCountryCode
    case TooShort
    case TooLong
}

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






