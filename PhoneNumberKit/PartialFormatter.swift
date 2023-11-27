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

    public convenience init(phoneNumberKit: PhoneNumberKit = PhoneNumberKit(),
                            defaultRegion: String = PhoneNumberKit.defaultRegionCode(),
                            withPrefix: Bool = true,
                            maxDigits: Int? = nil,
                            ignoreIntlNumbers: Bool = false) {
        self.init(phoneNumberKit: phoneNumberKit,
                  regexManager: phoneNumberKit.regexManager,
                  metadataManager: phoneNumberKit.metadataManager,
                  parser: phoneNumberKit.parseManager.parser,
                  defaultRegion: defaultRegion,
                  withPrefix: withPrefix,
                  maxDigits: maxDigits,
                  ignoreIntlNumbers: ignoreIntlNumbers)
    }

    init(phoneNumberKit: PhoneNumberKit,
         regexManager: RegexManager,
         metadataManager: MetadataManager,
         parser: PhoneNumberParser, defaultRegion: String,
         withPrefix: Bool = true,
         maxDigits: Int? = nil,
         ignoreIntlNumbers: Bool = false) {
        self.phoneNumberKit = phoneNumberKit
        self.regexManager = regexManager
        self.metadataManager = metadataManager
        self.parser = parser
        self.defaultRegion = defaultRegion
        self.updateMetadataForDefaultRegion()
        self.withPrefix = withPrefix
        self.maxDigits = maxDigits
        self.ignoreIntlNumbers = ignoreIntlNumbers
    }

    public var defaultRegion: String {
        didSet {
            self.updateMetadataForDefaultRegion()
        }
    }

    public var maxDigits: Int?

    func updateMetadataForDefaultRegion() {
        guard let metadataManager else { return }
        if let regionMetadata = metadataManager.filterTerritories(byCountry: defaultRegion) {
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
    var ignoreIntlNumbers = false

    // MARK: Status

    public var currentRegion: String {
        if ignoreIntlNumbers, currentMetadata?.codeID == "001" {
            return defaultRegion
        } else {
            let countryCode = self.phoneNumberKit.countryCode(for: self.defaultRegion)
            if countryCode != 1, countryCode != 7 {
                return currentMetadata?.codeID ?? "US"
            } else {
                return self.currentMetadata?.countryCode == 1 || self.currentMetadata?.countryCode == 7
                    ? self.defaultRegion
                    : self.currentMetadata?.codeID ?? self.defaultRegion
            }
        }
    }

    public func nationalNumber(from rawNumber: String) -> String {
        guard let parser else { return rawNumber }

        let iddFreeNumber = self.extractIDD(rawNumber)
        var nationalNumber = parser.normalizePhoneNumber(iddFreeNumber)
        if !self.prefixBeforeNationalNumber.isEmpty {
            nationalNumber = self.extractCountryCallingCode(nationalNumber)
        }

        nationalNumber = self.extractNationalPrefix(nationalNumber)

        if let maxDigits {
            let extra = nationalNumber.count - maxDigits

            if extra > 0 {
                nationalNumber = String(nationalNumber.dropLast(extra))
            }
        }

        return nationalNumber
    }

    // MARK: Lifecycle

    /// Formats a partial string (for use in TextField)
    ///
    /// - parameter rawNumber: Unformatted phone number string
    ///
    /// - returns: Formatted phone number string.
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
        if self.withPrefix, !self.prefixBeforeNationalNumber.isEmpty {
            finalNumber.append(self.prefixBeforeNationalNumber)
        }
        if self.withPrefix, self.shouldAddSpaceAfterNationalPrefix, !self.prefixBeforeNationalNumber.isEmpty,
           self.prefixBeforeNationalNumber.last != PhoneNumberConstants.separatorBeforeNationalNumber.first {
            finalNumber.append(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if !nationalNumber.isEmpty {
            finalNumber.append(nationalNumber)
        }
        if finalNumber.last == PhoneNumberConstants.separatorBeforeNationalNumber.first {
            finalNumber = String(finalNumber[..<finalNumber.index(before: finalNumber.endIndex)])
        }
        finalNumber.append(split.pausesOrWaits)
        return finalNumber
    }

    // MARK: Formatting Functions

    func resetVariables() {
        self.currentMetadata = self.defaultMetadata
        self.prefixBeforeNationalNumber = String()
        self.shouldAddSpaceAfterNationalPrefix = false
    }

    // MARK: Formatting Tests

    func isValidRawNumber(_ rawNumber: String) -> Bool {
        do {
            // In addition to validPhoneNumberPattern,
            // accept any sequence of digits and whitespace, prefixed or not by a plus sign
            let validPartialPattern = "[+＋]?(\\s*\\d)+\\s*$|\(PhoneNumberPatterns.validPhoneNumberPattern)"
            let validNumberMatches = try regexManager?.regexMatches(validPartialPattern, string: rawNumber)
            let validStart = self.regexManager?.stringPositionByRegex(PhoneNumberPatterns.validStartPattern,
                                                                      string: rawNumber)
            if validNumberMatches?.isEmpty == true || validStart != 0 {
                return false
            }
        } catch {
            return false
        }
        return true
    }

    func isNanpaNumberWithNationalPrefix(_ rawNumber: String) -> Bool {
        guard self.currentMetadata?.countryCode == 1, rawNumber.count > 1 else { return false }

        let firstCharacter = String(describing: rawNumber.first)
        let secondCharacter = String(describing: rawNumber[rawNumber.index(rawNumber.startIndex, offsetBy: 1)])
        return firstCharacter == "1" && secondCharacter != "0" && secondCharacter != "1"
    }

    func isFormatEligible(_ format: MetadataPhoneNumberFormat) -> Bool {
        guard let phoneFormat = format.format else {
            return false
        }
        let validRegex = try? regexManager?.regexWithPattern(PhoneNumberPatterns.eligibleAsYouTypePattern)
        if validRegex?
            .firstMatch(in: phoneFormat, options: [], range: NSRange(location: 0, length: phoneFormat.count)) != nil {
            return true
        }
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
        var startOfNationalNumber = 0
        if self.isNanpaNumberWithNationalPrefix(rawNumber) {
            self.prefixBeforeNationalNumber.append("1 ")
        } else {
            do {
                if let nationalPrefix = currentMetadata?.nationalPrefixForParsing {
                    let nationalPrefixPattern = String(format: PhoneNumberPatterns.nationalPrefixParsingPattern,
                                                       arguments: [nationalPrefix])
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
        if let potentialCountryCode = parser?.extractPotentialCountryCode(rawNumber,
                                                                          nationalNumber: &numberWithoutCountryCallingCode),
            potentialCountryCode != 0 {
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
            } else {
                return (String(splitBySemiColon[0]), ";" + splitBySemiColon[1])
            }
        }
        return (rawNumber, "")
    }

    func availableFormats(_ rawNumber: String) -> [MetadataPhoneNumberFormat]? {
        guard let regexManager else { return nil }
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
            if possibleFormats.isEmpty {
                possibleFormats.append(contentsOf: tempPossibleFormats)
            }
            return possibleFormats
        }
        return nil
    }

    func applyFormat(_ rawNumber: String, formats: [MetadataPhoneNumberFormat]) -> String? {
        guard let regexManager else { return nil }
        for format in formats {
            guard let pattern = format.pattern, let formatTemplate = format.format else { continue }
            let patternRegExp = String(format: PhoneNumberPatterns.formatPattern, arguments: [pattern])
            guard let matches = try? regexManager.regexMatches(patternRegExp, string: rawNumber),
                  !matches.isEmpty else { continue }
            if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                let separatorRegex = try? regexManager.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                let nationalPrefixMatches = separatorRegex?.matches(
                    in: nationalPrefixFormattingRule,
                    options: [],
                    range: NSRange(
                        location: 0,
                        length: nationalPrefixFormattingRule.count
                    )
                )
                if let nationalPrefixMatches, !nationalPrefixMatches.isEmpty {
                    self.shouldAddSpaceAfterNationalPrefix = true
                }
            }
            let formattedNumber = regexManager.replaceStringByRegex(
                pattern,
                string: rawNumber,
                template: formatTemplate
            )
            return formattedNumber
        }
        return nil
    }

    func createFormattingTemplate(_ format: MetadataPhoneNumberFormat, rawNumber: String) -> String? {
        guard var numberPattern = format.pattern,
              let numberFormat = format.format,
              let regexManager,
              numberPattern.range(of: "|") == nil,
              let characterClassRegex = try? regexManager.regexWithPattern(PhoneNumberPatterns.characterClassPattern),
              let standaloneDigitRegex = try? regexManager.regexWithPattern(PhoneNumberPatterns.standaloneDigitPattern)
        else {
            return nil
        }

        numberPattern = characterClassRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")
        numberPattern = standaloneDigitRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")

        if let tempTemplate = getFormattingTemplate(numberPattern, numberFormat: numberFormat, rawNumber: rawNumber) {
            if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule,
               let separatorRegex = try? regexManager.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern),
               separatorRegex.firstMatch(
                   in: nationalPrefixFormattingRule,
                   options: [],
                   range: NSRange(location: 0, length: nationalPrefixFormattingRule.count)
               ) != nil {
                shouldAddSpaceAfterNationalPrefix = true
            }
            return tempTemplate
        }
        return nil
    }

    func getFormattingTemplate(_ numberPattern: String, numberFormat: String, rawNumber: String) -> String? {
        guard
            let regexManager,
            let matches = try? regexManager.matchedStringByRegex(
                numberPattern,
                string: PhoneNumberConstants.longPhoneNumber
            ),
            let match = matches.first else {
            return nil
        }
        if match.count < rawNumber.count {
            return nil
        }
        var template = regexManager.replaceStringByRegex(
            numberPattern,
            string: match,
            template: numberFormat
        )
        template = regexManager.replaceStringByRegex(
            "9",
            string: template,
            template: PhoneNumberConstants.digitPlaceholder
        )
        return template
    }

    func applyFormattingTemplate(_ template: String, rawNumber: String) -> String {
        guard rawNumber.count > PhoneNumberConstants.minLengthForNSN else { return rawNumber }
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
            let remainingNationalNumber = String(rawNumber[nationalCharacterIndex...])
            rebuiltString.append(remainingNationalNumber)
        }
        rebuiltString = rebuiltString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

        return rebuiltString
    }
}
#endif
