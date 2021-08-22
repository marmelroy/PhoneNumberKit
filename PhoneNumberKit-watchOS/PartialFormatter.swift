//
//  PartialFormatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/11/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

#if canImport(ObjectiveC)
import Foundation

/// Partial formatter
public final class PartialFormatter {
    private let phoneNumberKit: PhoneNumberKit

    weak var metadataManager: MetadataManager?
    weak var parser: PhoneNumberParser?
    weak var regexManager: RegexManager?

    public convenience init(phoneNumberKit: PhoneNumberKit = PhoneNumberKit(), defaultRegion: String = PhoneNumberKit.defaultRegionCode(), withPrefix: Bool = true, maxDigits: Int? = nil) {
        self.init(phoneNumberKit: phoneNumberKit, regexManager: phoneNumberKit.regexManager, metadataManager: phoneNumberKit.metadataManager, parser: phoneNumberKit.parseManager.parser, defaultRegion: defaultRegion, withPrefix: withPrefix, maxDigits: maxDigits)
    }

    init(phoneNumberKit: PhoneNumberKit, regexManager: RegexManager, metadataManager: MetadataManager, parser: PhoneNumberParser, defaultRegion: String, withPrefix: Bool = true, maxDigits: Int? = nil) {
        self.phoneNumberKit = phoneNumberKit
        self.regexManager = regexManager
        self.metadataManager = metadataManager
        self.parser = parser
        self.defaultRegion = defaultRegion
        self.updateMetadataForDefaultRegion()
        self.withPrefix = withPrefix
        self.maxDigits = maxDigits
    }

    public var defaultRegion: String {
        didSet {
            self.updateMetadataForDefaultRegion()
        }
    }

    public var maxDigits: Int?

    func updateMetadataForDefaultRegion() {
        guard let metadataManager = metadataManager else { return }
        if let regionMetadata = metadataManager.territoriesByCountry[defaultRegion] {
            self.defaultMetadata = metadataManager.mainTerritory(forCode: regionMetadata.countryCode)
        } else {
            self.defaultMetadata = nil
        }
        self.currentMetadata = self.defaultMetadata
    }

    var defaultMetadata: MetadataTerritory?
    var currentMetadata: MetadataTerritory?
    var prefixBeforeNationalNumber = String()
    var shouldAddSpaceAfterNationalPrefix = false
    var withPrefix = true

    // MARK: Status

    public var currentRegion: String {
        if self.phoneNumberKit.countryCode(for: self.defaultRegion) != 1 {
            return currentMetadata?.codeID ?? "US"
        } else {
            return self.currentMetadata?.countryCode == 1
                ? self.defaultRegion
                : self.currentMetadata?.codeID ?? self.defaultRegion
        }
    }

    public func nationalNumber(from rawNumber: String) -> String {
        guard let parser = parser else { return rawNumber }

        let iddFreeNumber = self.extractIDD(rawNumber)
        var nationalNumber = parser.normalizePhoneNumber(iddFreeNumber)
        if self.prefixBeforeNationalNumber.count > 0 {
            nationalNumber = self.extractCountryCallingCode(nationalNumber)
        }

        nationalNumber = self.extractNationalPrefix(nationalNumber)

        if let maxDigits = maxDigits {
            let extra = nationalNumber.count - maxDigits

            if extra > 0 {
                nationalNumber = String(nationalNumber.dropLast(extra))
            }
        }

        return nationalNumber
    }

    // MARK: Lifecycle

    /**
     Formats a partial string (for use in TextField)

     - parameter rawNumber: Unformatted phone number string

     - returns: Formatted phone number string.
     */
    public func formatPartial(_ rawNumber: String) -> String {
        // Always reset variables with each new raw number
        self.resetVariables()

        guard self.isValidRawNumber(rawNumber) else {
            return rawNumber
        }
        let split = splitNumberAndPausesOrWaits(rawNumber)
        
        var nationalNumber = self.nationalNumber(from: split.number)
        if let formats = availableFormats(nationalNumber) {
            if let formattedNumber = applyFormat(nationalNumber, formats: formats) {
                nationalNumber = formattedNumber
            } else {
                for format in formats {
                    if let template = createFormattingTemplate(format, rawNumber: nationalNumber) {
                        nationalNumber = self.applyFormattingTemplate(template, rawNumber: nationalNumber)
                        break
                    }
                }
            }
        }

        var finalNumber = String()
        if self.withPrefix, self.prefixBeforeNationalNumber.count > 0 {
            finalNumber.append(self.prefixBeforeNationalNumber)
        }
        if self.withPrefix, self.shouldAddSpaceAfterNationalPrefix, self.prefixBeforeNationalNumber.count > 0, self.prefixBeforeNationalNumber.last != PhoneNumberConstants.separatorBeforeNationalNumber.first {
            finalNumber.append(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if nationalNumber.count > 0 {
            finalNumber.append(nationalNumber)
        }
        if finalNumber.last == PhoneNumberConstants.separatorBeforeNationalNumber.first {
            finalNumber = String(finalNumber[..<finalNumber.index(before: finalNumber.endIndex)])
        }
        finalNumber.append(split.pausesOrWaits)
        return finalNumber
    }

    // MARK: Formatting Functions

    internal func resetVariables() {
        self.currentMetadata = self.defaultMetadata
        self.prefixBeforeNationalNumber = String()
        self.shouldAddSpaceAfterNationalPrefix = false
    }

    // MARK: Formatting Tests

    internal func isValidRawNumber(_ rawNumber: String) -> Bool {
        do {
            // In addition to validPhoneNumberPattern,
            // accept any sequence of digits and whitespace, prefixed or not by a plus sign
            let validPartialPattern = "[+＋]?(\\s*\\d)+\\s*$|\(PhoneNumberPatterns.validPhoneNumberPattern)"
            let validNumberMatches = try regexManager?.regexMatches(validPartialPattern, string: rawNumber)
            let validStart = self.regexManager?.stringPositionByRegex(PhoneNumberPatterns.validStartPattern, string: rawNumber)
            if validNumberMatches?.count == 0 || validStart != 0 {
                return false
            }
        } catch {
            return false
        }
        return true
    }

    internal func isNanpaNumberWithNationalPrefix(_ rawNumber: String) -> Bool {
        guard self.currentMetadata?.countryCode == 1, rawNumber.count > 1 else { return false }

        let firstCharacter: String = String(describing: rawNumber.first)
        let secondCharacter: String = String(describing: rawNumber[rawNumber.index(rawNumber.startIndex, offsetBy: 1)])
        return (firstCharacter == "1" && secondCharacter != "0" && secondCharacter != "1")
    }

    func isFormatEligible(_ format: MetadataPhoneNumberFormat) -> Bool {
        guard let phoneFormat = format.format else {
            return false
        }
        do {
            let validRegex = try regexManager?.regexWithPattern(PhoneNumberPatterns.eligibleAsYouTypePattern)
            if validRegex?.firstMatch(in: phoneFormat, options: [], range: NSRange(location: 0, length: phoneFormat.count)) != nil {
                return true
            }
        } catch {}
        return false
    }

    // MARK: Formatting Extractions

    func extractIDD(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        do {
            if let internationalPrefix = currentMetadata?.internationalPrefix {
                let prefixPattern = String(format: PhoneNumberPatterns.iddPattern, arguments: [internationalPrefix])
                let matches = try regexManager?.matchedStringByRegex(prefixPattern, string: rawNumber)
                if let m = matches?.first {
                    let startCallingCode = m.count
                    let index = rawNumber.index(rawNumber.startIndex, offsetBy: startCallingCode)
                    processedNumber = String(rawNumber[index...])
                    self.prefixBeforeNationalNumber = String(rawNumber[..<index])
                }
            }
        } catch {
            return processedNumber
        }
        return processedNumber
    }

    func extractNationalPrefix(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        var startOfNationalNumber: Int = 0
        if self.isNanpaNumberWithNationalPrefix(rawNumber) {
            self.prefixBeforeNationalNumber.append("1 ")
        } else {
            do {
                if let nationalPrefix = currentMetadata?.nationalPrefixForParsing {
                    let nationalPrefixPattern = String(format: PhoneNumberPatterns.nationalPrefixParsingPattern, arguments: [nationalPrefix])
                    let matches = try regexManager?.matchedStringByRegex(nationalPrefixPattern, string: rawNumber)
                    if let m = matches?.first {
                        startOfNationalNumber = m.count
                    }
                }
            } catch {
                return processedNumber
            }
        }
        let index = rawNumber.index(rawNumber.startIndex, offsetBy: startOfNationalNumber)
        processedNumber = String(rawNumber[index...])
        self.prefixBeforeNationalNumber.append(String(rawNumber[..<index]))
        return processedNumber
    }

    func extractCountryCallingCode(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        if rawNumber.isEmpty {
            return rawNumber
        }
        var numberWithoutCountryCallingCode = String()
        if self.prefixBeforeNationalNumber.isEmpty == false, self.prefixBeforeNationalNumber.first != "+" {
            self.prefixBeforeNationalNumber.append(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if let potentialCountryCode = parser?.extractPotentialCountryCode(rawNumber, nationalNumber: &numberWithoutCountryCallingCode), potentialCountryCode != 0 {
            processedNumber = numberWithoutCountryCallingCode
            self.currentMetadata = self.metadataManager?.mainTerritory(forCode: potentialCountryCode)
            let potentialCountryCodeString = String(potentialCountryCode)
            prefixBeforeNationalNumber.append(potentialCountryCodeString)
            self.prefixBeforeNationalNumber.append(" ")
        } else if self.withPrefix == false, self.prefixBeforeNationalNumber.isEmpty {
            let potentialCountryCodeString = String(describing: currentMetadata?.countryCode)
            self.prefixBeforeNationalNumber.append(potentialCountryCodeString)
            self.prefixBeforeNationalNumber.append(" ")
        }
        return processedNumber
    }
    
    func splitNumberAndPausesOrWaits(_ rawNumber: String) -> (number: String, pausesOrWaits: String) {
        if rawNumber.isEmpty {
            return (rawNumber, "")
        }
        
        let splitByComma = rawNumber.split(separator: ",", maxSplits: 1, omittingEmptySubsequences: false)
        let splitBySemiColon = rawNumber.split(separator: ";", maxSplits: 1, omittingEmptySubsequences: false)
        
        if splitByComma[0].count != splitBySemiColon[0].count {
            let foundCommasFirst = splitByComma[0].count < splitBySemiColon[0].count
            
            if foundCommasFirst {
                return (String(splitByComma[0]), "," + splitByComma[1])
            }
            else {
                return (String(splitBySemiColon[0]), ";" + splitBySemiColon[1])
            }
        }
        return (rawNumber, "")
    }
    
    func availableFormats(_ rawNumber: String) -> [MetadataPhoneNumberFormat]? {
        guard let regexManager = regexManager else { return nil }
        var tempPossibleFormats = [MetadataPhoneNumberFormat]()
        var possibleFormats = [MetadataPhoneNumberFormat]()
        if let metadata = currentMetadata {
            let formatList = metadata.numberFormats
            for format in formatList {
                if self.isFormatEligible(format) {
                    tempPossibleFormats.append(format)
                    if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                        if regexManager.stringPositionByRegex(leadingDigitPattern, string: String(rawNumber)) == 0 {
                            possibleFormats.append(format)
                        }
                    } else {
                        if regexManager.matchesEntirely(format.pattern, string: String(rawNumber)) {
                            possibleFormats.append(format)
                        }
                    }
                }
            }
            if possibleFormats.count == 0 {
                possibleFormats.append(contentsOf: tempPossibleFormats)
            }
            return possibleFormats
        }
        return nil
    }

    func applyFormat(_ rawNumber: String, formats: [MetadataPhoneNumberFormat]) -> String? {
        guard let regexManager = regexManager else { return nil }
        for format in formats {
            if let pattern = format.pattern, let formatTemplate = format.format {
                let patternRegExp = String(format: PhoneNumberPatterns.formatPattern, arguments: [pattern])
                do {
                    let matches = try regexManager.regexMatches(patternRegExp, string: rawNumber)
                    if matches.count > 0 {
                        if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                            let separatorRegex = try regexManager.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                            let nationalPrefixMatches = separatorRegex.matches(in: nationalPrefixFormattingRule, options: [], range: NSRange(location: 0, length: nationalPrefixFormattingRule.count))
                            if nationalPrefixMatches.count > 0 {
                                self.shouldAddSpaceAfterNationalPrefix = true
                            }
                        }
                        let formattedNumber = regexManager.replaceStringByRegex(pattern, string: rawNumber, template: formatTemplate)
                        return formattedNumber
                    }
                } catch {}
            }
        }
        return nil
    }

    func createFormattingTemplate(_ format: MetadataPhoneNumberFormat, rawNumber: String) -> String? {
        guard var numberPattern = format.pattern, let numberFormat = format.format, let regexManager = regexManager else {
            return nil
        }
        guard numberPattern.range(of: "|") == nil else {
            return nil
        }
        do {
            let characterClassRegex = try regexManager.regexWithPattern(PhoneNumberPatterns.characterClassPattern)
            numberPattern = characterClassRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")

            let standaloneDigitRegex = try regexManager.regexWithPattern(PhoneNumberPatterns.standaloneDigitPattern)
            numberPattern = standaloneDigitRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")

            if let tempTemplate = getFormattingTemplate(numberPattern, numberFormat: numberFormat, rawNumber: rawNumber) {
                if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                    let separatorRegex = try regexManager.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                    let nationalPrefixMatch = separatorRegex.firstMatch(in: nationalPrefixFormattingRule, options: [], range: NSRange(location: 0, length: nationalPrefixFormattingRule.count))
                    if nationalPrefixMatch != nil {
                        self.shouldAddSpaceAfterNationalPrefix = true
                    }
                }
                return tempTemplate
            }
        } catch {}
        return nil
    }

    func getFormattingTemplate(_ numberPattern: String, numberFormat: String, rawNumber: String) -> String? {
        guard let regexManager = regexManager else { return nil }
        do {
            let matches = try regexManager.matchedStringByRegex(numberPattern, string: PhoneNumberConstants.longPhoneNumber)
            if let match = matches.first {
                if match.count < rawNumber.count {
                    return nil
                }
                var template = regexManager.replaceStringByRegex(numberPattern, string: match, template: numberFormat)
                template = regexManager.replaceStringByRegex("9", string: template, template: PhoneNumberConstants.digitPlaceholder)
                return template
            }
        } catch {}
        return nil
    }

    func applyFormattingTemplate(_ template: String, rawNumber: String) -> String {
        var rebuiltString = String()
        var rebuiltIndex = 0
        for character in template {
            if character == PhoneNumberConstants.digitPlaceholder.first {
                if rebuiltIndex < rawNumber.count {
                    let nationalCharacterIndex = rawNumber.index(rawNumber.startIndex, offsetBy: rebuiltIndex)
                    rebuiltString.append(rawNumber[nationalCharacterIndex])
                    rebuiltIndex += 1
                }
            } else {
                if rebuiltIndex < rawNumber.count {
                    rebuiltString.append(character)
                }
            }
        }
        if rebuiltIndex < rawNumber.count {
            let nationalCharacterIndex = rawNumber.index(rawNumber.startIndex, offsetBy: rebuiltIndex)
            let remainingNationalNumber: String = String(rawNumber[nationalCharacterIndex...])
            rebuiltString.append(remainingNationalNumber)
        }
        rebuiltString = rebuiltString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return rebuiltString
    }
}
#endif
