//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Formatter {
    
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
    
    func formatNationalNumber(phoneNumber: PhoneNumber, regionMetadata: MetadataTerritory) -> String {
        return ""
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
        if let regionMetadata = metadata.metadataPerCode[countryCode] {
            let formattedExtension = formatter.formatExtension(self, regionMetadata: regionMetadata)
            let formattedNationalNumber = ""
//            NSString *formattedNationalNumber = [self formatNsn:nationalSignificantNumber metadata:metadata phoneNumberFormat:numberFormat carrierCode:nil];

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


