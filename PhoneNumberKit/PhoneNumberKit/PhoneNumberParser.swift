//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

let PNNonBreakingSpace : String = "\u{00a0}"
let PNPlusChars : String = "+＋"
let PNValidDigitsString : String = "0-9０-９٠-٩۰-۹"
let PNRegionCodeForNonGeoEntity : String = "001"

let RFC3966_EXTN_PREFIX = ";ext="
let RFC3966_PREFIX = "tel:"
let RFC3966_PHONE_CONTEXT = ";phone-context="
let RFC3966_ISDN_SUBADDRESS = ";isub="


public class PhoneNumberParser: NSObject {

    // MARK: PARSER

    public func parse(rawNumber: String, defaultRegion: String) -> PhoneNumber {
        let numberToParse = normalizeNonBreakingSpace(rawNumber)
        let nationalNumber = buildNationalNumber(numberToParse)
    }
    
    func buildNationalNumber(numberToParse: String) -> String {
        
        let indexOfPhoneContent = self.inde
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }

    
    // MARK: HELPERS

    func normalizeNonBreakingSpace(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }
    
    func indexOfStringInString(source: String, target: String) -> Int {
        let stringRange = source.rangeOfString(target)
        if (stringRange!.isEmpty) {
            return -1
        }
        else {
            return stringRange!.startIndex as Int
        }
    }
    
}

