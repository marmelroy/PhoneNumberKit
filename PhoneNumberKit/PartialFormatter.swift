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
    
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance
    
    let defaultRegion: String
    let defaultMetadata: MetadataTerritory?

    var currentMetadata: MetadataTerritory?
    var prefixBeforeNationalNumber =  String()
    var shouldAddSpaceAfterNationalPrefix = false

    //MARK: Lifecycle
    
    convenience init() {
        let region = PhoneNumberKit().defaultRegionCode()
        self.init(region: region)
    }
    
    /**
     Inits a partial formatter with a custom region
     
     - parameter region: ISO 639 compliant region code.
     
     - returns: PartialFormatter object
     */
    public init(region: String) {
        defaultRegion = region
        defaultMetadata = metadata.fetchMetadataForCountry(defaultRegion)
        currentMetadata = defaultMetadata
    }
    
    /**
     Formats a partial string (for use in TextField)
     
     - parameter rawNumber: Unformatted phone number string
     
     - returns: Formatted phone number string.
     */
    public func formatPartial(rawNumber: String) -> String {
        if rawNumber.isEmpty || rawNumber.characters.count < 3 {
            return rawNumber
        }
        do {
            let validNumberMatches = try regex.regexMatches(validPhoneNumberPattern, string: rawNumber)
            if validNumberMatches.count == 0 {
                return rawNumber
            }
        }
        catch {
            return rawNumber
        }
        currentMetadata = defaultMetadata
        prefixBeforeNationalNumber = String()
        shouldAddSpaceAfterNationalPrefix = false
        let iddFreeNumber = extractIDD(rawNumber)
        let normalizedNumber = parser.normalizePhoneNumber(iddFreeNumber)
        var nationalNumber = extractCountryCallingCode(normalizedNumber)
        nationalNumber = extractNationalPrefix(nationalNumber)
        if let formats = availableFormats() {
            if let formattedNumber = applyFormat(nationalNumber, formats: formats) {
                nationalNumber = formattedNumber
            }
            else if let firstFormat = formats.first, let template = createFormattingTemplate(firstFormat, rawNumber: nationalNumber) {
                nationalNumber = applyFormattingTemplate(template, rawNumber: nationalNumber)
            }
        }
        var finalNumber = String()
        if prefixBeforeNationalNumber.characters.count > 0 {
            finalNumber.appendContentsOf(prefixBeforeNationalNumber)
        }
        if shouldAddSpaceAfterNationalPrefix {
            finalNumber.appendContentsOf(" ")
        }
        if nationalNumber.characters.count > 0 {
            finalNumber.appendContentsOf(nationalNumber)
        }
        return finalNumber
    }
    
    //MARK: Formatting functions
    
    func extractIDD(rawNumber: String) -> String {
        var processedNumber = rawNumber
        do {
            if let internationalPrefix = currentMetadata?.internationalPrefix {
                let prefixPattern = String(format: iddPattern, arguments: [internationalPrefix])
                let matches = try regex.matchedStringByRegex(prefixPattern, string: rawNumber)
                if let m = matches.first {
                    let startCallingCode = m.characters.count
                    let index = rawNumber.startIndex.advancedBy(startCallingCode)
                    processedNumber = rawNumber.substringFromIndex(index)
                    prefixBeforeNationalNumber = rawNumber.substringToIndex(index)
                    if rawNumber.characters.first != "+" {
                        prefixBeforeNationalNumber.appendContentsOf(" ")
                    }
                }
            }
        }
        catch {
            return processedNumber
        }
        return processedNumber
    }
    
    func extractNationalPrefix(rawNumber: String) -> String {
        var processedNumber = rawNumber
        do {
            if let nationalPrefix = currentMetadata?.nationalPrefixForParsing {
                let nationalPrefixPattern = String(format: nationalPrefixParsingPattern, arguments: [nationalPrefix])
                let matches = try regex.matchedStringByRegex(nationalPrefixPattern, string: rawNumber)
                if let m = matches.first {
                    let startCallingCode = m.characters.count
                    let index = rawNumber.startIndex.advancedBy(startCallingCode)
                    processedNumber = rawNumber.substringFromIndex(index)
                    prefixBeforeNationalNumber.appendContentsOf(rawNumber.substringToIndex(index))
                }
            }
        }
        catch {
            return processedNumber
        }
        return processedNumber
    }
    
    func extractCountryCallingCode(rawNumber: String) -> String {
        var processedNumber = rawNumber
        if rawNumber.isEmpty {
            return rawNumber
        }
        var numberWithoutCountryCallingCode = String()
        if let potentialCountryCode = self.parser.extractPotentialCountryCode(rawNumber, nationalNumber: &numberWithoutCountryCallingCode) where potentialCountryCode != 0 {
            processedNumber = numberWithoutCountryCallingCode
            currentMetadata = metadata.fetchMainCountryMetadataForCode(potentialCountryCode)
            prefixBeforeNationalNumber.appendContentsOf("\(potentialCountryCode)")
            if rawNumber.rangeOfString("\(potentialCountryCode)")?.endIndex < rawNumber.endIndex {
                shouldAddSpaceAfterNationalPrefix = true
            }
            else {
                shouldAddSpaceAfterNationalPrefix = false
            }
        }
        return processedNumber
    }

    func availableFormats() -> [MetadataPhoneNumberFormat]? {
        var possibleFormats = [MetadataPhoneNumberFormat]()
        if let metadata = currentMetadata {
            let formatList = metadata.numberFormats
            for format in formatList {
                if isFormatEligible(format) {
                    possibleFormats.append(format)
                }
            }
            return possibleFormats
        }
        return nil
    }
    
    func isFormatEligible(format: MetadataPhoneNumberFormat) -> Bool {
        guard let phoneFormat = format.format else {
            return false
        }
        do {
            let validRegex = try regex.regexWithPattern(eligibleAsYouTypePattern)
            if validRegex.firstMatchInString(phoneFormat, options: [], range: NSMakeRange(0, phoneFormat.characters.count)) != nil {
                return true
            }
        }
        catch {}
        return false
    }
    
    func applyFormat(rawNumber: String, formats: [MetadataPhoneNumberFormat]) -> String? {
        for format in formats {
            if let pattern = format.pattern, let formatTemplate = format.format {
                let patternRegExp = String(format: formatPattern, arguments: [pattern])
                do {
                    let matches = try regex.regexMatches(patternRegExp, string: rawNumber)
                    if matches.count > 0 {
                        if let nationalPrefixFormattingRule = format.nationalPrefixFormattingRule {
                            let separatorRegex = try regex.regexWithPattern(prefixSeparatorPattern)
                            let nationalPrefixMatches = separatorRegex.matchesInString(nationalPrefixFormattingRule, options: [], range:  NSMakeRange(0, nationalPrefixFormattingRule.characters.count))
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
    
    
    
    func createFormattingTemplate(format: MetadataPhoneNumberFormat, rawNumber: String) -> String?  {
        guard var numberPattern = format.pattern, let numberFormat = format.format else {
            return nil
        }
        guard numberPattern.rangeOfString("|") == nil else {
            return nil
        }
        do {
            let characterClassRegex = try regex.regexWithPattern(characterClassPattern)
            var nsString = numberPattern as NSString
            var stringRange = NSMakeRange(0, nsString.length)
            numberPattern = characterClassRegex.stringByReplacingMatchesInString(numberPattern, options: [], range: stringRange, withTemplate: "\\\\d")
    
            let standaloneDigitRegex = try regex.regexWithPattern(standaloneDigitPattern)
            nsString = numberPattern as NSString
            stringRange = NSMakeRange(0, nsString.length)
            numberPattern = standaloneDigitRegex.stringByReplacingMatchesInString(numberPattern, options: [], range: stringRange, withTemplate: "\\\\d")
            
            if let tempTemplate = getFormattingTemplate(numberPattern, numberFormat: numberFormat, rawNumber: rawNumber) {
                return tempTemplate
            }
        }
        catch { }
        return nil
    }
    
    func getFormattingTemplate(numberPattern: String, numberFormat: String, rawNumber: String) -> String? {
        do {
            let matches =  try regex.matchedStringByRegex(numberPattern, string: longPhoneNumber)
            if let match = matches.first {
                if match.characters.count < rawNumber.characters.count {
                    return nil
                }
                var template = regex.replaceStringByRegex(numberPattern, string: match, template: numberFormat)
                template = regex.replaceStringByRegex("9", string: template, template: digitPlaceholder)
                return template
            }
        }
        catch {
        
        }
        return nil
    }
    
    func applyFormattingTemplate(template: String, rawNumber: String) -> String {
        var rebuiltString = String()
        var rebuiltIndex = 0
        for character in template.characters {
            if character == digitPlaceholder.characters.first {
                if rebuiltIndex < rawNumber.characters.count {
                    let nationalCharacterIndex = rawNumber.startIndex.advancedBy(rebuiltIndex)
                    rebuiltString.append(rawNumber[nationalCharacterIndex])
                    rebuiltIndex++
                }
            }
            else {
                rebuiltString.append(character)
            }
        }
        if rebuiltIndex < rawNumber.characters.count {
            let nationalCharacterIndex = rawNumber.startIndex.advancedBy(rebuiltIndex)
            let remainingNationalNumber: String = rawNumber.substringFromIndex(nationalCharacterIndex)
            rebuiltString.appendContentsOf(remainingNationalNumber)
        }
        rebuiltString = rebuiltString.stringByTrimmingCharactersInSet(NSCharacterSet.alphanumericCharacterSet().invertedSet)
        return rebuiltString
    }
    
}
