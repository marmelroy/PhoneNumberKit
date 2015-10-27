//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public struct PhoneNumber {
    private(set) public var countryCode: UInt64
    private(set) public var nationalNumber: UInt64
    private(set) public var numberExtension: String?
    private(set) public var rawNumber: String
    private(set) public var leadingZero: Bool
    private(set) public var type: PNPhoneNumberType
}

public extension PhoneNumber {
    
    // Parse on init
    public init(rawNumber: String) throws {
        let parser = PhoneNumberParser()
        let phoneNumberKit = PhoneNumberKit.sharedInstance
        let defaultRegion = phoneNumberKit.defaultRegionCode()
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
        var regionMetaData =  phoneNumberKit.metadata.filter { $0.codeID == defaultRegion}.first
        var countryCode : UInt64 = 0
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
        
        // Length Validations
        var normalizedNationalNumber = parser.normalizePhoneNumber(nationalNumber as String)
        if (normalizedNationalNumber.characters.count <=
            PNMinLengthForNSN) {
            throw PNParsingError.TooShort
        }
        if (normalizedNationalNumber.characters.count >= PNMaxLengthForNSN) {
            throw PNParsingError.TooLong
        }
        
        // Regex validations
        if (self.countryCode != regionMetaData!.countryCode) {
            let country = phoneNumberKit.countriesForCode(countryCode).first
            if  (country == nil) {
                throw PNParsingError.NotANumber
            }
            regionMetaData =  phoneNumberKit.metadata.filter { $0.codeID == country}.first
        }
        
        // Carrier Code
        var carrierCode : NSString = NSString()
        parser.stripNationalPrefixAndCarrierCode(&normalizedNationalNumber, metadata: regionMetaData!, carrierCode: &carrierCode)
        
        self.type = parser.extractNumberType(normalizedNationalNumber, metadata: regionMetaData!)
        if (self.type == PNPhoneNumberType.Unknown) {
            throw PNParsingError.NotANumber
        }
        self.leadingZero = normalizedNationalNumber.hasPrefix("0")
        self.nationalNumber = UInt64(normalizedNationalNumber)!
    }
    
    private func adjustedNationalNumber() -> String {
        if (self.leadingZero) {
            return "0" + String(nationalNumber)
        }
        else {
            return String(nationalNumber)
        }
    }
    
    // Format to E164 format (e.g. +33689123456)
    public func toE164() -> String {
        let formattedNumber : String = "+" + String(countryCode) + adjustedNationalNumber()
        return formattedNumber
    }
    
    // Format to International format (e.g. +33 689123456)
    public func toInternational() -> String {
        let formattedNumber : String = "+" + String(countryCode) + " " + adjustedNationalNumber()
        return formattedNumber
    }
    
    // Format to actionable RFC format (e.g. tel:+33-689123456)
    public func toRFC3966() -> String {
        let formattedNumber : String = "tel:+" + String(countryCode) + "-" + adjustedNationalNumber()
        return formattedNumber
    }

    // Format to local national format (e.g. 0689123456)
    public func toNational() -> String {
        let formattedNumber : String = "0" + String(nationalNumber)
        return formattedNumber
    }
    


}


