//
//  RegexManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

final class RegexManager {
    public init() {
        var characterSet = CharacterSet(charactersIn: PhoneNumberConstants.nonBreakingSpace)
        characterSet.formUnion(.whitespacesAndNewlines)
        spaceCharacterSet = characterSet
    }

    // MARK: Regular expression pool

    var regularExpressionPool = [String: NSRegularExpression]()

    private let regularExpressionPoolQueue = DispatchQueue(label: "com.phonenumberkit.regexpool", target: .global())

    var spaceCharacterSet: CharacterSet

    // MARK: Regular expression

    func regexWithPattern(_ pattern: String) throws -> NSRegularExpression {
        var cached: NSRegularExpression?
        cached = regularExpressionPoolQueue.sync {
            regularExpressionPool[pattern]
        }

        if let cached {
            return cached
        }

        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)

            regularExpressionPoolQueue.sync {
                regularExpressionPool[pattern] = regex
            }

            return regex
        } catch {
            throw PhoneNumberError.generalError
        }
    }

    func regexMatches(_ pattern: String, string: String) throws -> [NSTextCheckingResult] {
        do {
            let internalString = string
            let currentPattern = try regexWithPattern(pattern)
            let matches = currentPattern.matches(in: internalString)
            return matches
        } catch {
            throw PhoneNumberError.generalError
        }
    }

    func phoneDataDetectorMatch(_ string: String) throws -> NSTextCheckingResult {
        let fallBackMatches = try regexMatches(PhoneNumberPatterns.validPhoneNumberPattern, string: string)
        if let firstMatch = fallBackMatches.first {
            return firstMatch
        } else {
            throw PhoneNumberError.invalidNumber
        }
    }

    // MARK: Match helpers

    func matchesAtStart(_ pattern: String, string: String) -> Bool {
        guard
            let matches = try? regexMatches(pattern, string: string),
            matches.first(where: { $0.range.location == 0 }) != nil else {
            return false
        }
        return true
    }

    func stringPositionByRegex(_ pattern: String, string: String) -> Int {
        do {
            let matches = try regexMatches(pattern, string: string)
            if let match = matches.first {
                return match.range.location
            }
            return -1
        } catch {
            return -1
        }
    }

    func matchesExist(_ pattern: String?, string: String) -> Bool {
        guard let pattern else {
            return false
        }
        do {
            let matches = try regexMatches(pattern, string: string)
            return !matches.isEmpty
        } catch {
            return false
        }
    }

    func matchesEntirely(_ pattern: String?, string: String) -> Bool {
        guard var pattern else {
            return false
        }
        pattern = "^(\(pattern))$"
        return matchesExist(pattern, string: string)
    }

    func matchedStringByRegex(_ pattern: String, string: String) throws -> [String] {
        guard let matches = try? regexMatches(pattern, string: string) else {
            return []
        }
        return matches.map { string.substring(with: $0.range) }
    }

    // MARK: String and replace

    func replaceStringByRegex(_ pattern: String, string: String, template: String = "") -> String {
        do {
            var replacementResult = string
            let regex = try regexWithPattern(pattern)
            let matches = regex.matches(in: string)
            if matches.count == 1 {
                let range = regex.rangeOfFirstMatch(in: string)
                if range != nil {
                    replacementResult = regex.stringByReplacingMatches(
                        in: string,
                        options: [],
                        range: range,
                        withTemplate: template
                    )
                }
                return replacementResult
            } else if matches.count > 1 {
                replacementResult = regex.stringByReplacingMatches(in: string, withTemplate: template)
            }
            return replacementResult
        } catch {
            return string
        }
    }

    func replaceFirstStringByRegex(_ pattern: String, string: String, templateString: String) -> String {
        do {
            let regex = try regexWithPattern(pattern)
            let range = regex.rangeOfFirstMatch(in: string)
            if range != nil {
                return regex.stringByReplacingMatches(
                    in: string,
                    options: [],
                    range: range,
                    withTemplate: templateString
                )
            }
            return string
        } catch {
            return String()
        }
    }

    func stringByReplacingOccurrences(_ string: String, map: [String: String], keepUnmapped: Bool = false) -> String {
        var targetString = String()
        for i in 0..<string.count {
            let oneChar = string[string.index(string.startIndex, offsetBy: i)]
            let keyString = String(oneChar).uppercased()
            if let mappedValue = map[keyString] {
                targetString.append(mappedValue)
            } else if keepUnmapped {
                targetString.append(keyString)
            }
        }
        return targetString
    }

    // MARK: Validations

    func hasValue(_ value: String?) -> Bool {
        if let valueString = value {
            if valueString.trimmingCharacters(in: spaceCharacterSet).isEmpty {
                return false
            }
            return true
        } else {
            return false
        }
    }

    func testStringLengthAgainstPattern(_ pattern: String, string: String) -> Bool {
        if matchesEntirely(pattern, string: string) {
            return true
        } else {
            return false
        }
    }
}

// MARK: Extensions

extension String {
    func substring(with range: NSRange) -> String {
        let nsString = self as NSString
        return nsString.substring(with: range)
    }
}
