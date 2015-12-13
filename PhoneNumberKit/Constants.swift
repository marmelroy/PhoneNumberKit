//
//  Constants.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 25/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Private Enums

enum PhoneNumberFormat {
    case E164
    case International
    case National
}

enum PhoneNumberCountryCodeSource {
    case NumberWithPlusSign
    case NumberWithIDD
    case NumberWithoutPlusSign
    case DefaultCountry
}

// MARK: Public Enums

/**
Enumeration for parsing error types

- GeneralError: A general error occured.
- InvalidCountryCode: A country code could not be found or the one found was invalid
- NotANumber: The string provided is not a number
- TooLong: The string provided is too long to be a valid number
- TooShort: The string provided is too short to be a valid number
*/
public enum PhoneNumberError: ErrorType {
    case GeneralError
    case InvalidCountryCode
    case NotANumber
    case TooLong
    case TooShort
    
    public var description: String {
        switch self {
        case .GeneralError: return NSLocalizedString("An error occured whilst validating the phone number.", comment: "")
        case .InvalidCountryCode: return NSLocalizedString("The country code is invalid.", comment: "")
        case .NotANumber: return NSLocalizedString("The number provided is invalid.", comment: "")
        case .TooLong: return NSLocalizedString("The number provided is too long.", comment: "")
        case .TooShort: return NSLocalizedString("The number provided is too show.", comment: "")
        }
    }
}

/**
 Phone number type enumeration
 - FixedLine: Fixed line numbers
 - Mobile: Mobile numbers
 - FixedOrMobile: Either fixed or mobile numbers if we can't tell conclusively.
 - Pager: Pager numbers
 - PersonalNumber: Personal number numbers
 - PremiumRate: Premium rate numbers
 - SharedCost: Shared cost numbers
 - TollFree: Toll free numbers
 - Voicemail: Voice mail numbers
 - VOIP: Voip numbers
 - UAN: UAN numbers
 - Unknown: Unknown number type
 */
public enum PhoneNumberType {
    case FixedLine
    case Mobile
    case FixedOrMobile
    case Pager
    case PersonalNumber
    case PremiumRate
    case SharedCost
    case TollFree
    case Voicemail
    case VOIP
    case UAN
    case Unknown
}

// MARK: Constants

let minLengthForNSN = 2
let maxInputStringLength = 250
let maxLengthCountryCode = 3
let maxLengthForNSN = 16
let nonBreakingSpace = "\u{00a0}"
let plusChars = "+＋"
let validDigitsString = "0-9０-９٠-٩۰-۹"
let defaultCountry = "US"
let defaultExtnPrefix = " ext. "
let firstGroupPattern = "(\\$\\d)"
let npPattern = "\\$NP"
let fgPattern = "\\$FG"

// MARK: Patterns

let allNormalizationMappings = ["0":"0", "1":"1", "2":"2", "3":"3", "4":"4", "5":"5", "6":"6", "7":"7", "8":"8", "9":"9", "\u{FF10}":"0", "\u{FF11}":"1", "\u{FF12}":"2", "\u{FF13}":"3", "\u{FF14}":"4", "\u{FF15}":"5", "\u{FF16}":"6", "\u{FF17}":"7", "\u{FF18}":"8", "\u{FF19}":"9", "\u{0660}":"0", "\u{0661}":"1", "\u{0662}":"2", "\u{0663}":"3", "\u{0664}":"4", "\u{0665}":"5", "\u{0666}":"6", "\u{0667}":"7", "\u{0668}":"8", "\u{0669}":"9", "\u{06F0}":"0", "\u{06F1}":"1", "\u{06F2}":"2", "\u{06F3}":"3", "\u{06F4}":"4", "\u{06F5}":"5", "\u{06F6}":"6", "\u{06F7}":"7", "\u{06F8}":"8", "\u{06F9}":"9"]

let capturingDigitPattern = "([0-9０-９٠-٩۰-۹])"

let extnPattern = "\\;(.*)"

let leadingPlusCharsPattern = "^[+＋]+"

let secondNumberStartPattern = "[\\\\\\/] *x"

let unwantedEndPattern = "[^0-9０-９٠-٩۰-۹A-Za-z#]+$"

let validStartPattern = "[+＋0-9０-９٠-٩۰-۹]"

let validPhoneNumberPattern = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*]*[0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]){3,}[-x\u{2010}-\u{2015}\u{2212}\u{30FC}\u{FF0D}-\u{FF0F} \u{00A0}\u{00AD}\u{200B}\u{2060}\u{3000}()\u{FF08}\u{FF09}\u{FF3B}\u{FF3D}.\\[\\]/~\u{2053}\u{223C}\u{FF5E}*A-Za-z0-9\u{FF10}-\u{FF19}\u{0660}-\u{0669}\u{06F0}-\u{06F9}]*(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$)?$"
