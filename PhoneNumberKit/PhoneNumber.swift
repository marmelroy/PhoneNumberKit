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
 
- numberString: String used to generate phone number struct
- countryCode: Country dialing code as an unsigned. Int.
- leadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
- nationalNumber: National number as an unsigned. Int.
- numberExtension: Extension if available. String. Optional
- type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
*/
public struct PhoneNumber {
    public var numberString: String
    public var countryCode: UInt64
    public var leadingZero: Bool
    public var nationalNumber: UInt64
    public var numberExtension: String?
    public var type: PhoneNumberType
}

extension PhoneNumber : Equatable {

    public static func ==(lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        return (lhs.countryCode == rhs.countryCode)
            && (lhs.leadingZero == rhs.leadingZero)
            && (lhs.nationalNumber == rhs.nationalNumber)
            && (lhs.numberExtension == rhs.numberExtension)
    }

}

extension PhoneNumber : Hashable {

    public var hashValue: Int {
        return countryCode.hashValue ^ nationalNumber.hashValue ^ leadingZero.hashValue ^ (numberExtension?.hashValue ?? 0)
    }

}

/// In past versions of PhoneNumebrKit you were able to initialize a PhoneNumber object to parse a String. Please use a PhoneNumberKit object's methods.
public extension PhoneNumber {
    /**
    DEPRECATED. 
    Parse a string into a phone number object using default region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    */
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    public init(rawNumber: String) throws {
        assertionFailure(PhoneNumberError.deprecated.localizedDescription)
        throw PhoneNumberError.deprecated
    }
    
    /**
    DEPRECATED.
    Parse a string into a phone number object using custom region. Can throw.
    - Parameter rawNumber: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    public init(rawNumber: String, region: String) throws {
        throw PhoneNumberError.deprecated
    }

}


