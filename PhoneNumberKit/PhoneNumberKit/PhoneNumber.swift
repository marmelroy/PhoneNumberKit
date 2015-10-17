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
    init(rawNumber: String, defaultRegion: String) throws {
        self.rawNumber = rawNumber
        self.defaultRegion = defaultRegion
        
        if (rawNumber.isEmpty) {
            throw PNParsingError.NotANumber
        } else if (rawNumber.characters.count > PNMaxInputStringLength) {
            throw PNParsingError.TooLong
        }
        
        let parser = PhoneNumberParser()
        
        var nationalNumber = parser.extractPossibleNumber(rawNumber)
        if (!parser.isViablePhoneNumber(nationalNumber)) {
            throw PNParsingError.NotANumber
        }
        
        if (!parser.checkRegionForParsing(nationalNumber, defaultRegion: defaultRegion)) {
            throw PNParsingError.InvalidCountryCode
        }
        
        let extn = parser.maybeStripExtension(nationalNumber).extn
        if (extn != nil && extn?.characters.count > 0) {
            self.numberExtension = extn
            nationalNumber = parser.maybeStripExtension(nationalNumber).modifiedNumber
        }
        
        let regionMetaData =  PhoneNumberKit().metadata.filter { $0.codeID == defaultRegion}.first

        let countryCode = parser.maybeExtractCountryCode(nationalNumber, metadata: regionMetaData!)
        
        
//        /** @type {i18n.phonenumbers.PhoneMetadata} */
//        var regionMetadata = this.getMetadataForRegion(defaultRegion);
//        // Check to see if the number is given in international format so we know
//        // whether this number is from the default region or not.
//        /** @type {!goog.string.StringBuffer} */
//        var normalizedNationalNumber = new goog.string.StringBuffer();
//        /** @type {number} */
//        var countryCode = 0;
//        /** @type {string} */
//        var nationalNumberStr = nationalNumber.toString();
//        try {
//            countryCode = this.maybeExtractCountryCode(nationalNumberStr,
//                regionMetadata, normalizedNationalNumber, keepRawInput, phoneNumber);
//        } catch (e) {
//            if (e == i18n.phonenumbers.Error.INVALID_COUNTRY_CODE &&
//                i18n.phonenumbers.PhoneNumberUtil.LEADING_PLUS_CHARS_PATTERN_
//                    .test(nationalNumberStr)) {
//                        // Strip the plus-char, and try again.
//                        nationalNumberStr = nationalNumberStr.replace(
//                            i18n.phonenumbers.PhoneNumberUtil.LEADING_PLUS_CHARS_PATTERN_, '');
//                        countryCode = this.maybeExtractCountryCode(nationalNumberStr,
//                            regionMetadata, normalizedNationalNumber, keepRawInput, phoneNumber);
//                        if (countryCode == 0) {
//                            throw e;
//                        }
//            } else {
//                throw e;
//            }
//        }
//        if (countryCode != 0) {
//            /** @type {string} */
//            var phoneNumberRegion = this.getRegionCodeForCountryCode(countryCode);
//            if (phoneNumberRegion != defaultRegion) {
//                // Metadata cannot be null because the country calling code is valid.
//                regionMetadata = this.getMetadataForRegionOrCallingCode_(
//                    countryCode, phoneNumberRegion);
//            }
//        } else {
//            // If no extracted country calling code, use the region supplied instead.
//            // The national number is just the normalized version of the number we were
//            // given to parse.
//            i18n.phonenumbers.PhoneNumberUtil.normalizeSB_(nationalNumber);
//            normalizedNationalNumber.append(nationalNumber.toString());
//            if (defaultRegion != null) {
//                countryCode = regionMetadata.getCountryCodeOrDefault();
//                phoneNumber.setCountryCode(countryCode);
//            } else if (keepRawInput) {
//                phoneNumber.clearCountryCodeSource();
//            }
//        }
//        if (normalizedNationalNumber.getLength() <
//            i18n.phonenumbers.PhoneNumberUtil.MIN_LENGTH_FOR_NSN_) {
//                throw i18n.phonenumbers.Error.TOO_SHORT_NSN;
//        }
//        
//        if (regionMetadata != null) {
//            /** @type {!goog.string.StringBuffer} */
//            var carrierCode = new goog.string.StringBuffer();
//            /** @type {!goog.string.StringBuffer} */
//            var potentialNationalNumber =
//            new goog.string.StringBuffer(normalizedNationalNumber.toString());
//            this.maybeStripNationalPrefixAndCarrierCode(
//                potentialNationalNumber, regionMetadata, carrierCode);
//            if (!this.isShorterThanPossibleNormalNumber_(
//                regionMetadata, potentialNationalNumber.toString())) {
//                    normalizedNationalNumber = potentialNationalNumber;
//                    if (keepRawInput) {
//                        phoneNumber.setPreferredDomesticCarrierCode(carrierCode.toString());
//                    }
//            }
//        }
//        /** @type {string} */
//        var normalizedNationalNumberStr = normalizedNationalNumber.toString();
//        /** @type {number} */
//        var lengthOfNationalNumber = normalizedNationalNumberStr.length;
//        if (lengthOfNationalNumber <
//            i18n.phonenumbers.PhoneNumberUtil.MIN_LENGTH_FOR_NSN_) {
//                throw i18n.phonenumbers.Error.TOO_SHORT_NSN;
//        }
//        if (lengthOfNationalNumber >
//            i18n.phonenumbers.PhoneNumberUtil.MAX_LENGTH_FOR_NSN_) {
//                throw i18n.phonenumbers.Error.TOO_LONG;
//        }
//        this.setItalianLeadingZerosForPhoneNumber_(
//            normalizedNationalNumberStr, phoneNumber);
//        phoneNumber.setNationalNumber(parseInt(normalizedNationalNumberStr, 10));
//        return phoneNumber;

    }
}


