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
    
    // MARK: Lifecycle
    
    var metadata: [MetadataTerritory] = []

    public override init() {
        super.init()
        metadata = populateMetadata()
    }
    
    // MARK: Data population
    
    // Populate the metadata from the json file
    func populateMetadata() -> [MetadataTerritory] {
        var territoryArray : [MetadataTerritory] = [MetadataTerritory]()
        let frameworkBundle = NSBundle(forClass: PhoneNumberKit.self)
        let jsonPath = frameworkBundle.pathForResource("PhoneNumberMetadata", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        do {
            let jsonObjects : NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let metaDataDict : NSDictionary = jsonObjects["phoneNumberMetadata"] as! NSDictionary
            let metaDataTerritories : NSDictionary = metaDataDict["territories"] as! NSDictionary
            let metaDataTerritoryArray : NSArray = metaDataTerritories["territory"] as! NSArray
            for territory in metaDataTerritoryArray {
                let parsedTerritory = MetadataTerritory(jsondDict: territory as! NSDictionary)
                territoryArray.append(parsedTerritory)
            }
        }
        catch {
            
        }
        return territoryArray
    }
    
    // MARK: Country and region code
    
    // Get a list of all the countries in the metadata database
    public func allCountries() -> [String] {
        let results = metadata.map{$0.codeID}
        return results
    }
    
    // Get a the countries corresponding to a given country code
    public func countriesForCode(code: UInt) -> [String] {
        let results = metadata.filter { $0.countryCode == code}
            .map{$0.codeID}
        return results
    }
    
    // Get a the country code for a specific country
    public func codeForCountry(country: NSString) -> UInt? {
        let results = metadata.filter { $0.codeID == country}
            .map{$0.countryCode}
        return results.first
    }
    
    // Get the user's default region code, based on the carrier and if not available, the device region
    public func defaultRegionCode() -> String {
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        if (carrier != nil && (carrier!.isoCountryCode != nil)) {
            return carrier!.isoCountryCode!;
        } else {
            let currentLocale = NSLocale.currentLocale()
            let countryCode : String = currentLocale.objectForKey(NSLocaleCountryCode) as! String
            return countryCode;
        }
    }

    
}


