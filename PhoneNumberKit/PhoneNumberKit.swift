//
//  PhoneNumberKit.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import CoreTelephony

public class PhoneNumberKit : NSObject {
    
    let metadata = Metadata.sharedInstance
    
    // MARK: Parsing
    
    // Fastest way to parse an array of phone numbers, returns an array of valid PhoneNumber objects. Uses default region code.
    public func parseMultiple(rawNumbers : [String]) -> [PhoneNumber] {
        return ParseManager().multiParse(rawNumbers, region: self.defaultRegionCode())
    }
    
    // Fastest way to parse an array of phone numbers. Allows you to specifiy custom region code.
    public func parseMultiple(rawNumbers : [String], region: String) -> [PhoneNumber] {
        return ParseManager().multiParse(rawNumbers, region: region)
    }

    // MARK: Country and region code
    
    // Get a list of all the countries in the metadata database
    public func allCountries() -> [String] {
        let results = metadata.items.map{$0.codeID}
        return results
    }
    
    // Get the countries corresponding to a given country code
    public func countriesForCode(code: UInt64) -> [String]? {
        let results = metadata.countriesForCode(code)?.map{$0.codeID}
        return results
    }
    
    // Get the main country corresponding to a given country code
    public func mainCountryForCode(code: UInt64) -> String? {
        let country = metadata.mainCountryMetadataForCode(code)
        return country?.codeID
    }
        
    // Get a the country code for a specific country
    public func codeForCountry(country: NSString) -> UInt64? {
        let results = metadata.metadataForCountry(country)?.countryCode
        return results
    }
    
    // Get the user's default region code, based on the carrier and if not available, the device region
    public func defaultRegionCode() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if (carrier != nil && (carrier!.isoCountryCode != nil)) {
            return carrier!.isoCountryCode!.uppercaseString;
        } else {
            let currentLocale = NSLocale.currentLocale()
            let countryCode : String = currentLocale.objectForKey(NSLocaleCountryCode) as! String
            return countryCode.uppercaseString;
        }
    }

}


