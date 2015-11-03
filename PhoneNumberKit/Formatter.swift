//
//  Formatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

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
        let formattedNumber: String = "+" + String(countryCode) + " " + adjustedNationalNumber()
        return formattedNumber
    }
    
    /**
     Formats a phone number to actionable RFC format (e.g. tel:+33-689123456)
     - Returns: A string representing the phone number in RFC format.
     */
    public func toRFC3966() -> String {
        let formattedNumber: String = "tel:+" + String(countryCode) + "-" + adjustedNationalNumber()
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


