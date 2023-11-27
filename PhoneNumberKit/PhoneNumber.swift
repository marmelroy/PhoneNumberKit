//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

/// Parsed phone number object
///
/// - numberString: String used to generate phone number struct
/// - countryCode: Country dialing code as an unsigned. Int.
/// - leadingZero: Some countries (e.g. Italy) require leading zeros. Bool.
/// - nationalNumber: National number as an unsigned. Int.
/// - numberExtension: Extension if available. String. Optional
/// - type: Computed phone number type on access. Returns from an enumeration - PNPhoneNumberType.
public struct PhoneNumber {
    public let numberString: String
    public let countryCode: UInt64
    public let leadingZero: Bool
    public let nationalNumber: UInt64
    public let numberExtension: String?
    public let type: PhoneNumberType
    public let regionID: String?
}

extension PhoneNumber: Equatable {
    public static func == (lhs: PhoneNumber, rhs: PhoneNumber) -> Bool {
        return (lhs.countryCode == rhs.countryCode)
            && (lhs.leadingZero == rhs.leadingZero)
            && (lhs.nationalNumber == rhs.nationalNumber)
            && (lhs.numberExtension == rhs.numberExtension)
    }
}

extension PhoneNumber: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.countryCode)
        hasher.combine(self.nationalNumber)
        hasher.combine(self.leadingZero)
        if let numberExtension = numberExtension {
            hasher.combine(numberExtension)
        } else {
            hasher.combine(0)
        }
    }
}

public extension PhoneNumber {
    static func notPhoneNumber() -> PhoneNumber {
        return PhoneNumber(numberString: "", countryCode: 0, leadingZero: false, nationalNumber: 0, numberExtension: nil, type: .notParsed, regionID: nil)
    }

    func notParsed() -> Bool {
        return self.type == .notParsed
    }

    /// Get a callable URL from the number.
    /// - Returns: A callable URL.
    var url: URL? {
        return URL(string: "tel://" + numberString)
    }
}

/// In past versions of PhoneNumberKit you were able to initialize a PhoneNumber object to parse a String. Please use a PhoneNumberKit object's methods.
public extension PhoneNumber {
    /// DEPRECATED.
    /// Parse a string into a phone number object using default region. Can throw.
    /// - Parameter rawNumber: String to be parsed to phone number struct.
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    init(rawNumber: String) throws {
        assertionFailure(PhoneNumberError.deprecated.localizedDescription)
        throw PhoneNumberError.deprecated
    }

    /// DEPRECATED.
    /// Parse a string into a phone number object using custom region. Can throw.
    /// - Parameter rawNumber: String to be parsed to phone number struct.
    /// - Parameter region: ISO 3166 compliant region code.
    @available(*, unavailable, message: "use PhoneNumberKit instead to produce PhoneNumbers")
    init(rawNumber: String, region: String) throws {
        throw PhoneNumberError.deprecated
    }
}
