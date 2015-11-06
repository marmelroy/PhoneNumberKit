//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Parsed phone number object
- Parameter countryCode: Country dialing code as an unsigned. Int.
- Parameter leadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
- Parameter nationalNumber: National number as an unsigned. Int.
- Parameter numberExtension: Extension if available. String. Optional
- Parameter rawNumber: String used to generate phone number struct
- Parameter type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
*/
public struct PhoneNumber {
    public let countryCode: UInt64
    private(set) public var leadingZero: Bool = false
    public let nationalNumber: UInt64
    public let numberExtension: String?
    public let rawNumber: String
    public var type: PNPhoneNumberType {
        get {
            let parser = PhoneNumberParser()
            let type: PNPhoneNumberType = parser.checkNumberType(String(nationalNumber), countryCode: countryCode)
            return type
        }
    }
}

public extension PhoneNumber {
    /**
    Parse a string into a phone number object using default region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    */
    public init(rawNumber: String) throws {
        let defaultRegion = PhoneNumberKit().defaultRegionCode()
        try self.init(rawNumber: rawNumber, region: defaultRegion)
    }
    
    /**
    Parse a string into a phone number object using custom region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    public init(rawNumber: String, region: String) throws {
        let phoneNumber = try ParseManager().parsePhoneNumber(rawNumber, region: region)
        self = phoneNumber
    }

}


