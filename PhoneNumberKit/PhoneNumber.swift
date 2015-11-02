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
 - Parameter rawNumber: String used to generate phone number strict
 - Parameter type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
 */
struct PhoneNumber {
    let countryCode: UInt64
    private(set) var leadingZero: Bool = false
    let nationalNumber: UInt64
    let numberExtension: String?
    let rawNumber: String
    var type: PNPhoneNumberType { // Compute type on get
        get {
            let parser = PhoneNumberParser()
            let type : PNPhoneNumberType = parser.extractNumberType(String(nationalNumber), countryCode: countryCode)
            return type
        }
    }
}

extension PhoneNumber {
    
    // Parse raw number (with default SIM region)
    init(rawNumber: String) throws {
        let phoneNumberKit = PhoneNumberKit()
        let defaultRegion = phoneNumberKit.defaultRegionCode()
        try self.init(rawNumber: rawNumber, region : defaultRegion)
    }
    
    // Parse raw number with custom region
    init(rawNumber: String, region: String) throws {
        let region = region.uppercaseString
        let phoneNumber = try ParseManager().parsePhoneNumber(rawNumber, region: region)
        self.countryCode = phoneNumber.countryCode!
        self.nationalNumber = phoneNumber.nationalNumber!
        self.rawNumber = phoneNumber.rawNumber!
        self.leadingZero = phoneNumber.leadingZero
        self.numberExtension = phoneNumber.numberExtension
    }
    
    // Parse raw number with custom region
    init(rawNumber: String, countryCode: UInt64, nationalNumber: UInt64, leadingZero: Bool, numberExtension: String?) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
        self.rawNumber = rawNumber
        self.leadingZero = leadingZero
        self.numberExtension = numberExtension
    }
    
    private func adjustedNationalNumber() -> String? {
        // Adding leading zero if needed
        if (self.leadingZero == true) {
            return "0" + String(nationalNumber)
        }
        else {
            return String(nationalNumber)
        }
    }
    
    // Format to E164 format (e.g. +33689123456)
    func toE164() -> String? {
        if let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "+" + String(countryCode) + aNumber
            return formattedNumber
        }
        return nil
    }
    
    // Format to International format (e.g. +33 689123456)
    func toInternational() -> String? {
        if let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "+" + String(countryCode) + " " + aNumber
            return formattedNumber
        }
        return nil
    }
    
    // Format to actionable RFC format (e.g. tel:+33-689123456)
    func toRFC3966() -> String? {
        if let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "tel:+" + String(countryCode) + "-" + aNumber
            return formattedNumber
        }
        return nil
    }

    // Format to local national format (e.g. 0689123456)
    func toNational() -> String? {
        if let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "0" + aNumber
            return formattedNumber
        }
        return nil
    }
    
}


