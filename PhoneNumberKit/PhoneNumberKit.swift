//
//  PhoneNumberKit.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
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
    
    // MARK: Checking
    
    /// Checks if a number string is a valid PhoneNumber object
    ///
    /// - Parameters:
    ///   - numberString: the raw number string.
    ///   - region: ISO 639 compliant region code.
    ///   - ignoreType: Avoids number type checking for faster performance.
    /// - Returns: Bool
    public func isValidPhoneNumber(_ numberString: String, withRegion region: String = PhoneNumberKit.defaultRegionCode(), ignoreType: Bool = false) -> Bool {
        return (try? self.parse(numberString, withRegion: region, ignoreType: ignoreType)) != nil
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

    /// Get an array of possible phone number lengths for the country, as specified by the parameters.
    ///
    /// - parameter country: ISO 639 compliant region code.
    /// - parameter phoneNumberType: PhoneNumberType enum.
    /// - parameter lengthType: PossibleLengthType enum.
    ///
    /// - returns: Array of possible lengths for the country. May be empty.
    public func possiblePhoneNumberLengths(forCountry country: String, phoneNumberType: PhoneNumberType, lengthType: PossibleLengthType) -> [Int] {
        guard let territory = metadataManager.filterTerritories(byCountry: country) else { return [] }

        let possibleLengths = possiblePhoneNumberLengths(forTerritory: territory, phoneNumberType: phoneNumberType)

        switch lengthType {
        case .national:     return possibleLengths?.national.flatMap { self.parsePossibleLengths($0) } ?? []
        case .localOnly:    return possibleLengths?.localOnly.flatMap { self.parsePossibleLengths($0) } ?? []
        }
    }

    private func possiblePhoneNumberLengths(forTerritory territory: MetadataTerritory, phoneNumberType: PhoneNumberType) -> MetadataPossibleLengths? {
        switch phoneNumberType {
        case .fixedLine:        return territory.fixedLine?.possibleLengths
        case .mobile:           return territory.mobile?.possibleLengths
        case .pager:            return territory.pager?.possibleLengths
        case .personalNumber:   return territory.personalNumber?.possibleLengths
        case .premiumRate:      return territory.premiumRate?.possibleLengths
        case .sharedCost:       return territory.sharedCost?.possibleLengths
        case .tollFree:         return territory.tollFree?.possibleLengths
        case .voicemail:        return territory.voicemail?.possibleLengths
        case .voip:             return territory.voip?.possibleLengths
        case .uan:              return territory.uan?.possibleLengths
        case .fixedOrMobile:    return nil // caller needs to combine results for .fixedLine and .mobile
        case .unknown:          return nil
        case .notParsed:        return nil
        }
    }

    /// Parse lengths string into array of Int, e.g. "6,[8-10]" becomes [6,8,9,10]
    private func parsePossibleLengths(_ lengths: String) -> [Int] {
        let components = lengths.components(separatedBy: ",")
        let results = components.reduce([Int](), { result, component in
            let newComponents = parseLengthComponent(component)
            return result + newComponents
        })

        return results
    }

    /// Parses numbers and ranges into array of Int
    private func parseLengthComponent(_ component: String) -> [Int] {
        if let int = Int(component) {
            return [int]
        } else {
            let trimmedComponent = component.trimmingCharacters(in: CharacterSet(charactersIn: "[]"))
            let rangeLimits = trimmedComponent.components(separatedBy: "-").compactMap { Int($0) }

            guard rangeLimits.count == 2,
                let rangeStart = rangeLimits.first,
                let rangeEnd = rangeLimits.last
                else { return [] }

            return Array(rangeStart...rangeEnd)
        }
    }

    // MARK: Class functions

    /// Get a user's default region code
    ///
    /// - returns: A computed value for the user's current region - based on the iPhone's carrier and if not available, the device region.
    public class func defaultRegionCode() -> String {
#if os(iOS) && !targetEnvironment(simulator) && !targetEnvironment(macCatalyst)
        let networkInfo = CTTelephonyNetworkInfo()
        var carrier: CTCarrier? = nil
        if #available(iOS 12.0, *) {
            carrier = networkInfo.serviceSubscriberCellularProviders?.values.first
        } else {
            carrier = networkInfo.subscriberCellularProvider
        }

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
        let frameworkBundle = Bundle.module
        guard let jsonPath = frameworkBundle.path(forResource: "PhoneNumberMetadata", ofType: "json") else {
            throw PhoneNumberError.metadataNotFound
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: jsonPath))
        return data
    }
}

#if canImport(UIKit)
extension PhoneNumberKit {

    /// Configuration for the CountryCodePicker presented from PhoneNumberTextField if `withDefaultPickerUI` is `true`
    public enum CountryCodePicker {
        /// Common Country Codes are shown below the Current section in the CountryCodePicker by default
        public static var commonCountryCodes: [String] = []

        /// When the Picker is shown from the textfield it is presented modally
        public static var forceModalPresentation: Bool = false
    }
}
#endif
