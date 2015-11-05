//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Formatter {
    
    let regex = RegularExpressions.sharedInstance
    
    func formatExtension(phoneNumber: PhoneNumber, regionMetadata: MetadataTerritory) -> String? {
        if let extn = phoneNumber.numberExtension {
            if let preferredExtnPrefix = regionMetadata.preferredExtnPrefix {
                return "\(preferredExtnPrefix)\(extn)"
            }
            else {
                return "\(PNDefaultExtnPrefix)\(extn)"
            }
        }
        return nil
    }
    
    func formatNationalNumber(nationalNumber: String, regionMetadata: MetadataTerritory, desiredFormatType: PNNumberFormat) -> String {
        let formats = regionMetadata.numberFormats
        var selectedFormat : MetadataPhoneNumberFormat?
        for format in formats {
            if let leadingDigitPattern = format.leadingDigitsPatterns {
                if (regex.stringPositionByRegex(leadingDigitPattern, string: String(nationalNumber)) == 0) {
                    selectedFormat = format
                }
            }
        }
        if let format = selectedFormat {
            let result = formatNationalNumber(nationalNumber, formatPattern: format, desiredFormatType: desiredFormatType)
            return result
        }
        else {
            return nationalNumber
        }
    }
    
    func formatNationalNumber(nationalNumber: String, formatPattern: MetadataPhoneNumberFormat, desiredFormatType: PNNumberFormat)  -> String {
        let numberFormatRule = formatPattern.format
        var formattedNationalNumber : String?
        let nationalPrefixFormattingRule = formatPattern.nationalPrefixFormattingRule
        if (desiredFormatType == PNNumberFormat.National && regex.hasValue(nationalPrefixFormattingRule)){
            let replacePattern = regex.replaceFirstStringByRegex(numberFormatRule!, string: PNFirstGroupPattern, templateString: nationalPrefixFormattingRule!)
            formattedNationalNumber = self.regex.replaceStringByRegex(formatPattern.pattern!, string: nationalNumber, template: replacePattern)
        }
        else {
            formattedNationalNumber = self.regex.replaceStringByRegex(formatPattern.pattern!, string: nationalNumber, template: numberFormatRule!)
        }
        

        return formattedNationalNumber!
    }
    
}

public extension PhoneNumber {
    
    // MARK: Formatting
    
    /**
    Formats a phone number to E164 format (e.g. +33689123456)
    - Returns: A string representing the phone number in E164 format.
    */
    public func toE164() -> String {
        let formattedNumber: String = "+" + String(countryCode) + adjustedNationalNumber()
        return formattedNumber
    }
    
    /**
     Formats a phone number to International format (e.g. +33 689123456)
     - Returns: A string representing the phone number in International format.
     */
    public func toInternational() -> String {
        let formatter = Formatter()
        let metadata = Metadata.sharedInstance
        var formattedNationalNumber = adjustedNationalNumber()
        if let regionMetadata = metadata.metadataPerCode[countryCode] {
            formattedNationalNumber = formatter.formatNationalNumber(adjustedNationalNumber(), regionMetadata: regionMetadata, desiredFormatType: PNNumberFormat.International)
            if let formattedExtension = formatter.formatExtension(self, regionMetadata: regionMetadata) {
                formattedNationalNumber = formattedNationalNumber + formattedExtension
            }
        }
        let formattedNumber: String = "+" + String(countryCode) + " " + formattedNationalNumber
        return formattedNumber
    }
    
    /**
     Formats a phone number to local national format (e.g. 0689123456)
     - Returns: A string representing the phone number in the local national format.
     */
    public func toNational() -> String {
        let formattedNumber: String = "0" + adjustedNationalNumber()
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


