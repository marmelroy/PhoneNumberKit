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
    
    var regularExpresions = [String:RegularExpression]()

    var phoneDataDetector: NSDataDetector? = {
        do {
            let dataDetector = try NSDataDetector(types: TextCheckingResult.CheckingType.phoneNumber.rawValue)
            return dataDetector
        }
        catch {
            return nil
        }
    }()
    
    var spaceCharacterSet: CharacterSet = {
        let characterSet = NSMutableCharacterSet(charactersIn: "\u{00a0}")
        characterSet.formUnion(with: CharacterSet.whitespacesAndNewlines)
        return characterSet as CharacterSet
    }()
    
    deinit {
        regularExpresions.removeAll()
        phoneDataDetector = nil
    }

    // MARK: Regular expression
    
    func regexWithPattern(_ pattern: String) throws -> RegularExpression {
        if let regex = regularExpresions[pattern] {
            return regex
        }
        else {
            do {
                let currentPattern: RegularExpression
                currentPattern =  try RegularExpression(pattern: pattern, options:RegularExpression.Options.caseInsensitive)
                regularExpresions[pattern] = currentPattern
                return currentPattern
            }
            catch {
                throw PhoneNumberError.generalError
            }
        }
    }
    
    func regexMatches(_ pattern: String, string: String) throws -> [TextCheckingResult] {
        do {
            let internalString = string
            let currentPattern =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = internalString as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = currentPattern.matches(in: internalString, options: [], range: stringRange)
            return matches
        }
        catch {
            throw PhoneNumberError.generalError
        }
    }
    
    func phoneDataDetectorMatches(_ string: String) throws -> [TextCheckingResult] {
        let nsString = string as NSString
        let stringRange = NSMakeRange(0, nsString.length)
        guard let matches = phoneDataDetector?.matches(in: string, options: [], range: stringRange) else {
            throw PhoneNumberError.generalError
        }
        if matches.isEmpty == false {
            return matches
        }
        else {
            let fallBackMatches = try regexMatches(PhoneNumberPatterns.validPhoneNumberPattern, string: string)
            if fallBackMatches.isEmpty == false {
                return fallBackMatches
            }
            else {
                throw PhoneNumberError.notANumber
            }
        }
    }
    
    // MARK: Match helpers
    
    func matchesAtStart(_ pattern: String, string: String) -> Bool {
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
    
    func stringPositionByRegex(_ pattern: String, string: String) -> Int {
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
    
    func matchesExist(_ pattern: String?, string: String) -> Bool {
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

    
    func matchesEntirely(_ pattern: String?, string: String) -> Bool {
        guard var pattern = pattern else {
            return false
        }
        pattern = "^(\(pattern))$"
        return matchesExist(pattern, string: string)
    }
    
    func matchedStringByRegex(_ pattern: String, string: String) throws -> [String] {
        do {
            let matches = try regexMatches(pattern, string: string)
            var matchedStrings = [String]()
            for match in matches {
                let processedString = string.substringWithNSRange(match.range)
                matchedStrings.append(processedString)
            }
            return matchedStrings
        }
        catch {
        }
        return []
    }
    
    // MARK: String and replace
    
    func replaceStringByRegex(_ pattern: String, string: String) -> String {
        do {
            var replacementResult = string
            let regex =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = regex.matches(in: string,
                options: [], range: stringRange)
            if matches.count == 1 {
                let range = regex.rangeOfFirstMatch(in: string, options: [], range: stringRange)
                if range.location != NSNotFound {
                    replacementResult = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
                }
                return replacementResult
            }
            else if matches.count > 1 {
                replacementResult = regex.stringByReplacingMatches(in: string, options: [], range: stringRange, withTemplate: "")
            }
            return replacementResult
        } catch {
            return string
        }
    }
    
    func replaceStringByRegex(_ pattern: String, string: String, template: String) -> String {
        do {
            var replacementResult = string
            let regex =  try regexWithPattern(pattern)
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            let nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let matches = regex.matches(in: string,
                options: [], range: stringRange)
            if matches.count == 1 {
                let range = regex.rangeOfFirstMatch(in: string, options: [], range: stringRange)
                if range.location != NSNotFound {
                    replacementResult = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
                }
                return replacementResult
            }
            else if matches.count > 1 {
                replacementResult = regex.stringByReplacingMatches(in: string, options: [], range: stringRange, withTemplate: template)
            }
            return replacementResult
        } catch {
            return string
        }
    }
    
    func replaceFirstStringByRegex(_ pattern: String, string: String, templateString: String) -> String {
        do {
            // NSRegularExpression accepts Swift strings but works with NSString under the hood. Safer to bridge to NSString for taking range.
            var nsString = string as NSString
            let stringRange = NSMakeRange(0, nsString.length)
            let regex = try regexWithPattern(pattern)
            let range = regex.rangeOfFirstMatch(in: string, options: [], range: stringRange)
            if range.location != NSNotFound {
                nsString = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: templateString)
            }
            return nsString as String
        } catch {
            return String()
        }
    }
    
    func stringByReplacingOccurrences(_ string: String, map: [String:String]) -> String {
        var targetString = String()
        for i in 0 ..< string.characters.count {
            let oneChar = string[string.characters.index(string.startIndex, offsetBy: i)]
            let keyString = String(oneChar).uppercased()
            if let mappedValue = map[keyString] {
                targetString.append(mappedValue)
            }
        }
        return targetString
    }
    
    // MARK: Validations
    
    func hasValue(_ value: NSString?) -> Bool {
        if let valueString = value {
            if valueString.trimmingCharacters(in: spaceCharacterSet).characters.count == 0 {
                return false
            }
            return true
        }
        else {
            return false
        }
    }
    
    func testStringLengthAgainstPattern(_ pattern: String, string: String) -> Bool {
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
    func substringWithNSRange(_ range: NSRange) -> String {
        let nsString = self as NSString
        return nsString.substring(with: range)
    }
}



