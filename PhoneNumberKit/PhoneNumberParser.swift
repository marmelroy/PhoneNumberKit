//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parser. Contains parsing functions. 
*/
final class PhoneNumberParser {
    let metadata: MetadataManager
    let regex: RegexManager

    init(regex: RegexManager, metadata: MetadataManager) {
        self.regex = regex
        self.metadata = metadata
    }

    // MARK: Normalizations

    /**
    Normalize a phone number (e.g +33 612-345-678 to 33612345678).
    - Parameter number: Phone number string.
    - Returns: Normalized phone number string.
    */
    func normalizePhoneNumber(_ number: String) -> String {
        let normalizationMappings = PhoneNumberPatterns.allNormalizationMappings
        return regex.stringByReplacingOccurrences(number, map: normalizationMappings)
    }

    // MARK: Extractions

    /**
    Extract country code (e.g +33 612-345-678 to 33).
    - Parameter number: Number string.
    - Parameter nationalNumber: National number string - inout.
    - Parameter metadata: Metadata territory object.
    - Returns: Country code is UInt64.
    */
    func extractCountryCode(_ number: String, nationalNumber: inout String, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        guard let possibleCountryIddPrefix = metadata.internationalPrefix else {
            return 0
        }
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix)
        if countryCodeSource != .defaultCountry {
            if fullNumber.count <= PhoneNumberConstants.minLengthForNSN {
                throw PhoneNumberError.tooShort
            }
            if let potentialCountryCode = extractPotentialCountryCode(fullNumber, nationalNumber: &nationalNumber), potentialCountryCode != 0 {
                return potentialCountryCode
            } else {
                return 0
            }
        } else {
            let defaultCountryCode = String(metadata.countryCode)
            if fullNumber.hasPrefix(defaultCountryCode) {
                let nsFullNumber = fullNumber as NSString
                var potentialNationalNumber = nsFullNumber.substring(from: defaultCountryCode.count)
                guard let validNumberPattern = metadata.generalDesc?.nationalNumberPattern, let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern else {
                    return 0
                }
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = potentialNationalNumber
                if ((!regex.matchesEntirely(validNumberPattern, string: fullNumber) && regex.matchesEntirely(validNumberPattern, string: potentialNationalNumberStr )) || regex.testStringLengthAgainstPattern(possibleNumberPattern, string: fullNumber as String) == false) {
                    nationalNumber = potentialNationalNumberStr
                    if let countryCode = UInt64(defaultCountryCode) {
                        return UInt64(countryCode)
                    }
                }
            }
        }
        return 0
    }

    /**
    Extract potential country code (e.g +33 612-345-678 to 33).
    - Parameter fullNumber: Full number string.
    - Parameter nationalNumber: National number string.
    - Returns: Country code is UInt64. Optional.
    */
    func extractPotentialCountryCode(_ fullNumber: String, nationalNumber: inout String) -> UInt64? {
        let nsFullNumber = fullNumber as NSString
        if nsFullNumber.length == 0 || nsFullNumber.substring(to: 1) == "0" {
            return 0
        }
        let numberLength = nsFullNumber.length
        let maxCountryCode = PhoneNumberConstants.maxLengthCountryCode
        var startPosition = 0
        if fullNumber.hasPrefix("+") {
            if nsFullNumber.length == 1 {
                return 0
            }
            startPosition = 1
        }
        for i in 1...numberLength {
            if i > maxCountryCode {
                break
            }
            let stringRange = NSMakeRange(startPosition, i)
            let subNumber = nsFullNumber.substring(with: stringRange)
            if let potentialCountryCode = UInt64(subNumber), metadata.territoriesByCode[potentialCountryCode] != nil {
                    nationalNumber = nsFullNumber.substring(from: i)
                    return potentialCountryCode
            }
        }
        return 0
    }

    // MARK: Validations

    func checkNumberType(_ nationalNumber: String, metadata: MetadataTerritory, leadingZero: Bool = false) -> PhoneNumberType {
        if leadingZero {
            let type = checkNumberType("0" + String(nationalNumber), metadata: metadata)
            if type != .unknown {
                return type
            }
        }

        guard let generalNumberDesc = metadata.generalDesc else {
            return .unknown
        }
        if (regex.hasValue(generalNumberDesc.nationalNumberPattern) == false || isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            return .unknown
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.pager)) {
            return .pager
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.premiumRate)) {
            return .premiumRate
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.tollFree)) {
            return .tollFree
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.sharedCost)) {
            return .sharedCost
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voip)) {
            return .voip
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.personalNumber)) {
            return .personalNumber
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.uan)) {
            return .uan
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voicemail)) {
            return .voicemail
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.fixedLine)) {
            if metadata.fixedLine?.nationalNumberPattern == metadata.mobile?.nationalNumberPattern {
                return .fixedOrMobile
            } else if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
                return .fixedOrMobile
            } else {
                return .fixedLine
            }
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
            return .mobile
        }
        return .unknown
    }

    /**
     Checks if number matches description.
     - Parameter nationalNumber: National number string.
     - Parameter numberDesc:  MetadataPhoneNumberDesc of a given phone number type.
     - Returns: True or false.
     */
    func isNumberMatchingDesc(_ nationalNumber: String, numberDesc: MetadataPhoneNumberDesc?) -> Bool {
        return regex.matchesEntirely(numberDesc?.nationalNumberPattern, string: nationalNumber)
    }

    /**
    Checks and strips if prefix is international dialing pattern.
    - Parameter number: Number string.
    - Parameter iddPattern:  iddPattern for a given country.
    - Returns: True or false and modifies the number accordingly.
    */
    func parsePrefixAsIdd(_ number: inout String, iddPattern: String) -> Bool {
        if (regex.stringPositionByRegex(iddPattern, string: number) == 0) {
            do {
                guard let matched = try regex.regexMatches(iddPattern as String, string: number as String).first else {
                    return false
                }
                let matchedString = number.substring(with: matched.range)
                let matchEnd = matchedString.count
                let remainString = (number as NSString).substring(from: matchEnd)
                let capturingDigitPatterns = try NSRegularExpression(pattern: PhoneNumberPatterns.capturingDigitPattern, options: NSRegularExpression.Options.caseInsensitive)
                let matchedGroups = capturingDigitPatterns.matches(in: remainString as String)
                if let firstMatch = matchedGroups.first {
                    let digitMatched = remainString.substring(with: firstMatch.range) as NSString
                    if digitMatched.length > 0 {
                        let normalizedGroup =  regex.stringByReplacingOccurrences(digitMatched as String, map: PhoneNumberPatterns.allNormalizationMappings)
                        if normalizedGroup == "0" {
                            return false
                        }
                    }
                }
                number = remainString as String
                return true
            } catch {
                return false
            }
        }
        return false
    }

    // MARK: Strip helpers

    /**
    Strip an extension (e.g +33 612-345-678 ext.89 to 89).
    - Parameter number: Number string.
    - Returns: Modified number without extension and optional extension as string.
    */
    func stripExtension(_ number: inout String) -> String? {
        do {
            let matches = try regex.regexMatches(PhoneNumberPatterns.extnPattern, string: number)
            if let match = matches.first {
                let adjustedRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                let matchString = number.substring(with: adjustedRange)
                let stringRange = NSMakeRange(0, match.range.location)
                number = number.substring(with: stringRange)
                return matchString
            }
            return nil
        } catch {
            return nil
        }
    }

    /**
    Strip international prefix.
    - Parameter number: Number string.
    - Parameter possibleIddPrefix:  Possible idd prefix for a given country.
    - Returns: Modified normalized number without international prefix and a PNCountryCodeSource enumeration.
    */
    func stripInternationalPrefixAndNormalize(_ number: inout String, possibleIddPrefix: String?) -> PhoneNumberCountryCodeSource {
        if (regex.matchesAtStart(PhoneNumberPatterns.leadingPlusCharsPattern, string: number as String)) {
            number = regex.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: number as String)
            return .numberWithPlusSign
        }
        number = normalizePhoneNumber(number as String)
        guard let possibleIddPrefix = possibleIddPrefix else {
            return .numberWithoutPlusSign
        }
        let prefixResult = parsePrefixAsIdd(&number, iddPattern: possibleIddPrefix)
        if prefixResult == true {
            return .numberWithIDD
        } else {
            return .defaultCountry
        }
    }

    /**
     Strip national prefix.
     - Parameter number: Number string.
     - Parameter metadata:  Final country's metadata.
     - Returns: Modified number without national prefix.
     */
    func stripNationalPrefix(_ number: inout String, metadata: MetadataTerritory) {
        guard let possibleNationalPrefix = metadata.nationalPrefixForParsing else {
            return
        }
        let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
        do {
            let matches = try regex.regexMatches(prefixPattern, string: number)
            if let firstMatch = matches.first {
                let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                let firstMatchString = number.substring(with: firstMatch.range)
                let numOfGroups = firstMatch.numberOfRanges - 1
                var transformedNumber: String = String()
                let firstRange = firstMatch.range(at: numOfGroups)
                let firstMatchStringWithGroup = (firstRange.location != NSNotFound && firstRange.location < number.count) ? number.substring(with: firstRange):  String()
                let firstMatchStringWithGroupHasValue = regex.hasValue(firstMatchStringWithGroup)
                if let transformRule = metadata.nationalPrefixTransformRule, firstMatchStringWithGroupHasValue == true {
                    transformedNumber = regex.replaceFirstStringByRegex(prefixPattern, string: number, templateString: transformRule)
                } else {
                    let index = number.index(number.startIndex, offsetBy: firstMatchString.count)
                    transformedNumber = String(number[index...])
                }
                if (regex.hasValue(nationalNumberRule) && regex.matchesEntirely(nationalNumberRule, string: number) && regex.matchesEntirely(nationalNumberRule, string: transformedNumber) == false) {
                    return
                }
                number = transformedNumber
                return
            }
        } catch {
            return
        }
    }

}
