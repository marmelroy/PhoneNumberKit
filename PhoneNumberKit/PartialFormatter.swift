//
//  PartialFormatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/// Partial formatter
public class PartialFormatter {
        
    let regex: RegexManager
    let metadata: MetadataManager
    let parser: PhoneNumberParser

    init(regex: RegexManager, metadata: MetadataManager, parser: PhoneNumberParser, defaultRegion: String, withPrefix: Bool = true) {
        self.regex = regex
        self.metadata = metadata
        self.parser = parser
        self.defaultRegion = defaultRegion
        updateMetadataForDefaultRegion()
        self.withPrefix = withPrefix
    }

    
    var defaultRegion: String {
        didSet {
            updateMetadataForDefaultRegion()
        }
    }
    
    func updateMetadataForDefaultRegion() {
        if let regionMetadata = metadata.filterTerritories(byCountry: defaultRegion) {
            defaultMetadata = metadata.mainTerritory(forCode: regionMetadata.countryCode)
        } else {
            defaultMetadata = nil
        }
        currentMetadata = defaultMetadata
    }
    
    var defaultMetadata: MetadataTerritory?
    var currentMetadata: MetadataTerritory?
    var prefixBeforeNationalNumber =  String()
    var shouldAddSpaceAfterNationalPrefix = false
    
    var withPrefix = true
    
    //MARK: Status
    
    public var currentRegion: String {
        get {
            return currentMetadata?.codeID ?? defaultRegion
        }
    }
    
    
    //MARK: Lifecycle
    
    /**
     Formats a partial string (for use in TextField)
     
     - parameter rawNumber: Unformatted phone number string
     
     - returns: Formatted phone number string.
     */
    public func formatPartial(_ rawNumber: String) -> String {
        // Always reset variables with each new raw number
        resetVariables()
        // Check if number is valid for parsing, if not return raw
        guard isValidRawNumber(rawNumber) else {
            return rawNumber
        }
        // Determine if number is valid by trying to instantiate a PhoneNumber object with it
        let iddFreeNumber = extractIDD(rawNumber)
        var nationalNumber = parser.normalizePhoneNumber(iddFreeNumber)
        if prefixBeforeNationalNumber.characters.count > 0 {
            nationalNumber = extractCountryCallingCode(nationalNumber)
        }
        nationalNumber = extractNationalPrefix(nationalNumber)
        
        if let formats = availableFormats(nationalNumber) {
            if let formattedNumber = applyFormat(nationalNumber, formats: formats) {
                nationalNumber = formattedNumber
            }
            else {
                for format in formats {
                    if let template = createFormattingTemplate(format, rawNumber: nationalNumber) {
                        nationalNumber = applyFormattingTemplate(template, rawNumber: nationalNumber)
                        break
                    }
                }
            }
        }
        var finalNumber = String()
        if prefixBeforeNationalNumber.characters.count > 0 {
            finalNumber.append(prefixBeforeNationalNumber)
        }
        if shouldAddSpaceAfterNationalPrefix && prefixBeforeNationalNumber.characters.count > 0 && prefixBeforeNationalNumber.characters.last != PhoneNumberConstants.separatorBeforeNationalNumber.characters.first  {
            finalNumber.append(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if nationalNumber.characters.count > 0 {
            finalNumber.append(nationalNumber)
        }
        if finalNumber.characters.last == PhoneNumberConstants.separatorBeforeNationalNumber.characters.first {
            finalNumber = finalNumber.substring(to: finalNumber.index(before: finalNumber.endIndex))
        }
        
        return finalNumber
    }
    
    //MARK: Formatting Functions
    
    internal func resetVariables() {
        currentMetadata = defaultMetadata
        prefixBeforeNationalNumber = String()
        shouldAddSpaceAfterNationalPrefix = false
    }
    
    //MARK: Formatting Tests
    
    internal func isValidRawNumber(_ rawNumber: String) -> Bool {
        do {
            // In addition to validPhoneNumberPattern,
            // accept any sequence of digits and whitespace, prefixed or not by a plus sign
            let validPartialPattern = "[+＋]?(\\s*\\d)+\\s*$|\(PhoneNumberPatterns.validPhoneNumberPattern)"
            let validNumberMatches = try regex.regexMatches(validPartialPattern, string: rawNumber)
            let validStart = regex.stringPositionByRegex(PhoneNumberPatterns.validStartPattern, string: rawNumber)
            if validNumberMatches.count == 0 || validStart != 0 {
                return false
            }
        }
        catch {
            return false
        }
        return true
    }
    
    internal func isNanpaNumberWithNationalPrefix(_ rawNumber: String) -> Bool {
        guard currentMetadata?.countryCode == 1 && rawNumber.characters.count > 1 else { return false }
        
        let firstCharacter = rawNumber.characters.first
        let secondCharacter = rawNumber.characters[rawNumber.characters.index(rawNumber.characters.startIndex, offsetBy: 1)]
        return (firstCharacter == "1" && secondCharacter != "0" && secondCharacter != "1")
    }
    
    func isFormatEligible(_ format: MetadataPhoneNumberFormat) -> Bool {
        guard let phoneFormat = format.format else {
            return false
        }
        do {
            let validRegex = try regex.regexWithPattern(PhoneNumberPatterns.eligibleAsYouTypePattern)
            if validRegex.firstMatch(in: phoneFormat, options: [], range: NSMakeRange(0, phoneFormat.characters.count)) != nil {
                return true
            }
        }
        catch {}
        return false
    }
    
    //MARK: Formatting Extractions
    
    func extractIDD(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        do {
            if let internationalPrefix = currentMetadata?.internationalPrefix {
                let prefixPattern = String(format: PhoneNumberPatterns.iddPattern, arguments: [internationalPrefix])
                let matches = try regex.matchedStringByRegex(prefixPattern, string: rawNumber)
                if let m = matches.first {
                    let startCallingCode = m.characters.count
                    let index = rawNumber.characters.index(rawNumber.startIndex, offsetBy: startCallingCode)
                    processedNumber = rawNumber.substring(from: index)
                    prefixBeforeNationalNumber = rawNumber.substring(to: index)
                }
            }
        }
        catch {
            return processedNumber
        }
        return processedNumber
    }
    
    func extractNationalPrefix(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        var startOfNationalNumber: Int = 0
        if isNanpaNumberWithNationalPrefix(rawNumber) {
            prefixBeforeNationalNumber.append("1 ")
        }
        else {
            do {
                if let nationalPrefix = currentMetadata?.nationalPrefixForParsing {
                    let nationalPrefixPattern = String(format: PhoneNumberPatterns.nationalPrefixParsingPattern, arguments: [nationalPrefix])
                    let matches = try regex.matchedStringByRegex(nationalPrefixPattern, string: rawNumber)
                    if let m = matches.first {
                        startOfNationalNumber = m.characters.count
                    }
                }
            }
            catch {
                return processedNumber
            }
        }
        let index = rawNumber.characters.index(rawNumber.startIndex, offsetBy: startOfNationalNumber)
        processedNumber = rawNumber.substring(from: index)
        prefixBeforeNationalNumber.append(rawNumber.substring(to: index))
        return processedNumber
    }
    
    func extractCountryCallingCode(_ rawNumber: String) -> String {
        var processedNumber = rawNumber
        if rawNumber.isEmpty {
            return rawNumber
        }
        var numberWithoutCountryCallingCode = String()
        if prefixBeforeNationalNumber.isEmpty == false && prefixBeforeNationalNumber.characters.first != "+" {
            prefixBeforeNationalNumber.append(PhoneNumberConstants.separatorBeforeNationalNumber)
        }
        if let potentialCountryCode = self.parser.extractPotentialCountryCode(rawNumber, nationalNumber: &numberWithoutCountryCallingCode), potentialCountryCode != 0 {
            processedNumber = numberWithoutCountryCallingCode
            currentMetadata = metadata.mainTerritory(forCode: potentialCountryCode)
            let potentialCountryCodeString = String(potentialCountryCode)
            prefixBeforeNationalNumber.append(potentialCountryCodeString)
            prefixBeforeNationalNumber.append(" ")
        }
        else if withPrefix == false && prefixBeforeNationalNumber.isEmpty {
            let potentialCountryCodeString = String(describing: currentMetadata?.countryCode)
            prefixBeforeNationalNumber.append(potentialCountryCodeString)
            prefixBeforeNationalNumber.append(" ")
        }
        return processedNumber
    }
    
    func availableFormats(_ rawNumber: String) -> [MetadataPhoneNumberFormat]? {
        var tempPossibleFormats = [MetadataPhoneNumberFormat]()
        var possibleFormats = [MetadataPhoneNumberFormat]()
        if let metadata = currentMetadata {
            let formatList = metadata.numberFormats
            for format in formatList {
                if isFormatEligible(format) {
                    tempPossibleFormats.append(format)
                    if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                        if (regex.stringPositionByRegex(leadingDigitPattern, string: String(rawNumber)) == 0) {
                            possibleFormats.append(format)
                        }
                    }
                    else {
                        if (regex.matchesEntirely(format.pattern, string: String(rawNumber))) {
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
        for format in formats {
            if let pattern = format.pattern, let formatTemplate = format.format {
                let patternRegExp = String(format: PhoneNumberPatterns.formatPattern, arguments: [pattern])
                do {
                    let matches = try regex.regexMatches(patternRegExp, string: rawNumber)
                    if matches.count > 0 {
                        if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                            let separatorRegex = try regex.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                            let nationalPrefixMatches = separatorRegex.matches(in: nationalPrefixFormattingRule, options: [], range:  NSMakeRange(0, nationalPrefixFormattingRule.characters.count))
                            if nationalPrefixMatches.count > 0 {
                                shouldAddSpaceAfterNationalPrefix = true
                            }
                        }
                        let formattedNumber = regex.replaceStringByRegex(pattern, string: rawNumber, template: formatTemplate)
                        return formattedNumber
                    }
                }
                catch {
                    
                }
            }
        }
        return nil
    }
    
    
    
    func createFormattingTemplate(_ format: MetadataPhoneNumberFormat, rawNumber: String) -> String?  {
        guard var numberPattern = format.pattern, let numberFormat = format.format else {
            return nil
        }
        guard numberPattern.range(of: "|") == nil else {
            return nil
        }
        do {
            let characterClassRegex = try regex.regexWithPattern(PhoneNumberPatterns.characterClassPattern)
            numberPattern = characterClassRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")
            
            let standaloneDigitRegex = try regex.regexWithPattern(PhoneNumberPatterns.standaloneDigitPattern)
            numberPattern = standaloneDigitRegex.stringByReplacingMatches(in: numberPattern, withTemplate: "\\\\d")
            
            if let tempTemplate = getFormattingTemplate(numberPattern, numberFormat: numberFormat, rawNumber: rawNumber) {
                if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                    let separatorRegex = try regex.regexWithPattern(PhoneNumberPatterns.prefixSeparatorPattern)
                    let nationalPrefixMatch = separatorRegex.firstMatch(in: nationalPrefixFormattingRule, options: [], range:  NSMakeRange(0, nationalPrefixFormattingRule.characters.count))
                    if nationalPrefixMatch != nil {
                        shouldAddSpaceAfterNationalPrefix = true
                    }
                }
                return tempTemplate
            }
        }
        catch { }
        return nil
    }
    
    func getFormattingTemplate(_ numberPattern: String, numberFormat: String, rawNumber: String) -> String? {
        do {
            let matches =  try regex.matchedStringByRegex(numberPattern, string: PhoneNumberConstants.longPhoneNumber)
            if let match = matches.first {
                if match.characters.count < rawNumber.characters.count {
                    return nil
                }
                var template = regex.replaceStringByRegex(numberPattern, string: match, template: numberFormat)
                template = regex.replaceStringByRegex("9", string: template, template: PhoneNumberConstants.digitPlaceholder)
                return template
            }
        }
        catch {
            
        }
        return nil
    }
    
    func applyFormattingTemplate(_ template: String, rawNumber: String) -> String {
        var rebuiltString = String()
        var rebuiltIndex = 0
        for character in template.characters {
            if character == PhoneNumberConstants.digitPlaceholder.characters.first {
                if rebuiltIndex < rawNumber.characters.count {
                    let nationalCharacterIndex = rawNumber.characters.index(rawNumber.startIndex, offsetBy: rebuiltIndex)
                    rebuiltString.append(rawNumber[nationalCharacterIndex])
                    rebuiltIndex += 1
                }
            }
            else {
                if rebuiltIndex < rawNumber.characters.count {
                    rebuiltString.append(character)
                }
            }
        }
        if rebuiltIndex < rawNumber.characters.count {
            let nationalCharacterIndex = rawNumber.characters.index(rawNumber.startIndex, offsetBy: rebuiltIndex)
            let remainingNationalNumber: String = rawNumber.substring(from: nationalCharacterIndex)
            rebuiltString.append(remainingNationalNumber)
        }
        rebuiltString = rebuiltString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        return rebuiltString
    }
    
}
