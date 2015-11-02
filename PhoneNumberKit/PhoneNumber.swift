//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public struct PhoneNumber {
    private(set) public var countryCode: UInt64?
    private(set) public var nationalNumber: UInt64?
    private(set) public var rawNumber: String?
    private(set) public var leadingZero: Bool = false
    private(set) public var numberExtension: String?
    public var type: PNPhoneNumberType { // Compute type on get
        get {
            if let nNumber = nationalNumber, let cCode = countryCode {
                let parser = PhoneNumberParser()
                let type : PNPhoneNumberType = parser.extractNumberType(String(nNumber), countryCode: cCode)
                return type
            }
            return PNPhoneNumberType.Unknown
        }
    }
}

public extension PhoneNumber {
    
    // Parse raw number (with default SIM region)
    public init(rawNumber: String) throws {
        let phoneNumberKit = PhoneNumberKit()
        let defaultRegion = phoneNumberKit.defaultRegionCode()
        try self.init(rawNumber: rawNumber, region : defaultRegion)
    }
    
    // Parse raw number with custom region
    public init(rawNumber: String, region: String) throws {
        let region = region.uppercaseString
        let parseManager = ParseManager.sharedInstance
        let phoneNumber = try parseManager.parsePhoneNumber(rawNumber, region: region)
        self.countryCode = phoneNumber.countryCode
        self.nationalNumber = phoneNumber.nationalNumber
        self.rawNumber = phoneNumber.rawNumber
        self.leadingZero = phoneNumber.leadingZero
        self.numberExtension = phoneNumber.numberExtension
    }
    
    // Parse raw number with custom region
    public init(rawNumber: String, countryCode: UInt64?, nationalNumber: UInt64?, leadingZero: Bool, numberExtension: String?) {
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
        self.rawNumber = rawNumber
        self.leadingZero = leadingZero
        self.numberExtension = numberExtension
    }
    
    private func adjustedNationalNumber() -> String? {
        // Adding leading zero if needed
        if let nNumber = nationalNumber {
            if (self.leadingZero == true) {
                return "0" + String(nNumber)
            }
            else {
                return String(nNumber)
            }
        }
        return nil
    }
    
    // Format to E164 format (e.g. +33689123456)
    public func toE164() -> String? {
        if let cCode = countryCode, let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "+" + String(cCode) + aNumber
            return formattedNumber
        }
        return nil
    }
    
    // Format to International format (e.g. +33 689123456)
    public func toInternational() -> String? {
        if let cCode = countryCode, let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "+" + String(cCode) + " " + aNumber
            return formattedNumber
        }
        return nil
    }
    
    // Format to actionable RFC format (e.g. tel:+33-689123456)
    public func toRFC3966() -> String? {
        if let cCode = countryCode, let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "tel:+" + String(cCode) + "-" + aNumber
            return formattedNumber
        }
        return nil
    }

    // Format to local national format (e.g. 0689123456)
    public func toNational() -> String? {
        if let aNumber = adjustedNationalNumber() {
            let formattedNumber : String = "0" + aNumber
            return formattedNumber
        }
        return nil
    }
    
    
    
}


