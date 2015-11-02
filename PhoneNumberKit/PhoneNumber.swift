//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parsed ☎️#️⃣ object
- Parameter countryCode: Country dialing code as an unsigned. Int.
- Parameter leadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
- Parameter nationalNumber: National number as an unsigned. Int.
- Parameter numberExtension: Extension if available. String. Optional
- Parameter rawNumber: String used to generate phone number struct
- Parameter type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
*/
struct PhoneNumber {
    let countryCode: UInt64
    private(set) var leadingZero: Bool = false
    let nationalNumber: UInt64
    let numberExtension: String?
    let rawNumber: String
    var type: PNPhoneNumberType {
        get {
            let parser = PhoneNumberParser()
            let type: PNPhoneNumberType = parser.checkNumberType(String(nationalNumber), countryCode: countryCode)
            return type
        }
    }
}

extension PhoneNumber {
    /**
    Parse a string into a phone number object using default region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    */
    init(rawNumber: String) throws {
        let defaultRegion = PhoneNumberKit().defaultRegionCode()
        try self.init(rawNumber: rawNumber, region: defaultRegion)
    }
    
    /**
    Parse a string into a phone number object using custom region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    init(rawNumber: String, region: String) throws {
        let phoneNumber = try ParseManager().parsePhoneNumber(rawNumber, region: region)
        self = phoneNumber
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
    
    // MARK: Formatting
    
    /**
    Formats a phone number to E164 format (e.g. +33689123456)
    - Returns: A string representing the phone number in E164 format.
    */
    func toE164() -> String {
        let formattedNumber: String = "+" + String(countryCode) + adjustedNationalNumber()
        return formattedNumber
    }
    
    /**
    Formats a phone number to International format (e.g. +33 689123456)
    - Returns: A string representing the phone number in International format.
    */
    func toInternational() -> String {
        let formattedNumber: String = "+" + String(countryCode) + " " + adjustedNationalNumber()
        return formattedNumber
    }
    
    /**
    Formats a phone number to actionable RFC format (e.g. tel:+33-689123456)
    - Returns: A string representing the phone number in RFC format.
    */
    func toRFC3966() -> String {
        let formattedNumber: String = "tel:+" + String(countryCode) + "-" + adjustedNationalNumber()
        return formattedNumber
    }

    /**
    Formats a phone number to local national format (e.g. 0689123456)
    - Returns: A string representing the phone number in the local national format.
    */
    func toNational() -> String {
        let formattedNumber: String = "0" + adjustedNationalNumber()
        return formattedNumber
    }
    
}


