//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
 Manager for parsing flow.
 */
final class ParseManager {
    weak var metadataManager: MetadataManager?
    let parser: PhoneNumberParser
    weak var regexManager: RegexManager?

    init(metadataManager: MetadataManager, regexManager: RegexManager) {
        self.metadataManager = metadataManager
        self.parser = PhoneNumberParser(regex: regexManager, metadata: metadataManager)
        self.regexManager = regexManager
    }

    /**
     Parse a string into a phone number object with a custom region. Can throw.
     - Parameter numberString: String to be parsed to phone number struct.
     - Parameter region: ISO 3166 compliant region code.
     - parameter ignoreType:   Avoids number type checking for faster performance.
     */
    func parse(_ numberString: String, withRegion region: String, ignoreType: Bool) throws -> PhoneNumber {
        guard let metadataManager = metadataManager, let regexManager = regexManager else { throw PhoneNumberError.generalError }
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercased()
        // Extract number (2)
        var nationalNumber = numberString
        let match = try regexManager.phoneDataDetectorMatch(numberString)
        let matchedNumber = nationalNumber.substring(with: match.range)
        // Replace Arabic and Persian numerals and let the rest unchanged
        nationalNumber = regexManager.stringByReplacingOccurrences(matchedNumber, map: PhoneNumberPatterns.allNormalizationMappings, keepUnmapped: true)

        // Strip and extract extension (3)
        var numberExtension: String?
        if let rawExtension = parser.stripExtension(&nationalNumber) {
            numberExtension = self.parser.normalizePhoneNumber(rawExtension)
        }
        // Country code parse (4)
        guard var regionMetadata = metadataManager.filterTerritories(byCountry: region) else {
            throw PhoneNumberError.invalidCountryCode
        }
        let countryCode: UInt64
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetadata)
        } catch {
            let plusRemovedNumberString = regexManager.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: nationalNumber as String)
            countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetadata)
        }

        // Normalized number (5)
        nationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        if countryCode == 0 {
            if let result = try validPhoneNumber(from: nationalNumber, using: regionMetadata, countryCode: regionMetadata.countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
                return result
            }
            throw PhoneNumberError.invalidNumber
        }
        
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetadata.countryCode, let countryMetadata = metadataManager.mainTerritory(forCode: countryCode) {
            regionMetadata = countryMetadata
        }

        if let result = try validPhoneNumber(from: nationalNumber, using: regionMetadata, countryCode: countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
            return result
        }

        // If everything fails, iterate through other territories with the same country code (7)
        var possibleResults: Set<PhoneNumber> = []
        if let metadataList = metadataManager.filterTerritories(byCode: countryCode) {
            for metadata in metadataList where regionMetadata.codeID != metadata.codeID {
                if let result = try validPhoneNumber(from: nationalNumber, using: metadata, countryCode: countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
                    possibleResults.insert(result)
                }
            }
        }
        
        switch possibleResults.count {
        case 0: throw PhoneNumberError.invalidNumber
        case 1: return possibleResults.first!
        default: throw PhoneNumberError.ambiguousNumber(phoneNumbers: possibleResults)
        }
    }

    // Parse task

    /**
     Fastest way to parse an array of phone numbers. Uses custom region code.
     - Parameter numberStrings: An array of raw number strings.
     - Parameter region: ISO 3166 compliant region code.
     - parameter ignoreType: Avoids number type checking for faster performance.
     - Returns: An array of valid PhoneNumber objects.
     */
    func parseMultiple(_ numberStrings: [String], withRegion region: String, ignoreType: Bool, shouldReturnFailedEmptyNumbers: Bool = false) -> [PhoneNumber] {
        var hasError = false
        
        var multiParseArray = [PhoneNumber](unsafeUninitializedCapacity: numberStrings.count) { buffer, initializedCount in
            DispatchQueue.concurrentPerform(iterations: numberStrings.count) { index in
                let numberString = numberStrings[index]
                do {
                    let phoneNumber = try self.parse(numberString, withRegion: region, ignoreType: ignoreType)
                    buffer.baseAddress!.advanced(by: index).initialize(to: phoneNumber)
                } catch {
                    buffer.baseAddress!.advanced(by: index).initialize(to: PhoneNumber.notPhoneNumber())
                    hasError = true
                }
            }
            initializedCount = numberStrings.count
        }

        if hasError && !shouldReturnFailedEmptyNumbers {
            multiParseArray = multiParseArray.filter { $0.type != .notParsed }
        }

        return multiParseArray
    }

    /// Get correct ISO 3166 compliant region code for a number.
    ///
    /// - Parameters:
    ///   - nationalNumber: national number.
    ///   - countryCode: country code.
    ///   - leadingZero: whether or not the number has a leading zero.
    /// - Returns: ISO 3166 compliant region code.
    func getRegionCode(of nationalNumber: UInt64, countryCode: UInt64, leadingZero: Bool) -> String? {
        guard let regexManager = regexManager, let metadataManager = metadataManager, let regions = metadataManager.filterTerritories(byCode: countryCode) else { return nil }

        if regions.count == 1 {
            return regions[0].codeID
        }

        let nationalNumberString = String(nationalNumber)
        for region in regions {
            if let leadingDigits = region.leadingDigits {
                if regexManager.matchesAtStart(leadingDigits, string: nationalNumberString) {
                    return region.codeID
                }
            }
            if leadingZero, self.parser.checkNumberType("0" + nationalNumberString, metadata: region) != .unknown {
                return region.codeID
            }
            if self.parser.checkNumberType(nationalNumberString, metadata: region) != .unknown {
                return region.codeID
            }
        }
        return nil
    }

    //MARK: Internal method


    /// Creates a valid phone number given a specifc region metadata, used internally by the parse function
    private func validPhoneNumber(from nationalNumber: String, using regionMetadata: MetadataTerritory, countryCode: UInt64, ignoreType: Bool, numberString: String, numberExtension: String?) throws -> PhoneNumber? {
        guard let metadataManager = metadataManager, let regexManager = regexManager else { throw PhoneNumberError.generalError }

        var nationalNumber = nationalNumber
        var regionMetadata = regionMetadata

        // National Prefix Strip (1)
        self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetadata)

        // Test number against general number description for correct metadata (2)
        if let generalNumberDesc = regionMetadata.generalDesc,
            regexManager.hasValue(generalNumberDesc.nationalNumberPattern) == false || parser.isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false {
            return nil
        }
        // Finalize remaining parameters and create phone number object (3)
        let leadingZero = nationalNumber.hasPrefix("0")
        guard let finalNationalNumber = UInt64(nationalNumber) else {
            throw PhoneNumberError.invalidNumber
        }

        // Check if the number if of a known type (4)
        var type: PhoneNumberType = .unknown
        if ignoreType == false {
            if let regionCode = getRegionCode(of: finalNationalNumber, countryCode: countryCode, leadingZero: leadingZero), let foundMetadata = metadataManager.filterTerritories(byCountry: regionCode){
                regionMetadata = foundMetadata
            }
            type = self.parser.checkNumberType(String(nationalNumber), metadata: regionMetadata, leadingZero: leadingZero)
            if type == .unknown {
                throw PhoneNumberError.invalidNumber
            }
        }

        return PhoneNumber(numberString: numberString, countryCode: countryCode, leadingZero: leadingZero, nationalNumber: finalNationalNumber, numberExtension: numberExtension, type: type, regionID: regionMetadata.codeID)
    }

}
