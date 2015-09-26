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

public class PhoneNumberParser: NSObject {

    // MARK: PARSER

    public func parse(rawNumber: String, defaultRegion: String) -> PhoneNumber {
        let numberToParse = normalizeNonBreakingSpace(rawNumber)
        let nationalNumber = buildNationalNumber(numberToParse)
    }
    
    func buildNationalNumber(numberToParse: String) -> String {
        var nationalNumber : String = ""
        nationalNumber =  nationalNumber.stringByAppendingString("") [(*nationalNumber) stringByAppendingString:[self extractPossibleNumber:numberToParse]];

        return nationalNumber
    }

    
    // MARK: HELPERS

    func normalizeNonBreakingSpace(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }
    
    func extractPossibleNumber(string: String) -> String {
        let start
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }

    func stringPositionByRegex(source: String, pattern: String) -> Int {

    }

    
}

