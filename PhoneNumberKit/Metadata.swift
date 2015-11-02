//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Metadata {
    
    static let sharedInstance = Metadata()
    
    var items: [MetadataTerritory] = []
    var metadataPerCode: [UInt64: MetadataTerritory] = [:]
    var metadataPerCountry: [String: MetadataTerritory] = [:]
    
    /**
     Private init populates metadata items and the two hashed dictionaries for faster lookup.
     */
    private init () {
        items = populateItems()
        for item in items {
            if (metadataPerCode[item.countryCode] == nil || item.mainCountryForCode == true) {
                metadataPerCode[item.countryCode] = item
            }
            metadataPerCountry[item.codeID] = item
        }
    }
    
    // MARK: Metadata population
    
    /**
    Populates the metadata from the included json file resource.
    - Returns: An array of MetadataTerritory objects.
    */
    func populateItems() -> [MetadataTerritory] {
        var territoryArray: [MetadataTerritory] = [MetadataTerritory]()
        let frameworkBundle = NSBundle(forClass: PhoneNumberKit.self)
        let jsonPath = frameworkBundle.pathForResource("PhoneNumberMetadata", ofType: "json")
        let jsonData = NSData(contentsOfFile: jsonPath!)
        do {
            let jsonObjects: NSDictionary = try NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.AllowFragments) as! NSDictionary
            let metaDataDict: NSDictionary = jsonObjects["phoneNumberMetadata"] as! NSDictionary
            let metaDataTerritories: NSDictionary = metaDataDict["territories"] as! NSDictionary
            let metaDataTerritoryArray: NSArray = metaDataTerritories["territory"] as! NSArray
            for territory in metaDataTerritoryArray {
                let parsedTerritory = MetadataTerritory(jsondDict: territory as! NSDictionary)
                territoryArray.append(parsedTerritory)
            }
            return territoryArray
        }
        catch {
            return territoryArray
        }
    }
    
    // MARK: Fetch helpers
    
    /**
    Get an array of MetadataTerritory objects corresponding to a given country code.
    - Parameter code: An international country code (e.g 44 for the UK).
    - Returns: An optional array of MetadataTerritory objects.
    */
    func fetchCountriesForCode(code: UInt64) -> [MetadataTerritory]? {
        let results = items.filter { $0.countryCode == code}
        return results
    }
    
    /**
    Get the main MetadataTerritory objects for a given country code.
    - Parameter code: An international country code (e.g 1 for the US).
    - Returns: A MetadataTerritory object.
    */
    func fetchMainCountryMetadataForCode(code: UInt64) -> MetadataTerritory? {
        let results = items.filter { $0.countryCode == code}
        if (results.count > 0) {
            var mainResult: MetadataTerritory
            if (results.count > 1) {
                mainResult = results.filter { $0.mainCountryForCode == true}.first!
            }
            else {
                mainResult = results.first!
            }
            return mainResult
        }
        return nil
    }
    

    /**
     Get the MetadataTerritory objects for an ISO 639 compliant region code.
     - Parameter country: ISO 639 compliant region code (e.g "GB" for the UK).
     - Returns: A MetadataTerritory object.
     */
    func fetchMetadataForCountry(country: String) -> MetadataTerritory? {
        let results = items.filter { $0.codeID == country.uppercaseString}
        return results.first
    }
    
}


