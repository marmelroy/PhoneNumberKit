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
    
    func formatExtension(phoneNumber: PhoneNumber, regionMetadata: MetadataTerritory) -> String {
        if let extn = phoneNumber.numberExtension {
            if let preferredExtnPrefix = regionMetadata.preferredExtnPrefix {
                return "\(preferredExtnPrefix)\(extn)"
            }
            else {
                return "\(PNDefaultExtnPrefix)\(extn)"
            }
        }
        return ""
    }
    
    func formatNationalNumber(nationalNumber: String, regionMetadata: MetadataTerritory) -> String {
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
            
        }
        else {
            return nationalNumber
        }
        return ""
    }
    
//    - (NSString *)formatNsnUsingPattern:(NSString *)nationalNumber formattingPattern:(NBNumberFormat*)formattingPattern numberFormat:(NBEPhoneNumberFormat)numberFormat carrierCode:(NSString *)opt_carrierCode
//    {
//    NSString *numberFormatRule = formattingPattern.format;
//    NSString *domesticCarrierCodeFormattingRule = formattingPattern.domesticCarrierCodeFormattingRule;
//    NSString *formattedNationalNumber = @"";
//    
//    if (numberFormat == NBEPhoneNumberFormatNATIONAL && [NBMetadataHelper hasValue:opt_carrierCode] && domesticCarrierCodeFormattingRule.length > 0) {
//    // Replace the $CC in the formatting rule with the desired carrier code.
//    NSString *carrierCodeFormattingRule = [self replaceStringByRegex:domesticCarrierCodeFormattingRule regex:CC_PATTERN withTemplate:opt_carrierCode];
//    // Now replace the $FG in the formatting rule with the first group and
//    // the carrier code combined in the appropriate way.
//    numberFormatRule = [self replaceFirstStringByRegex:numberFormatRule regex:FIRST_GROUP_PATTERN
//    withTemplate:carrierCodeFormattingRule];
//    formattedNationalNumber = [self replaceStringByRegex:nationalNumber regex:formattingPattern.pattern withTemplate:numberFormatRule];
//    } else {
//    // Use the national prefix formatting rule instead.
//    NSString *nationalPrefixFormattingRule = formattingPattern.nationalPrefixFormattingRule;
//    if (numberFormat == NBEPhoneNumberFormatNATIONAL && [NBMetadataHelper hasValue:nationalPrefixFormattingRule]) {
//    NSString *replacePattern = [self replaceFirstStringByRegex:numberFormatRule regex:FIRST_GROUP_PATTERN withTemplate:nationalPrefixFormattingRule];
//    formattedNationalNumber = [self replaceStringByRegex:nationalNumber regex:formattingPattern.pattern withTemplate:replacePattern];
//    } else {
//    formattedNationalNumber = [self replaceStringByRegex:nationalNumber regex:formattingPattern.pattern withTemplate:numberFormatRule];
//    }
//    }
//    
//    if (numberFormat == NBEPhoneNumberFormatRFC3966) {
//    // Strip any leading punctuation.
//    formattedNationalNumber = [self replaceStringByRegex:formattedNationalNumber regex:[NSString stringWithFormat:@"^%@", SEPARATOR_PATTERN] withTemplate:@""];
//    
//    // Replace the rest with a dash between each number group.
//    formattedNationalNumber = [self replaceStringByRegex:formattedNationalNumber regex:SEPARATOR_PATTERN withTemplate:@"-"];
//    }
//    return formattedNationalNumber;
//    }

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
        if let regionMetadata = metadata.metadataPerCode[countryCode] {
            let formattedExtension = formatter.formatExtension(self, regionMetadata: regionMetadata)
            let formattedNationalNumber = formatter.formatNationalNumber(adjustedNationalNumber(), regionMetadata: regionMetadata)

        }
        
        let formattedNumber: String = "+" + String(countryCode) + " " + adjustedNationalNumber()
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


