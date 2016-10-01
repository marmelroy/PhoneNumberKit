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
    let regexManager = RegexManager()
    let parseManager: ParseManager

    // Parsers
    let parser: PhoneNumberParser
    
    // MARK: Lifecycle
    
    override init() {
        self.parser = PhoneNumberParser(regex: regexManager, metadata: metadataManager)
        self.parseManager = ParseManager(regex: regexManager, metadata: metadataManager, parser: parser)
    }

    // MARK: Parsing
    
    public func parse(numberString: String, withRegion region: String = PhoneNumberKit.defaultRegionCode()) throws -> PhoneNumber {
        return try parseManager.parsePhoneNumber(numberString, region: region)
    }
    
    /**
    Fastest way to parse an array of phone numbers.
    - Parameter rawNumbers: An array of raw number strings.
    - Parameter region: ISO 639 compliant region code.
    - Returns: An array of valid PhoneNumber objects.
    */
    public func parse(numberStrings: [String], withRegion region: String = PhoneNumberKit.defaultRegionCode()) -> [PhoneNumber] {
        return parseManager.parseMultiple(numberStrings, region: region)
    }

    
    public func validate(phoneNumber: PhoneNumber) -> Bool {
        let type = self.parser.checkNumberType(phoneNumber)
        return (type != .unknown)
    }
    
    public func type(forPhoneNumber phoneNumber: PhoneNumber) -> PhoneNumberType {
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
    - Parameter code: An international country code (e.g 44 for the UK).
    - Returns: An optional array of ISO 639 compliant region codes.
    */
    public func countries(forCountryCode countryCode: UInt64) -> [String]? {
        let results = metadataManager.filterTerritories(byCode: countryCode)?.map{$0.codeID}
        return results
    }
    
    /**
    Get an main ISO 639 compliant region code for a given country code.
    - Parameter code: An international country code (e.g 1 for the US).
    - Returns: A ISO 639 compliant region code string.
    */
    public func mainCountry(forCountryCode countryCode: UInt64) -> String? {
        let country = metadataManager.mainTerritory(forCode: countryCode)
        return country?.codeID
    }

    /**
    Get the region code for the given phone number
    - Parameter number: The phone number
    - Returns: Region code, eg "US", or nil if the region cannot be determined
    */
    public func regionCode(forPhoneNumber phoneNumber: PhoneNumber) -> String? {
        let countryCode = phoneNumber.countryCode
        let regions = metadataManager.territories.filter { $0.countryCode == countryCode }
        if regions.count == 1 {
            return regions[0].codeID
        }

        return getRegionCodeForNumber(phoneNumber, fromRegionList: regions)
    }

    private func getRegionCodeForNumber(_ number: PhoneNumber, fromRegionList regions: [MetadataTerritory]) -> String? {
        let nationalNumber = String(number.nationalNumber)
        for region in regions {
            if let leadingDigits = region.leadingDigits {
                if regexManager.matchesAtStart(leadingDigits, string: nationalNumber) {
                    return region.codeID
                }
            }
            if number.leadingZero && parser.checkNumberType("0" + nationalNumber, metadata: region) != .unknown {
                return region.codeID
            }
            if parser.checkNumberType(nationalNumber, metadata: region) != .unknown {
                return region.codeID
            }
        }
        return nil
    }
    
    /**
    Get an international country code for an ISO 639 compliant region code
    - Parameter country: ISO 639 compliant region code.
    - Returns: An international country code (e.g. 33 for France).
    */
    public func countryCode(forCountry country: String) -> UInt64? {
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
