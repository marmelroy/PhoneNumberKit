//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public let PNMValidPhoneNumberPattern : String = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*]*[0-9０-９٠-٩۰-۹]){3,}[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*A-Za-z0-9０-９٠-٩۰-۹]*(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘ#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$"


public let PNLeadingPlusCharsPattern = "^[%@]+" + PNPlusChars

public let PNExtnPattern = "(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)$)$"


public func matchesEntirely(pattern: String, string: String) -> Bool {
    var matches : Bool = false
    if (pattern == "NA") {
        return matches
    }
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions.CaseInsensitive)
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
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions.CaseInsensitive)
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

public func matchFirst(string: String, pattern: String) -> NSTextCheckingResult? {
    do {
        var currentPattern : NSRegularExpression
        currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions.CaseInsensitive)
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
