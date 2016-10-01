//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

internal class MetadataManager {
    
    var territories = [MetadataTerritory]()
    var territoriesByCode = [UInt64: MetadataTerritory]()
    var territoriesByCountry = [String: MetadataTerritory]()
    
    /**
     Private init populates metadata territories and the two hashed dictionaries for faster lookup.
     */
    public init () {
        territories = populateTerritories()
        for item in territories {
            if territoriesByCode[item.countryCode] == nil || item.mainCountryForCode == true {
                territoriesByCode[item.countryCode] = item
            }
            territoriesByCountry[item.codeID] = item
        }
    }
    
    deinit {
        territories.removeAll()
        territoriesByCode.removeAll()
        territoriesByCountry.removeAll()
    }
    
    // MARK: Metadata population
    
    /**
    Populates the metadata from the included json file resource.
    - Returns: An array of MetadataTerritory objects.
    */
    func populateTerritories() -> [MetadataTerritory] {
        var territoryArray = [MetadataTerritory]()
        let frameworkBundle = Bundle(for: PhoneNumberKit.self)
        guard let jsonPath = frameworkBundle.path(forResource: "PhoneNumberMetadata", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
            return territoryArray
        }
        do {
            if let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? NSDictionary {
                if let metadataDict = jsonObjects["phoneNumberMetadata"] as? NSDictionary {
                    if let metadataTerritories = metadataDict["territories"] as? NSDictionary {
                        if let metadataTerritoryArray = metadataTerritories["territory"] as? NSArray {
                            metadataTerritoryArray.forEach({
                                if let territoryDict = $0 as? NSDictionary {
                                    let parsedTerritory = MetadataTerritory(jsondDict: territoryDict)
                                    territoryArray.append(parsedTerritory)
                                }
                            })
                        }
                        else {
                            return territoryArray
                        }
                    }
                }
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
    func filterTerritories(byCode code: UInt64) -> [MetadataTerritory]? {
        let results = territories.filter { $0.countryCode == code}
        return results
    }
    
    
    /**
     Get the MetadataTerritory objects for an ISO 639 compliant region code.
     - Parameter country: ISO 639 compliant region code (e.g "GB" for the UK).
     - Returns: A MetadataTerritory object.
     */
    func filterTerritories(byCountry country: String) -> MetadataTerritory? {
        let results = territories.filter { $0.codeID == country.uppercased()}
        return results.first
    }
    
    /**
    Get the main MetadataTerritory objects for a given country code.
    - Parameter code: An international country code (e.g 1 for the US).
    - Returns: A MetadataTerritory object.
    */
    func mainTerritory(forCode code: UInt64) -> MetadataTerritory? {
        let countryResults = territories.filter { $0.countryCode == code}
        let mainCountryResults = countryResults.filter { $0.mainCountryForCode == true}
        if let mainCountry = mainCountryResults.first {
            return mainCountry
        }
        else if let firstCountry = countryResults.first {
            return firstCountry
        }
        else {
            return nil
        }
    }
    
    
}
