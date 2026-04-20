//
//  Constants.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 25/10/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Private Enums

enum PhoneNumberCountryCodeSource {
    case numberWithPlusSign
    case numberWithIDD
    case numberWithoutPlusSign
    case defaultCountry
}

// MARK: Public Enums

/// An error type representing failures that may occur during phone number parsing or validation.
public enum PhoneNumberError: Error, Equatable, Sendable {
    /// A general or unknown error occurred.
    case generalError
    /// The provided country code is missing or invalid.
    case invalidCountryCode
    /// The provided input is not a valid number.
    case invalidNumber
    /// The input number is too long to be considered valid.
    case tooLong
    /// The input number is too short to be considered valid.
    case tooShort
    /// A deprecated method was used and is no longer supported.
    case deprecated
    /// Required metadata could not be found during parsing.
    case metadataNotFound
    /// The input could be interpreted as more than one valid phone number.
    case ambiguousNumber(phoneNumbers: Set<PhoneNumber>)
}

extension PhoneNumberError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .generalError: return NSLocalizedString("An error occurred while validating the phone number.", comment: "")
        case .invalidCountryCode: return NSLocalizedString("The country code is invalid.", comment: "")
        case .invalidNumber: return NSLocalizedString("The number provided is invalid.", comment: "")
        case .tooLong: return NSLocalizedString("The number provided is too long.", comment: "")
        case .tooShort: return NSLocalizedString("The number provided is too short.", comment: "")
        case .deprecated: return NSLocalizedString("This function is deprecated.", comment: "")
        case .metadataNotFound: return NSLocalizedString("Valid metadata is missing.", comment: "")
        case .ambiguousNumber: return NSLocalizedString("Phone number is ambiguous.", comment: "")
        }
    }
}

/// Formatting options for displaying a phone number.
public enum PhoneNumberFormat: String, Codable, Sendable {
    /// Format: +33689123456
    case e164
    /// Format: +33 6 89 12 34 56
    case international
    /// Format: 06 89 12 34 56
    case national
}

/// The type of a phone number, determined after parsing.
public enum PhoneNumberType: String, Codable, Sendable {
    /// A fixed line (landline) number.
    case fixedLine
    /// A mobile number.
    case mobile
    /// A number that could be either fixed line or mobile.
    case fixedOrMobile
    /// A pager number.
    case pager
    /// A personal number assigned to a person (not a device).
    case personalNumber
    /// A premium-rate number.
    case premiumRate
    /// A shared-cost number.
    case sharedCost
    /// A toll-free number.
    case tollFree
    /// A voicemail number.
    case voicemail
    /// A voice-over-IP (VoIP) number.
    case voip
    /// A UAN (Universal Access Number).
    case uan
    /// A number that could not be classified.
    case unknown
    /// The number has not been parsed and its type is unknown.
    case notParsed
}

/// Indicates the scope or context in which a number length is valid.
public enum PossibleLengthType: String, Codable, Sendable {
    /// The number length is valid for national dialing.
    case national
    /// The number length is valid only for local dialing.
    case localOnly
}

// MARK: Constants

enum PhoneNumberConstants {
    static let defaultCountry = "US"
    static let defaultExtnPrefix = " ext. "
    static let longPhoneNumber = "999999999999999"
    static let minLengthForNSN = 2
    static let maxInputStringLength = 250
    static let maxLengthCountryCode = 3
    static let maxLengthForNSN = 16
    static let nonBreakingSpace = "\u{00a0}"
    static let plusChars = "+＋"
    static let pausesAndWaitsChars = ",;"
    static let operatorChars = "*#"
    static let validDigitsString = "0-9０-９٠-٩۰-۹"
    static let digitPlaceholder = "\u{2008}"
    static let separatorBeforeNationalNumber = " "
}

enum PhoneNumberPatterns {
    // MARK: Patterns

    static let firstGroupPattern = "(\\$\\d)"
    static let fgPattern = "\\$FG"
    static let npPattern = "\\$NP"

    static let allNormalizationMappings = ["0": "0", "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9", "٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4", "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9", "۰": "0", "۱": "1", "۲": "2", "۳": "3", "۴": "4", "۵": "5", "۶": "6", "۷": "7", "۸": "8", "۹": "9", "*": "*", "#": "#", ",": ",", ";": ";"]
    static let capturingDigitPattern = "([0-9０-９٠-٩۰-۹])"

    static let extnPattern = "(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～;]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)$"

    static let iddPattern = "^(?:\\+|%@)"

    static let formatPattern = "^(?:%@)$"

    static let characterClassPattern = "\\[([^\\[\\]])*\\]"

    static let standaloneDigitPattern = "\\d(?=[^,}][^,}])"

    static let nationalPrefixParsingPattern = "^(?:%@)"

    static let prefixSeparatorPattern = "[- ]"

    static let eligibleAsYouTypePattern = "^[-x‐-―−ー－-／ ­​⁠　()（）［］.\\[\\]/~⁓∼～]*(\\$\\d[-x‐-―−ー－-／ ­​⁠　()（）［］.\\[\\]/~⁓∼～]*)+$"

    static let leadingPlusCharsPattern = "^[+＋]+"

    static let secondNumberStartPattern = "[\\\\\\/] *x"

    static let unwantedEndPattern = "[^0-9０-９٠-٩۰-۹A-Za-z#]+$"

    static let validStartPattern = "[+＋0-9０-９٠-٩۰-۹]"

    static let validPhoneNumberPattern = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*]*[0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]){3,}[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*A-Za-z0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]*(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～;]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$)?[,;]*$"

    static let countryCodePattern = "^[a-zA-Z]{2}$"
}
