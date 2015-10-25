//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public enum PNCountryCodeSource {
    case NumberWithPlusSign
    case NumberWithIDD
    case NumberWithoutPlusSign
    case DefaultCountry
}

public struct PhoneNumber {
    var rawNumber: String
    var defaultRegion: String
    var countryCode: UInt?
    var nationalNumber: UInt?
    var numberExtension: String?
//    var italianLeadingZero: Bool?
//    var leadingZerosNumber: Int?
    var countryCodeSource: PNCountryCodeSource?
//    var preferredDomesticCarrierCode: String?
}


extension PhoneNumber {
    init(let rawNumber: String, defaultRegion: String) throws {
        self.rawNumber = rawNumber
        self.defaultRegion = defaultRegion
        
        if (rawNumber.isEmpty) {
            throw PNParsingError.NotANumber
        } else if (rawNumber.characters.count > PNMaxInputStringLength) {
            throw PNParsingError.TooLong
        }
        
        let parser = PhoneNumberParser()
        
        let nationalNumber = parser.extractPossibleNumber(rawNumber)
        if (!parser.isViablePhoneNumber(nationalNumber)) {
            throw PNParsingError.NotANumber
        }
        
        if (!parser.checkRegionForParsing(nationalNumber, defaultRegion: defaultRegion)) {
            throw PNParsingError.InvalidCountryCode
        }
        
        var regexNationalNumber : NSString = nationalNumber as NSString
        
        let extn = parser.maybeStripExtension(&regexNationalNumber)
        if (extn != nil && extn?.length > 0) {
            self.numberExtension = extn as? String
        }
        
        var regionMetaData =  PhoneNumberKit().metadata.filter { $0.codeID == defaultRegion}.first
        var countryCode : UInt = 0
        do {
            countryCode = try parser.maybeExtractCountryCode(regexNationalNumber, nationalNumber: &regexNationalNumber, metadata: regionMetaData!)
            self.countryCode = countryCode
        } catch {
            do {
                let plusRemovedNumebrString = replaceStringByRegex(regexNationalNumber, pattern: PNLeadingPlusCharsPattern)
                countryCode = try parser.maybeExtractCountryCode(plusRemovedNumebrString, nationalNumber: &regexNationalNumber, metadata: regionMetaData!)
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
        print(regexNationalNumber)
    }
}


