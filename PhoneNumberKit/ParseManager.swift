//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

/// Manager for parsing flow.
final class ParseManager {
    weak var metadataManager: MetadataManager?
    let parser: PhoneNumberParser
    weak var regexManager: RegexManager?

    init(metadataManager: MetadataManager, regexManager: RegexManager) {
        self.metadataManager = metadataManager
        self.parser = PhoneNumberParser(regex: regexManager, metadata: metadataManager)
        self.regexManager = regexManager
    }

    /// Parse a string into a phone number object with a custom region. Can throw.
    /// - Parameter numberString: String to be parsed to phone number struct.
    /// - Parameter region: ISO 3166 compliant region code.
    /// - parameter ignoreType:   Avoids number type checking for faster performance.
    func parse(_ numberString: String, withRegion region: String, ignoreType: Bool) throws -> PhoneNumber {
        guard let metadataManager = metadataManager, let regexManager = regexManager else { throw PhoneNumberError.generalError }
        
        // STEP 1: Normalize region code
        // Ensure region is uppercase to match metadata keys (e.g., "us" -> "US")
        let region = region.uppercased()
        
        // STEP 2: Extract and normalize the phone number
        // Find the actual phone number within the input string using data detector
        var nationalNumber = numberString
        let match = try regexManager.phoneDataDetectorMatch(numberString)
        let matchedNumber = nationalNumber.substring(with: match.range)
        
        // Normalize digits by replacing Arabic and Persian numerals with standard digits
        // while keeping other characters unchanged for further processing
        nationalNumber = regexManager.stringByReplacingOccurrences(matchedNumber, map: PhoneNumberPatterns.allNormalizationMappings, keepUnmapped: true)

        // STEP 3: Handle phone number extensions
        // Extract and normalize any extension (e.g., "ext 123", "x123") from the number
        var numberExtension: String?
        if let rawExtension = parser.stripExtension(&nationalNumber) {
            numberExtension = self.parser.normalizePhoneNumber(rawExtension)
        }
        
        // STEP 4: Extract country code from the number
        // Get metadata for the specified region and attempt to extract country code
        guard var regionMetadata = metadataManager.filterTerritories(byCountry: region) else {
            throw PhoneNumberError.invalidCountryCode
        }
        
        let countryCode: UInt64
        do {
            // Try to extract country code normally
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetadata)
        } catch {
            // Fallback: Remove any leading plus signs and try again
            // This handles cases where the number has formatting like "+1" but extraction failed
            let plusRemovedNumberString = regexManager.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: nationalNumber as String)
            countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetadata)
        }

        // STEP 5: Final number normalization and validation
        // Normalize the remaining national number (remove spaces, dashes, etc.)
        nationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        
        // Handle special case where no country code was extracted (countryCode == 0)
        if countryCode == 0 {
            // Check if the number incorrectly includes the country code as part of the national number
            if nationalNumber.hasPrefix(String(regionMetadata.countryCode)) {
                let potentialNationalNumber = String(nationalNumber.dropFirst(String(regionMetadata.countryCode).count))
                
                // Validate that removing the country code prefix leaves a valid national number
                if let generalNumberDesc = regionMetadata.generalDesc,
                   regexManager.hasValue(generalNumberDesc.nationalNumberPattern),
                   parser.isNumberMatchingDesc(potentialNationalNumber, numberDesc: generalNumberDesc) {
                    
                    // Attempt to create a valid phone number with the corrected national number
                    let correctedNumberString = potentialNationalNumber
                    if let result = try validPhoneNumber(from: potentialNationalNumber, using: regionMetadata, countryCode: regionMetadata.countryCode, ignoreType: ignoreType, numberString: correctedNumberString, numberExtension: numberExtension) {
                        return result
                    }
                }
            }

            // Last attempt: try to parse the number as-is with the region's default country code
            if let result = try validPhoneNumber(from: nationalNumber, using: regionMetadata, countryCode: regionMetadata.countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
                return result
            }

            // If all attempts fail, the number is invalid
            throw PhoneNumberError.invalidNumber
        }

        // STEP 6: Update metadata if extracted country code differs from region's default
        // This handles cases where the number contains a country code different from the region parameter
        // For example: parsing a US number (+1) while specifying region as "CA" (Canada, also +1)
        if countryCode != regionMetadata.countryCode, let countryMetadata = metadataManager.mainTerritory(forCode: countryCode) {
            regionMetadata = countryMetadata
        }

        // Attempt to create a valid phone number with the extracted country code
        if let result = try validPhoneNumber(from: nationalNumber, using: regionMetadata, countryCode: countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
            return result
        }

        // STEP 7: Final fallback - try all territories with the same country code
        // Some country codes are shared by multiple territories (e.g., +1 for US, CA, etc.)
        // Try each territory's metadata to see if the number is valid in any of them
        var possibleResults: Set<PhoneNumber> = []
        if let metadataList = metadataManager.filterTerritories(byCode: countryCode) {
            for metadata in metadataList where regionMetadata.codeID != metadata.codeID {
                if let result = try validPhoneNumber(from: nationalNumber, using: metadata, countryCode: countryCode, ignoreType: ignoreType, numberString: numberString, numberExtension: numberExtension) {
                    possibleResults.insert(result)
                }
            }
        }

        // Return results based on how many valid interpretations were found
        switch possibleResults.count {
        case 0: 
            // No valid interpretation found
            throw PhoneNumberError.invalidNumber
        case 1: 
            // Exactly one valid interpretation - return it
            return possibleResults.first!
        default: 
            // Multiple valid interpretations - ambiguous number
            throw PhoneNumberError.ambiguousNumber(phoneNumbers: possibleResults)
        }
    }

    // Parse task

    /// Fastest way to parse an array of phone numbers. Uses custom region code.
    /// - Parameter numberStrings: An array of raw number strings.
    /// - Parameter region: ISO 3166 compliant region code.
    /// - parameter ignoreType: Avoids number type checking for faster performance.
    /// - Returns: An array of valid PhoneNumber objects.
    func parseMultiple(_ numberStrings: [String], withRegion region: String, ignoreType: Bool, shouldReturnFailedEmptyNumbers: Bool = false) -> [PhoneNumber] {
        var hasError = false

        let results = numberStrings.enumerated().map { index, numberString -> PhoneNumber in
            do {
                return try self.parse(numberString, withRegion: region, ignoreType: ignoreType)
            } catch {
                hasError = true
                return PhoneNumber.notPhoneNumber()
            }
        }

        if hasError && !shouldReturnFailedEmptyNumbers {
            return results.filter { $0.type != .notParsed }
        }

        return results
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

    // MARK: Internal method

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
            if let regionCode = getRegionCode(of: finalNationalNumber, countryCode: countryCode, leadingZero: leadingZero), let foundMetadata = metadataManager.filterTerritories(byCountry: regionCode) {
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
