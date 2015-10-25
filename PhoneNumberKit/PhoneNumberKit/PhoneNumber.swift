//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public struct PhoneNumber {
    public let rawNumber: String
    public var countryCode: UInt
    public var nationalNumber: UInt
    public var numberExtension: String?
}

extension PhoneNumber {
    
    // Parse on init
    init(let rawNumber: String, defaultRegion: String) throws {
        let parser = PhoneNumberParser()
        self.rawNumber = rawNumber
        
        // Validations
        if (rawNumber.isEmpty) {
            throw PNParsingError.NotANumber
        } else if (rawNumber.characters.count > PNMaxInputStringLength) {
            throw PNParsingError.TooLong
        }
        var nationalNumber = parser.extractPossibleNumber(rawNumber)
        
        if (!parser.isViablePhoneNumber(nationalNumber)) {
            throw PNParsingError.NotANumber
        }
        if (!parser.checkRegionForParsing(nationalNumber, defaultRegion: defaultRegion)) {
            throw PNParsingError.InvalidCountryCode
        }
        
        // Extension parsing
        let extn = parser.stripExtension(&nationalNumber)
        if (extn != nil && extn?.characters.count > 0) {
            self.numberExtension = extn
        }
        
        // Country code parsing
        let regionMetaData =  PhoneNumberKit().metadata.filter { $0.codeID == defaultRegion}.first
        var countryCode : UInt = 0
        do {
            countryCode = try parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
            self.countryCode = countryCode
        } catch {
            do {
                let plusRemovedNumebrString = replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try parser.extractCountryCode(plusRemovedNumebrString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
                self.countryCode = countryCode
            } catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if (countryCode == 0) {
            self.countryCode = regionMetaData!.countryCode
        }
        
        // Final Validations
        let normalizedNationalNumber = parser.normalizePhoneNumber(nationalNumber as String)
        if (normalizedNationalNumber.characters.count <
            PNMinLengthForNSN) {
            throw PNParsingError.TooShort
        }
        if (normalizedNationalNumber.characters.count > PNMaxLengthForNSN) {
            throw PNParsingError.TooLong
        }
        
        self.nationalNumber = UInt(normalizedNationalNumber)!
    }
    
    // Format to E164 format (e.g. +33689123456)
    public func toE164() -> String {
        let formattedNumber : String = "+" + String(countryCode) + String(nationalNumber)
        return formattedNumber
    }
    
    // Format to International format (e.g. +33 689123456)
    public func toInternational() -> String {
        let formattedNumber : String = "+" + String(countryCode) + " " + String(nationalNumber)
        return formattedNumber
    }
    
    // Format to actionable RFC format (e.g. tel:+33-689123456)
    public func toRFC3966() -> String {
        let formattedNumber : String = "tel:+" + String(countryCode) + "-" + String(nationalNumber)
        return formattedNumber
    }

    // Format to local national format (e.g. 0689123456)
    public func toNational() -> String {
        let formattedNumber : String = "0" + String(nationalNumber)
        return formattedNumber
    }

}


