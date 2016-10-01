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
    
public class PhoneNumberKit: NSObject {
    
    // Manager objects
    let metadataManager = MetadataManager()
    let parseManager: ParseManager
    let regexManager = RegexManager()

    // Parsers
    let parser: PhoneNumberParser
    
    // MARK: Lifecycle
    
    override init() {
        self.parser = PhoneNumberParser(regex: regexManager, metadata: metadataManager)
        self.parseManager = ParseManager(metadataManager: metadataManager, parser: parser, regexManager: regexManager)
    }

    // MARK: Parsing
    
    /// Parse function for a number string, used to create PhoneNumber objects.
    ///
    /// - parameter numberString: the raw number string.
    /// - parameter region:       ISO 639 compliant region code.
    ///
    /// - returns: PhoneNumber object.
    public func parse(_ numberString: String, withRegion region: String = PhoneNumberKit.defaultRegionCode()) throws -> PhoneNumber {
        return try parseManager.parsePhoneNumber(numberString, withRegion: region)
    }
    
    /// Parse function for an array of number strings. Optimised for performance. Parse failures are ignored in the resulting array
    ///
    /// - parameter numberStrings: array of raw number strings.
    /// - parameter region:        ISO 639 compliant region code.
    ///
    /// - returns: array of PhoneNumber objects.
    public func parse(_ numberStrings: [String], withRegion region: String = PhoneNumberKit.defaultRegionCode()) -> [PhoneNumber] {
        return parseManager.parseMultiple(numberStrings, withRegion: region)
    }
    
    // MARK: Formatting
    
    public func format(phoneNumber: PhoneNumber, to formatType:PhoneNumberFormat, with prefix: Bool = true) -> String {
        let formatter = Formatter(phoneNumberKit: self)
        if formatType == .e164 {
            let formattedNationalNumber = phoneNumber.adjustedNationalNumber()
            if prefix == false {
                return formattedNationalNumber
            }
            return "+\(phoneNumber.countryCode)\(formattedNationalNumber)"
        } else {
            let regionMetadata = metadataManager.territoriesByCode[phoneNumber.countryCode]
            let formattedNationalNumber = formatter.format(phoneNumber: phoneNumber, formatType: formatType, regionMetadata: regionMetadata)
            if formatType == .international && prefix == true {
                return "+\(phoneNumber.countryCode) \(formattedNationalNumber)"
            } else {
                return formattedNationalNumber
            }
        }
    }
    
    // MARK: Validation
    
    /// Performs a strong validation on a PhoneNumber object by checking if it is of a known type.
    ///
    /// - parameter phoneNumber: PhoneNumber object
    ///
    /// - returns: whether or not the number is valid
    public func isValid(phoneNumber: PhoneNumber) -> Bool {
        let type = self.parser.checkNumberType(phoneNumber)
        return (type != .unknown)
    }
    
    
    /// Determine the type of a given phone number.
    ///
    /// - parameter phoneNumber: PhoneNumber object.
    ///
    /// - returns: PhoneNumberType enum.
    public func getType(of phoneNumber: PhoneNumber) -> PhoneNumberType {
        let type = self.parser.checkNumberType(phoneNumber)
        return type
    }


    // MARK: Country and region code
    
    /**
    Get a list of all the countries in the metadata database
    - Returns: An array of ISO 639 compliant region codes.
    */
    public func allCountries() -> [String] {
        let results = metadataManager.territories.map{$0.codeID}
        return results
    }
    
    /**
    Get an array of ISO 639 compliant region codes corresponding to a given country code.
    - Parameter countryCode: An international country code (e.g 44 for the UK).
    - Returns: An optional array of ISO 639 compliant region codes.
    */
    public func countries(with countryCode: UInt64) -> [String]? {
        let results = metadataManager.filterTerritories(byCode: countryCode)?.map{$0.codeID}
        return results
    }
    
    /**
    Get an main ISO 639 compliant region code for a given country code.
    - Parameter countryCode: An international country code (e.g 1 for the US).
    - Returns: A ISO 639 compliant region code string.
    */
    public func mainCountry(for countryCode: UInt64) -> String? {
        let country = metadataManager.mainTerritory(forCode: countryCode)
        return country?.codeID
    }

    /**
    Get the region code for the given phone number
    - Parameter phoneNumber: The phone number
    - Returns: Region code, eg "US", or nil if the region cannot be determined
    */
    public func regionCode(for phoneNumber: PhoneNumber) -> String? {
        let countryCode = phoneNumber.countryCode
        let regions = metadataManager.territories.filter { $0.countryCode == countryCode }
        if regions.count == 1 {
            return regions[0].codeID
        }

        return parseManager.getRegionCodeForNumber(number: phoneNumber, fromRegionList: regions)
    }

    
    /**
    Get an international country code for an ISO 639 compliant region code
    - Parameter country: ISO 639 compliant region code.
    - Returns: An international country code (e.g. 33 for France).
    */
    public func countryCode(for country: String) -> UInt64? {
        let results = metadataManager.filterTerritories(byCountry: country)?.countryCode
        return results
    }
    
    /**
    Get a user's default region code,
    - Returns: A computed value for the user's current region - based on the iPhone's carrier and if not available, the device region.
    */
    public class func defaultRegionCode() -> String {
#if os(iOS)
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if let isoCountryCode = carrier?.isoCountryCode {
            return isoCountryCode.uppercased()
        }
#endif
        let currentLocale = Locale.current
        if #available(iOS 10.0, *) {
            let countryCode = currentLocale.regionCode
            return countryCode?.uppercased() ?? ""
        } else {
			if let countryCode = (currentLocale as NSLocale).object(forKey: .countryCode) as? String {
                return countryCode.uppercased()
            }
        }
        return PhoneNumberConstants.defaultCountry
    }

}
