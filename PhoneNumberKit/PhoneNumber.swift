//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public struct PhoneNumber {
    private(set) public var countryCode: UInt64
    private(set) public var nationalNumber: UInt64
    private(set) public var numberExtension: String?
    private(set) public var rawNumber: String
    private(set) public var leadingZero: Bool
    public var type: PNPhoneNumberType {
        if (nationalNumber != 0 && countryCode != 0) {
            let parser = PhoneNumberParser()
            let regionMetaData : MetadataTerritory =  Metadata.sharedInstance.metadataPerCode[countryCode]!
            let type : PNPhoneNumberType = parser.extractNumberType(String(nationalNumber),metadata: regionMetaData)
            return type
        }
        return PNPhoneNumberType.Unknown
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
        let parser = PhoneNumberParser()
        let phoneNumber = try parser.parsePhoneNumber(rawNumber, region: region)
        self.countryCode = phoneNumber.countryCode
        self.nationalNumber = phoneNumber.nationalNumber
        if let extn = phoneNumber.numberExtension {
            self.numberExtension = extn
        }
        self.rawNumber = phoneNumber.rawNumber
        self.leadingZero = phoneNumber.leadingZero
    }
    
    private func adjustedNationalNumber() -> String {
        // Adding leading zero if needed
        if (self.leadingZero) {
            return "0" + String(nationalNumber)
        }
        else {
            return String(nationalNumber)
        }
    }
    
    // Format to E164 format (e.g. +33689123456)
    public func toE164() -> String {
        let formattedNumber : String = "+" + String(countryCode) + adjustedNationalNumber()
        return formattedNumber
    }
    
    // Format to International format (e.g. +33 689123456)
    public func toInternational() -> String {
        let formattedNumber : String = "+" + String(countryCode) + " " + adjustedNationalNumber()
        return formattedNumber
    }
    
    // Format to actionable RFC format (e.g. tel:+33-689123456)
    public func toRFC3966() -> String {
        let formattedNumber : String = "tel:+" + String(countryCode) + "-" + adjustedNationalNumber()
        return formattedNumber
    }

    // Format to local national format (e.g. 0689123456)
    public func toNational() -> String {
        let formattedNumber : String = "0" + String(nationalNumber)
        return formattedNumber
    }
    
    
    
}


