//
//  PhoneNumberKit.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
#if os(iOS)
import CoreTelephony
#endif

public typealias MetadataCallback = (() throws -> Data?)

public final class PhoneNumberKit: NSObject {
    // Manager objects
    let metadataManager: MetadataManager
    let parseManager: ParseManager
    let regexManager = RegexManager()

    // MARK: Lifecycle

    public init(metadataCallback: @escaping MetadataCallback = PhoneNumberKit.defaultMetadataCallback) {
        self.metadataManager = MetadataManager(metadataCallback: metadataCallback)
        self.parseManager = ParseManager(metadataManager: self.metadataManager, regexManager: self.regexManager)
    }

    // MARK: Parsing

    /// Parses a number string, used to create PhoneNumber objects. Throws.
    ///
    /// - Parameters:
    ///   - numberString: the raw number string.
    ///   - region: ISO 639 compliant region code.
    ///   - ignoreType: Avoids number type checking for faster performance.
    /// - Returns: PhoneNumber object.
    public func parse(_ numberString: String, withRegion region: String = PhoneNumberKit.defaultRegionCode(), ignoreType: Bool = false) throws -> PhoneNumber {
        var numberStringWithPlus = numberString

        do {
            return try self.parseManager.parse(numberString, withRegion: region, ignoreType: ignoreType)
        } catch {
            if numberStringWithPlus.first != "+" {
                numberStringWithPlus = "+" + numberStringWithPlus
            }
        }

        return try self.parseManager.parse(numberStringWithPlus, withRegion: region, ignoreType: ignoreType)
    }

    /// Parses an array of number strings. Optimised for performance. Invalid numbers are ignored in the resulting array
    ///
    /// - parameter numberStrings:               array of raw number strings.
    /// - parameter region:                      ISO 639 compliant region code.
    /// - parameter ignoreType:   Avoids number type checking for faster performance.
    ///
    /// - returns: array of PhoneNumber objects.
    public func parse(_ numberStrings: [String], withRegion region: String = PhoneNumberKit.defaultRegionCode(), ignoreType: Bool = false, shouldReturnFailedEmptyNumbers: Bool = false) -> [PhoneNumber] {
        return self.parseManager.parseMultiple(numberStrings, withRegion: region, ignoreType: ignoreType, shouldReturnFailedEmptyNumbers: shouldReturnFailedEmptyNumbers)
    }

    // MARK: Formatting

    /// Formats a PhoneNumber object for dispaly.
    ///
    /// - parameter phoneNumber: PhoneNumber object.
    /// - parameter formatType:  PhoneNumberFormat enum.
    /// - parameter prefix:      whether or not to include the prefix.
    ///
    /// - returns: Formatted representation of the PhoneNumber.
    public func format(_ phoneNumber: PhoneNumber, toType formatType: PhoneNumberFormat, withPrefix prefix: Bool = true) -> String {
        if formatType == .e164 {
            let formattedNationalNumber = phoneNumber.adjustedNationalNumber()
            if prefix == false {
                return formattedNationalNumber
            }
            return "+\(phoneNumber.countryCode)\(formattedNationalNumber)"
        } else {
            let formatter = Formatter(phoneNumberKit: self)
            let regionMetadata = self.metadataManager.mainTerritoryByCode[phoneNumber.countryCode]
            let formattedNationalNumber = formatter.format(phoneNumber: phoneNumber, formatType: formatType, regionMetadata: regionMetadata)
            if formatType == .international, prefix == true {
                return "+\(phoneNumber.countryCode) \(formattedNationalNumber)"
            } else {
                return formattedNationalNumber
            }
        }
    }

    // MARK: Country and region code

    /// Get a list of all the countries in the metadata database
    ///
    /// - returns: An array of ISO 639 compliant region codes.
    public func allCountries() -> [String] {
        let results = self.metadataManager.territories.map { $0.codeID }
        return results
    }

    /// Get an array of ISO 639 compliant region codes corresponding to a given country code.
    ///
    /// - parameter countryCode: international country code (e.g 44 for the UK).
    ///
    /// - returns: optional array of ISO 639 compliant region codes.
    public func countries(withCode countryCode: UInt64) -> [String]? {
        let results = self.metadataManager.filterTerritories(byCode: countryCode)?.map { $0.codeID }
        return results
    }

    /// Get an main ISO 639 compliant region code for a given country code.
    ///
    /// - parameter countryCode: international country code (e.g 1 for the US).
    ///
    /// - returns: ISO 639 compliant region code string.
    public func mainCountry(forCode countryCode: UInt64) -> String? {
        let country = self.metadataManager.mainTerritory(forCode: countryCode)
        return country?.codeID
    }

    /// Get an international country code for an ISO 639 compliant region code
    ///
    /// - parameter country: ISO 639 compliant region code.
    ///
    /// - returns: international country code (e.g. 33 for France).
    public func countryCode(for country: String) -> UInt64? {
        let results = self.metadataManager.filterTerritories(byCountry: country)?.countryCode
        return results
    }

    /// Get leading digits for an ISO 639 compliant region code.
    ///
    /// - parameter country: ISO 639 compliant region code.
    ///
    /// - returns: leading digits (e.g. 876 for Jamaica).
    public func leadingDigits(for country: String) -> String? {
        let leadingDigits = self.metadataManager.filterTerritories(byCountry: country)?.leadingDigits
        return leadingDigits
    }

    /// Determine the region code of a given phone number.
    ///
    /// - parameter phoneNumber: PhoneNumber object
    ///
    /// - returns: Region code, eg "US", or nil if the region cannot be determined.
    public func getRegionCode(of phoneNumber: PhoneNumber) -> String? {
        return self.parseManager.getRegionCode(of: phoneNumber.nationalNumber, countryCode: phoneNumber.countryCode, leadingZero: phoneNumber.leadingZero)
    }

    /// Get an example phone number for an ISO 639 compliant region code.
    ///
    /// - parameter countryCode: ISO 639 compliant region code.
    /// - parameter type: The `PhoneNumberType` desired. default: `.mobile`
    ///
    /// - returns: An example phone number
    public func getExampleNumber(forCountry countryCode: String, ofType type: PhoneNumberType = .mobile) -> PhoneNumber? {
        let metadata = self.metadata(for: countryCode)
        let example: String?
        switch type {
        case .fixedLine: example = metadata?.fixedLine?.exampleNumber
        case .mobile: example = metadata?.mobile?.exampleNumber
        case .fixedOrMobile: example = metadata?.mobile?.exampleNumber
        case .pager: example = metadata?.pager?.exampleNumber
        case .personalNumber: example = metadata?.personalNumber?.exampleNumber
        case .premiumRate: example = metadata?.premiumRate?.exampleNumber
        case .sharedCost: example = metadata?.sharedCost?.exampleNumber
        case .tollFree: example = metadata?.tollFree?.exampleNumber
        case .voicemail: example = metadata?.voicemail?.exampleNumber
        case .voip: example = metadata?.voip?.exampleNumber
        case .uan: example = metadata?.uan?.exampleNumber
        case .unknown: return nil
        case .notParsed: return nil
        }
        do {
            return try example.flatMap { try parse($0, withRegion: countryCode, ignoreType: false) }
        } catch {
            print("[PhoneNumberKit] Failed to parse example number for \(countryCode) region")
            return nil
        }
    }

    /// Get a formatted example phone number for an ISO 639 compliant region code.
    ///
    /// - parameter countryCode: ISO 639 compliant region code.
    /// - parameter type: `PhoneNumberType` desired. default: `.mobile`
    /// - parameter format: `PhoneNumberFormat` to use for formatting. default: `.international`
    /// - parameter prefix: Whether or not to include the prefix.
    ///
    /// - returns: A formatted example phone number
    public func getFormattedExampleNumber(
        forCountry countryCode: String, ofType type: PhoneNumberType = .mobile,
        withFormat format: PhoneNumberFormat = .international, withPrefix prefix: Bool = true
    ) -> String? {
        return self.getExampleNumber(forCountry: countryCode, ofType: type)
            .flatMap { self.format($0, toType: format, withPrefix: prefix) }
    }

    /// Get the MetadataTerritory objects for an ISO 639 compliant region code.
    ///
    /// - parameter country: ISO 639 compliant region code (e.g "GB" for the UK).
    ///
    /// - returns: A MetadataTerritory object, or nil if no metadata was found for the country code
    public func metadata(for country: String) -> MetadataTerritory? {
        return self.metadataManager.filterTerritories(byCountry: country)
    }

    /// Get an array of MetadataTerritory objects corresponding to a given country code.
    ///
    /// - parameter countryCode: international country code (e.g 44 for the UK)
    public func metadata(forCode countryCode: UInt64) -> [MetadataTerritory]? {
        return self.metadataManager.filterTerritories(byCode: countryCode)
    }

    // MARK: Class functions

    /// Get a user's default region code
    ///
    /// - returns: A computed value for the user's current region - based on the iPhone's carrier and if not available, the device region.
    public class func defaultRegionCode() -> String {
#if os(iOS)
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if let isoCountryCode = carrier?.isoCountryCode {
            return isoCountryCode.uppercased()
        }
#endif
        let currentLocale = Locale.current
        if #available(iOS 10.0, *), let countryCode = currentLocale.regionCode {
            return countryCode.uppercased()
        } else {
            if let countryCode = (currentLocale as NSLocale).object(forKey: .countryCode) as? String {
                return countryCode.uppercased()
            }
        }
        return PhoneNumberConstants.defaultCountry
    }

    /// Default metadta callback, reads metadata from PhoneNumberMetadata.json file in bundle
    ///
    /// - returns: an optional Data representation of the metadata.
    public static func defaultMetadataCallback() throws -> Data? {
        let frameworkBundle = Bundle(for: PhoneNumberKit.self)
        guard let jsonPath = frameworkBundle.path(forResource: "PhoneNumberMetadata", ofType: "json") else {
            throw PhoneNumberError.metadataNotFound
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        return data
    }
}
