//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: Metdata Class

class Metadata {
    
    // MARK: Lifecycle
    
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

// MARK: MetadataTerritory

/**
MetadataTerritory object
- Parameter codeID: ISO 639 compliant region code
- Parameter countryCode: International country code
- Parameter internationalPrefix: International prefix. Optional.
- Parameter mainCountryForCode: Whether the current metadata is the main country for its country code.
- Parameter nationalPrefix: National prefix
- Parameter nationalPrefixForParsing: National prefix for parsing
- Parameter nationalPrefixTransformRule: National prefix transform rule
- Parameter emergency: MetadataPhoneNumberDesc for emergency numbers
- Parameter fixedLine: MetadataPhoneNumberDesc for fixed line numbers
- Parameter generalDesc: MetadataPhoneNumberDesc for general numbers
- Parameter mobile: MetadataPhoneNumberDesc for mobile numbers
- Parameter pager: MetadataPhoneNumberDesc for pager numbers
- Parameter personalNumber: MetadataPhoneNumberDesc for personal number numbers
- Parameter premiumRate: MetadataPhoneNumberDesc for premium rate numbers
- Parameter sharedCost: MetadataPhoneNumberDesc for shared cost numbers
- Parameter tollFree: MetadataPhoneNumberDesc for toll free numbers
- Parameter voicemail: MetadataPhoneNumberDesc for voice mail numbers
- Parameter voip: MetadataPhoneNumberDesc for voip numbers
- Parameter uan: MetadataPhoneNumberDesc for uan numbers
*/
struct MetadataTerritory {
    var codeID: String
    var countryCode: UInt64
    var internationalPrefix: String?
    var mainCountryForCode: Bool = false
    var nationalPrefix: String?
    var nationalPrefixForParsing: String?
    var nationalPrefixTransformRule: String?
    var emergency: MetadataPhoneNumberDesc?
    var fixedLine: MetadataPhoneNumberDesc?
    var generalDesc: MetadataPhoneNumberDesc?
    var mobile: MetadataPhoneNumberDesc?
    var pager: MetadataPhoneNumberDesc?
    var personalNumber: MetadataPhoneNumberDesc?
    var premiumRate: MetadataPhoneNumberDesc?
    var sharedCost: MetadataPhoneNumberDesc?
    var tollFree: MetadataPhoneNumberDesc?
    var voicemail: MetadataPhoneNumberDesc?
    var voip: MetadataPhoneNumberDesc?
    var uan: MetadataPhoneNumberDesc?
}

extension MetadataTerritory {
    /**
     Parse a json dictionary into a MetadataTerritory.
     - Parameter jsondDict: json dictionary from attached json metadata file.
     */
    init(jsondDict: NSDictionary) {
        self.generalDesc = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("generalDesc") as? NSDictionary)!)
        self.fixedLine = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("fixedLine") as? NSDictionary))
        self.mobile = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("mobile") as? NSDictionary))
        self.tollFree = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("tollFree") as? NSDictionary))
        self.premiumRate = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("premiumRate") as? NSDictionary))
        self.sharedCost = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("sharedCost") as? NSDictionary))
        self.personalNumber = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("personalNumber") as? NSDictionary))
        self.voip = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("voip") as? NSDictionary))
        self.pager = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("pager") as? NSDictionary))
        self.uan = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("uan") as? NSDictionary))
        self.emergency = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("emergency") as? NSDictionary))
        self.voicemail = MetadataPhoneNumberDesc(jsondDict: (jsondDict.valueForKey("voicemail") as? NSDictionary))
        self.codeID = jsondDict.valueForKey("_id") as! String
        self.countryCode = UInt64(jsondDict.valueForKey("_countryCode") as! String)!
        self.internationalPrefix = jsondDict.valueForKey("_internationalPrefix") as? String
        self.nationalPrefix = jsondDict.valueForKey("_nationalPrefix") as? String
        self.nationalPrefixForParsing = jsondDict.valueForKey("_nationalPrefixForParsing") as? String
        if (self.nationalPrefixForParsing == nil && self.nationalPrefix != nil) {
            self.nationalPrefixForParsing = self.nationalPrefix
        }
        self.nationalPrefixTransformRule = jsondDict.valueForKey("_nationalPrefixTransformRule") as? String
        let _mainCountryForCode = jsondDict.valueForKey("_mainCountryForCode") as? NSString
        if (_mainCountryForCode != nil) {
            self.mainCountryForCode = _mainCountryForCode!.boolValue
        }
    }
}

// MARK: MetadataPhoneNumberDesc

/**
 MetadataPhoneNumberDesc object
 - Parameter exampleNumber: An example phone number for the given type. Optional.
 - Parameter nationalNumberPattern:  National number regex pattern. Optional.
 - Parameter possibleNumberPattern:  Possible number regex pattern. Optional.
 */
struct MetadataPhoneNumberDesc {
    var exampleNumber: String?
    var nationalNumberPattern: String?
    var possibleNumberPattern: String?
}

extension MetadataPhoneNumberDesc {
    /**
     Parse a json dictionary into a MetadataTerritory.
     - Parameter jsondDict: json dictionary from attached json metadata file.
     */
    init(jsondDict: NSDictionary?) {
        self.nationalNumberPattern = jsondDict?.valueForKey("nationalNumberPattern") as? String
        self.possibleNumberPattern = jsondDict?.valueForKey("possibleNumberPattern") as? String
        self.exampleNumber = jsondDict?.valueForKey("exampleNumber") as? String
        
    }
}

