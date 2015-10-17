//
//  PhoneNumberKit.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public class PhoneNumberKit : NSObject {
    
    // MARK: Lifecycle
    
    var metadata: [MetadataTerritory]

    public override init() {
        metadata = []
        super.init()
        metadata = populateMetadata()
    }
    
    // MARK: Data population
    
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
    
    // MARK: Core functionality

    public func parsePhoneNumber(rawNumber: String, defaultRegion: String) -> PhoneNumber? {
        let number: PhoneNumber?
        do {
            number = try PhoneNumber(rawNumber: rawNumber, defaultRegion: defaultRegion)
        } catch _ {
            number = nil
        }
        return number
    }

    // MARK: Country code helpers
    
    public func allCountries() -> [String] {
        let results = metadata.map{$0.codeID}
        return results
    }
    
    public func countriesForCode(code: UInt) -> [String] {
        let results = metadata.filter { $0.countryCode == code}
            .map{$0.codeID}
        return results
    }
    
    public func codeForCountry(country: NSString) -> UInt? {
        let results = metadata.filter { $0.codeID == country}
            .map{$0.countryCode}
        return results.first
    }
    
}


