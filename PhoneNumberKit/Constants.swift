//
//  Constants.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 25/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
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

/**
Enumeration for parsing error types

- GeneralError: A general error occured.
- InvalidCountryCode: A country code could not be found or the one found was invalid
- NotANumber: The string provided is not a number
- TooLong: The string provided is too long to be a valid number
- TooShort: The string provided is too short to be a valid number
- Deprecated: The method used was deprecated
- metadataNotFound: PhoneNumberKit was unable to read the included metadata
*/
public enum PhoneNumberError: Error {
    case generalError
    case invalidCountryCode
    case notANumber
    case unknownType
    case tooLong
    case tooShort
    case deprecated
    case metadataNotFound
}

extension PhoneNumberError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .generalError: return NSLocalizedString("An error occured whilst validating the phone number.", comment: "")
        case .invalidCountryCode: return NSLocalizedString("The country code is invalid.", comment: "")
        case .notANumber: return NSLocalizedString("The number provided is invalid.", comment: "")
        case .unknownType: return NSLocalizedString("Phone number type is unknown.", comment: "")
        case .tooLong: return NSLocalizedString("The number provided is too long.", comment: "")
        case .tooShort: return NSLocalizedString("The number provided is too short.", comment: "")
        case .deprecated: return NSLocalizedString("This function is deprecated.", comment: "")
        case .metadataNotFound: return NSLocalizedString("Valid metadata is missing.", comment: "")
        }
    }

}

public enum PhoneNumberFormat {
    case e164 // +33689123456
    case international // +33 6 89 12 34 56
    case national // 06 89 12 34 56
}

/**
 Phone number type enumeration
 - fixedLine: Fixed line numbers
 - mobile: Mobile numbers
 - fixedOrMobile: Either fixed or mobile numbers if we can't tell conclusively.
 - pager: Pager numbers
 - personalNumber: Personal number numbers
 - premiumRate: Premium rate numbers
 - sharedCost: Shared cost numbers
 - tollFree: Toll free numbers
 - voicemail: Voice mail numbers
 - vOIP: Voip numbers
 - uan: UAN numbers
 - unknown: Unknown number type
 */
public enum PhoneNumberType: String, Codable {
    case fixedLine
    case mobile
    case fixedOrMobile
    case pager
    case personalNumber
    case premiumRate
    case sharedCost
    case tollFree
    case voicemail
    case voip
    case uan
    case unknown
    case notParsed
}

// MARK: Constants

struct PhoneNumberConstants {
  static let defaultCountry = "US"
  static let defaultExtnPrefix = " ext. "
  static let longPhoneNumber = "999999999999999"
  static let minLengthForNSN = 2
  static let maxInputStringLength = 250
  static let maxLengthCountryCode = 3
  static let maxLengthForNSN = 16
  static let nonBreakingSpace = "\u{00a0}"
  static let plusChars = "+＋"
  static let validDigitsString = "0-9０-９٠-٩۰-۹"
  static let digitPlaceholder = "\u{2008}"
  static let separatorBeforeNationalNumber = " "
}

struct PhoneNumberPatterns {
  // MARK: Patterns

  static let firstGroupPattern = "(\\$\\d)"
  static let fgPattern = "\\$FG"
  static let npPattern = "\\$NP"

  static let allNormalizationMappings = ["0": "0", "1": "1", "2": "2", "3": "3", "4": "4", "5": "5", "6": "6", "7": "7", "8": "8", "9": "9"]

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

  static let validPhoneNumberPattern = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*]*[0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]){3,}[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*A-Za-z0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]*(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～;]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$)?$"
}
