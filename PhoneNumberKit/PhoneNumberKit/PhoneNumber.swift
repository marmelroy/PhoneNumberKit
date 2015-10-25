//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation


public struct PhoneNumber {
    var rawNumber: String
    var countryCode: UInt?
    var nationalNumber: UInt?
    var numberExtension: String?
}

extension PhoneNumber {
    init(let rawNumber: String, defaultRegion: String) throws {
        self.rawNumber = rawNumber
        
        if (rawNumber.isEmpty) {
            throw PNParsingError.NotANumber
        } else if (rawNumber.characters.count > PNMaxInputStringLength) {
            throw PNParsingError.TooLong
        }
        
        let parser = PhoneNumberParser()
        
        var nationalNumber = parser.extractPossibleNumber(rawNumber)
        if (!parser.isViablePhoneNumber(nationalNumber as String)) {
            throw PNParsingError.NotANumber
        }
        
        if (!parser.checkRegionForParsing(nationalNumber as String, defaultRegion: defaultRegion)) {
            throw PNParsingError.InvalidCountryCode
        }
        
        let extn = parser.maybeStripExtension(&nationalNumber)
        if (extn != nil && extn?.length > 0) {
            self.numberExtension = extn as? String
        }
        
        var regionMetaData =  PhoneNumberKit().metadata.filter { $0.codeID == defaultRegion}.first
        var countryCode : UInt = 0
        do {
            countryCode = try parser.maybeExtractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
            self.countryCode = countryCode
        } catch {
            do {
                let plusRemovedNumebrString = replaceStringByRegex(nationalNumber, pattern: PNLeadingPlusCharsPattern)
                countryCode = try parser.maybeExtractCountryCode(plusRemovedNumebrString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
                self.countryCode = countryCode
            } catch {
            }
        }
        if (countryCode != 0) {
            let region = PhoneNumberKit().countriesForCode(countryCode).first
            if (region != defaultRegion) {
                regionMetaData = PhoneNumberKit().metadata.filter { $0.codeID == region}.first
            }
        }
        else {
            self.countryCode = regionMetaData?.countryCode
        }
        
        if (nationalNumber.length <
            PNMinLengthForNSN) {
            throw PNParsingError.TooShort
        }
        if (nationalNumber.length > PNMaxLengthForNSN) {
            throw PNParsingError.TooLong
        }
        let normalizedNationalNumber = parser.normalizePhoneNumber(nationalNumber as String)
        self.nationalNumber = UInt(normalizedNationalNumber)
        
    }
}


