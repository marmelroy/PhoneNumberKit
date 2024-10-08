//
//  PhoneNumber+Codable.swift
//  PhoneNumberKit
//
//  Created by David Roman on 16/11/2021.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

/// The strategy used to decode a `PhoneNumber` value.
public enum PhoneNumberDecodingStrategy {
    /// Decode `PhoneNumber` properties as key-value pairs. This is the default strategy.
    case properties
    /// Decode `PhoneNumber` as a E164 formatted string.
    case e164
    /// The default `PhoneNumber` encoding strategy.
    public static var `default` = properties
}

/// The strategy used to encode a `PhoneNumber` value.
public enum PhoneNumberEncodingStrategy {
    /// Encode `PhoneNumber` properties as key-value pairs. This is the default strategy.
    case properties
    /// Encode `PhoneNumber` as a E164 formatted string.
    case e164
    /// The default `PhoneNumber` encoding strategy.
    public static var `default` = properties
}

public enum PhoneNumberDecodingUtils {
    /// The default `PhoneNumberUtility` instance used for parsing when decoding, if needed.
    public static var defaultUtility: () -> PhoneNumberUtility = { .init() }
}

public enum PhoneNumberEncodingUtils {
    /// The default `PhoneNumberUtility` instance used for formatting when encoding, if needed.
    public static var defaultUtility: () -> PhoneNumberUtility = { .init() }
}

public extension JSONDecoder {
    /// The strategy used to decode a `PhoneNumber` value.
    var phoneNumberDecodingStrategy: PhoneNumberDecodingStrategy {
        get {
            return userInfo[.phoneNumberDecodingStrategy] as? PhoneNumberDecodingStrategy ?? .default
        }
        set {
            userInfo[.phoneNumberDecodingStrategy] = newValue
        }
    }

    /// The `PhoneNumberUtility` instance used for parsing when decoding, if needed.
    var phoneNumberUtility: () -> PhoneNumberUtility {
        get {
            return userInfo[.phoneNumberUtility] as? () -> PhoneNumberUtility ?? PhoneNumberDecodingUtils.defaultUtility
        }
        set {
            userInfo[.phoneNumberUtility] = newValue
        }
    }
}

public extension JSONEncoder {
    /// The strategy used to encode a `PhoneNumber` value.
    var phoneNumberEncodingStrategy: PhoneNumberEncodingStrategy {
        get {
            return userInfo[.phoneNumberEncodingStrategy] as? PhoneNumberEncodingStrategy ?? .default
        }
        set {
            userInfo[.phoneNumberEncodingStrategy] = newValue
        }
    }

    /// The `PhoneNumberUtility` instance used for formatting when encoding, if needed.
    var phoneNumberUtility: () -> PhoneNumberUtility {
        get {
            return userInfo[.phoneNumberUtility] as? () -> PhoneNumberUtility ?? PhoneNumberEncodingUtils.defaultUtility
        }
        set {
            userInfo[.phoneNumberUtility] = newValue
        }
    }
}

extension PhoneNumber: Codable {
    public init(from decoder: Decoder) throws {
        let strategy = decoder.userInfo[.phoneNumberDecodingStrategy] as? PhoneNumberDecodingStrategy ?? .default
        switch strategy {
        case .properties:
            let container = try decoder.container(keyedBy: CodingKeys.self)
            try self.init(
                numberString: container.decode(String.self, forKey: .numberString),
                countryCode: container.decode(UInt64.self, forKey: .countryCode),
                leadingZero: container.decode(Bool.self, forKey: .leadingZero),
                nationalNumber: container.decode(UInt64.self, forKey: .nationalNumber),
                numberExtension: container.decodeIfPresent(String.self, forKey: .numberExtension),
                type: container.decode(PhoneNumberType.self, forKey: .type),
                regionID: container.decodeIfPresent(String.self, forKey: .regionID)
            )
        case .e164:
            let container = try decoder.singleValueContainer()
            let e164String = try container.decode(String.self)
            let utility = decoder.userInfo[.phoneNumberUtility] as? () -> PhoneNumberUtility ?? PhoneNumberDecodingUtils.defaultUtility
            self = try utility().parse(e164String, ignoreType: true)
        }
    }

    public func encode(to encoder: Encoder) throws {
        let strategy = encoder.userInfo[.phoneNumberEncodingStrategy] as? PhoneNumberEncodingStrategy ?? .default
        switch strategy {
        case .properties:
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(numberString, forKey: .numberString)
            try container.encode(countryCode, forKey: .countryCode)
            try container.encode(leadingZero, forKey: .leadingZero)
            try container.encode(nationalNumber, forKey: .nationalNumber)
            try container.encode(numberExtension, forKey: .numberExtension)
            try container.encode(type, forKey: .type)
            try container.encode(regionID, forKey: .regionID)
        case .e164:
            var container = encoder.singleValueContainer()
            let utility = encoder.userInfo[.phoneNumberUtility] as? () -> PhoneNumberUtility ?? PhoneNumberEncodingUtils.defaultUtility
            let e164String = utility().format(self, toType: .e164)
            try container.encode(e164String)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case numberString
        case countryCode
        case leadingZero
        case nationalNumber
        case numberExtension
        case type
        case regionID
    }
}

extension CodingUserInfoKey {
    static let phoneNumberDecodingStrategy = Self(rawValue: "com.roymarmelstein.PhoneNumberKit.decoding-strategy")!
    static let phoneNumberEncodingStrategy = Self(rawValue: "com.roymarmelstein.PhoneNumberKit.encoding-strategy")!

    static let phoneNumberUtility = Self(rawValue: "com.roymarmelstein.PhoneNumberKit.instance")!
}
