//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Formatter {
    
    // MARK: Formatting functions
    let regex = RegularExpressions.sharedInstance
    
    /**
     Formats phone numbers for display
     - Parameter phoneNumber: Phone number object.
     - Returns: Modified national number ready for display.
     */
    func formatPhoneNumber(phoneNumber: PhoneNumber, formatType: PNNumberFormat) -> String {
        let metadata = Metadata.sharedInstance
        var formattedNationalNumber = phoneNumber.adjustedNationalNumber()
        if let regionMetadata = metadata.metadataPerCode[phoneNumber.countryCode] {
            formattedNationalNumber = formatNationalNumber(formattedNationalNumber, regionMetadata: regionMetadata, formatType: formatType)
            if let formattedExtension = formatExtension(phoneNumber.numberExtension, regionMetadata: regionMetadata) {
                formattedNationalNumber = formattedNationalNumber + formattedExtension
            }
        }
        return formattedNationalNumber
    }

    
    /**
     Formats extension for display
     - Parameter numberExtension: Number extension string.
     - Returns: Modified number extension with either a preferred extension prefix or the default one.
     */
    func formatExtension(numberExtension: String?, regionMetadata: MetadataTerritory) -> String? {
        if let extns = numberExtension {
            if let preferredExtnPrefix = regionMetadata.preferredExtnPrefix {
                return "\(preferredExtnPrefix)\(extns)"
            }
            else {
                return "\(PNDefaultExtnPrefix)\(extns)"
            }
        }
        return nil
    }
    
    /**
     Formats national number for display
     - Parameter nationalNumber: National number string.
     - Returns: Modified nationalNumber for display.
     */
    func formatNationalNumber(nationalNumber: String, regionMetadata: MetadataTerritory, formatType: PNNumberFormat) -> String {
        let formats = regionMetadata.numberFormats
        var selectedFormat : MetadataPhoneNumberFormat?
        for format in formats {
            if let leadingDigitPattern = format.leadingDigitsPatterns?.last {
                if (regex.stringPositionByRegex(leadingDigitPattern, string: String(nationalNumber)) == 0) {
                    if (regex.matchesEntirely(format.pattern, string: String(nationalNumber))) {
                        selectedFormat = format
                        break;
                    }
                }
            }
            else {
                if (regex.matchesEntirely(format.pattern, string: String(nationalNumber))) {
                    selectedFormat = format
                    break;
                }
            }
        }
        if let formatPattern = selectedFormat {
            let numberFormatRule = (formatType == PNNumberFormat.International && formatPattern.intlFormat != nil) ? formatPattern.intlFormat : formatPattern.format
            var formattedNationalNumber : String?
            var prefixFormattingRule = formatPattern.nationalPrefixFormattingRule
            if prefixFormattingRule?.characters.count > 0 {
                let nationalPrefix = regionMetadata.nationalPrefix
                if nationalPrefix?.characters.count > 0 {
                    prefixFormattingRule = regex.replaceStringByRegex(PNNPPattern, string: prefixFormattingRule!, template: nationalPrefix!)
                    prefixFormattingRule = regex.replaceStringByRegex(PNFGPattern, string: prefixFormattingRule!, template:"\\$1")
                }
                else {
                    prefixFormattingRule = ""
                }
            }
            if (formatType == PNNumberFormat.National && regex.hasValue(prefixFormattingRule)){
                let replacePattern = regex.replaceFirstStringByRegex(PNFirstGroupPattern, string: numberFormatRule!, templateString: prefixFormattingRule!)
                formattedNationalNumber = self.regex.replaceStringByRegex(formatPattern.pattern!, string: nationalNumber, template: replacePattern)
            }
            else {
                formattedNationalNumber = self.regex.replaceStringByRegex(formatPattern.pattern!, string: nationalNumber, template: numberFormatRule!)
            }
            return formattedNationalNumber!
        }
        else {
            return nationalNumber
        }
    }
    
}

public extension PhoneNumber {
    
    // MARK: Formatting extenstions to PhoneNumber
    
    /**
    Formats a phone number to E164 format (e.g. +33689123456)
    - Returns: A string representing the phone number in E164 format.
    */
    public func toE164() -> String {
        let formattedNumber: String = "+" + String(countryCode) + adjustedNationalNumber()
        return formattedNumber
    }
    
    /**
     Formats a phone number to International format (e.g. +33 6 89 12 34 56)
     - Returns: A string representing the phone number in International format.
     */
    public func toInternational() -> String {
        let formatter = Formatter()
        let formattedNationalNumber = formatter.formatPhoneNumber(self, formatType: .International)
        let formattedNumber: String = "+" + String(countryCode) + " " + formattedNationalNumber
        return formattedNumber
    }
    
    /**
     Formats a phone number to local national format (e.g. 06 89 12 34 56)
     - Returns: A string representing the phone number in the local national format.
     */
    public func toNational() -> String {
        let formatter = Formatter()
        let formattedNationalNumber = formatter.formatPhoneNumber(self, formatType: .National)
        let formattedNumber: String = formattedNationalNumber
        return formattedNumber
    }
    
    /**
     Adjust national number for display by adding leading zero if needed. Used for basic formatting functions.
     - Returns: A string representing the adjusted national number.
     */
    private func adjustedNationalNumber() -> String {
        if (self.leadingZero == true) {
            return "0" + String(nationalNumber)
        }
        else {
            return String(nationalNumber)
        }
    }
    
}


