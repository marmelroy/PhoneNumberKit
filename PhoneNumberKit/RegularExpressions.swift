//
//  RegularExpressions.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class RegularExpressions {
    
    static let sharedInstance = RegularExpressions()
    
    private let regexQueue = dispatch_queue_create("regex", DISPATCH_QUEUE_CONCURRENT)
    var regularExpressions = [String:NSRegularExpression]()
    
    var phoneDataDetector: NSDataDetector?

    // MARK: Regular expression
    
    func regexWithPattern(pattern: String) throws -> NSRegularExpression {
        
        var regex : NSRegularExpression?
        
        dispatch_sync(self.regexQueue) {
            regex = self.regularExpressions[pattern]
        }
        
        if let regex = regex {
            return regex
        } else {
            do {
                var currentPattern: NSRegularExpression
                currentPattern =  try NSRegularExpression(pattern: pattern, options:NSRegularExpressionOptions.CaseInsensitive)
                
                dispatch_barrier_async(self.regexQueue) {
                    [weak self] in
                    if let strongSelf = self {
                        strongSelf.regularExpressions.updateValue(currentPattern, forKey: pattern)
                    }
                }
                
                return currentPattern
            }
            catch {
                throw PhoneNumberError.GeneralError
            }
        }
    }
    
    func regexMatches(pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString = string
            let currentPattern =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = internalString as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = currentPattern.matchesInString(internalString, options: [], range: stringRange)
            return matches
        }
        catch {
            throw PhoneNumberError.GeneralError
        }
    }
    
    func phoneDataDetectorMatches(string: String) throws -> [NSTextCheckingResult] {
        var dataDetector: NSDataDetector
        if let phoneDataDetector = phoneDataDetector {
            dataDetector = phoneDataDetector
        }
        else {
            do {
                dataDetector = try NSDataDetector(types: NSTextCheckingType.PhoneNumber.rawValue)
                self.phoneDataDetector = dataDetector
            }
            catch {
                throw PhoneNumberError.GeneralError
            }
        }
        let nsString = string as NSString
        let stringRange = NSMakeRange(0, nsString.length)
        let matches = dataDetector.matchesInString(string, options: [], range: stringRange)
        if matches.isEmpty == false {
            return matches
        }
        else {
            let fallBackMatches = try regexMatches(validPhoneNumberPattern, string: string)
            if fallBackMatches.isEmpty == false {
                return fallBackMatches
            }
            else {
                throw PhoneNumberError.NotANumber
            }
        }
    }
    
    // MARK: Match helpers
    
    func matchesAtStart(pattern: String, string: String) -> Bool {
        do {
            let matches = try regexMatches(pattern, string: string)
            for match in matches {
                if match.range.location == 0 {
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
            if let match = matches.first {
                return (match.range.location)
            }
            return -1
        } catch {
            return -1
        }
    }
    
    func matchesExist(pattern: String?, string: String) -> Bool {
        guard let pattern = pattern else {
            return false
        }
        do {
            let matches = try regexMatches(pattern, string: string)
            return matches.count > 0
        }
        catch {
            return false
        }
    }

    
    func matchesEntirely(pattern: String?, string: String) -> Bool {
        guard let pattern = pattern else {
            return false
        }
        var isMatchingEntirely: Bool = false
        do {
            let matches = try regexMatches(pattern, string: string)
            let nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            for match in matches {
                if (NSEqualRanges(match.range, stringRange)) {
                    isMatchingEntirely = true
                }
            }
            return isMatchingEntirely
        }
        catch {
            return false
        }
    }
    
    // MARK: String and replace
    
    func replaceStringByRegex(pattern: String, string: String) -> String {
        do {
            var replacementResult = string
            let regex =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = regex.matchesInString(string,
                options: [], range: stringRange)
            if matches.count == 1 {
                let range = regex.rangeOfFirstMatchInString(string, options: [], range: stringRange)
                if range.location != NSNotFound {
                    replacementResult = regex.stringByReplacingMatchesInString(string, options: [], range: range, withTemplate: "")
                }
                return replacementResult
            }
            else if matches.count > 1 {
                replacementResult = regex.stringByReplacingMatchesInString(string, options: [], range: stringRange, withTemplate: "")
            }
            return replacementResult
        } catch {
            return string
        }
    }
    
    func replaceStringByRegex(pattern: String, string: String, template: String) -> String {
        do {
            var replacementResult = string
            let regex =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = regex.matchesInString(string,
                options: [], range: stringRange)
            if matches.count == 1 {
                let range = regex.rangeOfFirstMatchInString(string, options: [], range: stringRange)
                if range.location != NSNotFound {
                    replacementResult = regex.stringByReplacingMatchesInString(string, options: [], range: range, withTemplate: template)
                }
                return replacementResult
            }
            else if matches.count > 1 {
                replacementResult = regex.stringByReplacingMatchesInString(string, options: [], range: stringRange, withTemplate: template)
            }
            return replacementResult
        } catch {
            return string
        }
    }
    
    func replaceFirstStringByRegex(pattern: String, string: String, templateString: String) -> String {
        do {
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            var nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let regex = try regexWithPattern(pattern)
            let range = regex.rangeOfFirstMatchInString(string, options: [], range: stringRange)
            if range.location != NSNotFound {
                nsString = regex.stringByReplacingMatchesInString(string, options: [], range: range, withTemplate: templateString)
            }
            return nsString as String
        } catch {
            return String()
        }
    }
    
    func stringByReplacingOccurrences(string: String, map: [String:String], removeNonMatches: Bool) -> String {
        let targetString = NSMutableString ()
        let copiedString: NSString = string
        for var i = 0; i < string.characters.count; i++ {
            var oneChar = copiedString.characterAtIndex(i)
            let keyString = NSString(characters: &oneChar, length: 1) as String
            if let mappedValue = map[keyString.uppercaseString] {
                targetString.appendString(mappedValue)
            }
            else if removeNonMatches == false {
                targetString.appendString(keyString as String)
            }
        }
        return targetString as String
    }
    
    // MARK: Validations
    
    func hasValue(value: NSString?) -> Bool {
        guard let value = value else {
            return false
        }
        let spaceCharSet = NSMutableCharacterSet(charactersInString: nonBreakingSpace)
        spaceCharSet.formUnionWithCharacterSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if value.stringByTrimmingCharactersInSet(spaceCharSet).characters.count == 0 {
            return false
        }
        return true
    }
    
    func testStringLengthAgainstPattern(pattern: String, string: String) -> Bool {
        if (matchesEntirely(pattern, string: string)) {
            return true
        }
        else {
            return false
        }
    }
    
}



// MARK: Extensions

extension String {
    func substringWithNSRange(range: NSRange) -> String {
        let nsString = self as NSString
        return nsString.substringWithRange(range)
    }
}



