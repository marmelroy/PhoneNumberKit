//
//  Constants.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 25/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Private Enums

enum PNCountryCodeSource {
    case NumberWithPlusSign
    case NumberWithIDD
    case NumberWithoutPlusSign
    case DefaultCountry
}

enum PNRegexError :  ErrorType {
    case General
}

enum PNValidationResult :  ErrorType {
    case Unknown
    case IsPossible
    case InvalidCountryCode
    case TooShort
    case TooLong
}

// MARK: Public Enums

public enum PNParsingError :  ErrorType {
    case NotANumber
    case TooLong
    case TooShort
    case InvalidCountryCode
}

public enum PNPhoneNumberType {
    case FixedLine
    case Mobile
    case TollFree
    case PremiumRate
    case SharedCost
    case VOIP
    case PersonalNumber
    case Pager
    case UAN
    case Voicemail
    case Unknown

}


// MARK: Constants

let PNMinLengthForNSN : Int = 2
let PNMaxInputStringLength : Int = 250
let PNMaxLengthCountryCode : Int = 3
let PNMaxLengthForNSN : Int = 16
let PNNonBreakingSpace : String = "\u{00a0}"
let PNPlusChars : String = "+＋"
let PNValidDigitsString : String = "0-9０-９٠-٩۰-۹"

// MARK: Patterns

let PNAllNormalizationMappings : [String: String] = ["0":"0", "1":"1", "2":"2", "3":"3", "4":"4", "5":"5", "6":"6", "7":"7", "8":"8", "9":"9", "\u{FF10}":"0", "\u{FF11}":"1", "\u{FF12}":"2", "\u{FF13}":"3", "\u{FF14}":"4", "\u{FF15}":"5", "\u{FF16}":"6", "\u{FF17}":"7", "\u{FF18}":"8", "\u{FF19}":"9", "\u{0660}":"0", "\u{0661}":"1", "\u{0662}":"2", "\u{0663}":"3", "\u{0664}":"4", "\u{0665}":"5", "\u{0666}":"6", "\u{0667}":"7", "\u{0668}":"8", "\u{0669}":"9", "\u{06F0}":"0", "\u{06F1}":"1", "\u{06F2}":"2", "\u{06F3}":"3", "\u{06F4}":"4", "\u{06F5}":"5", "\u{06F6}":"6", "\u{06F7}":"7", "\u{06F8}":"8", "\u{06F9}":"9", "A":"2", "B":"2", "C":"2", "D":"3", "E":"3", "F":"3", "G":"4", "H":"4", "I":"4", "J":"5", "K":"5", "L":"5", "M":"6", "N":"6", "O":"6", "P":"7", "Q":"7", "R":"7", "S":"7", "T":"8", "U":"8", "V":"8", "W":"9", "X":"9", "Y":"9", "Z":"9"]

let PNCapturingDigitPattern = "([0-9０-９٠-٩۰-۹])"

let PNExtnPattern = "(?:(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘX#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)$)$"

let PNLeadingPlusCharsPattern = "^[+＋]+"

let PNSecondNumberStartPattern = "[\\\\\\/] *x"

let PNUnwantedEndPattern = "[^0-9０-９٠-٩۰-۹A-Za-z#]+$"

let PNValidPhoneNumberPattern : String = "^[0-9０-９٠-٩۰-۹]{2}$|^[+＋]*(?:[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*]*[0-9０-９٠-٩۰-۹]){3,}[-x‐-―−ー－-／  ­​⁠　()（）［］.\\[\\]/~⁓∼～*A-Za-z0-9０-９٠-٩۰-۹]*(?:;ext=([0-9０-９٠-٩۰-۹]{1,7})|[  \\t,]*(?:e?xt(?:ensi(?:ó?|ó))?n?|ｅ?ｘｔｎ?|[,xｘ#＃~～]|int|anexo|ｉｎｔ)[:\\.．]?[  \\t,-]*([0-9０-９٠-٩۰-۹]{1,7})#?|[- ]+([0-9０-９٠-٩۰-۹]{1,5})#)?$"

let PNValidStartPattern = "[+＋0-9０-９٠-٩۰-۹]"
