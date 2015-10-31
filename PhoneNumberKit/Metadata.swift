//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class Metadata {
    
    // MARK: Lifecycle
    
    static let sharedInstance = Metadata()
    
    private init () {
        items = populateItems()
        for item in items {
            if (countryPerCode[item.countryCode] == nil || item.mainCountryForCode == true) {
                countryPerCode[item.countryCode] = item.codeID
            }
            codePerCountry[item.codeID] = item.countryCode
        }
    }
    
    var items: [MetadataTerritory] = []
    
    var codePerCountry: [String : UInt64] = [:]
    var countryPerCode: [UInt64 : String] = [:]

    
    // Populate items
    func populateItems() -> [MetadataTerritory] {
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
    
    // MARK: Helpers
    
    // Get the main country corresponding to a given country code
    func mainCountryMetadataForCode(code: UInt64) -> MetadataTerritory? {
        let results = items.filter { $0.countryCode == code}
        if (results.count > 0) {
            var mainResult : MetadataTerritory
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
    
    // Get the countries corresponding to a given country code
    func countriesForCode(code: UInt64) -> [MetadataTerritory]? {
        let results = items.filter { $0.countryCode == code}
        return results
    }
    
    // Get a the country code for a specific country
    func metadataForCountry(country: NSString) -> MetadataTerritory? {
        let results = items.filter { $0.codeID == country.uppercaseString}
        return results.first
    }
    
}

struct MetadataTerritory {
    var generalDesc: MetadataPhoneNumberDesc?
    var fixedLine: MetadataPhoneNumberDesc?
    var mobile: MetadataPhoneNumberDesc?
    var tollFree: MetadataPhoneNumberDesc?
    var premiumRate: MetadataPhoneNumberDesc?
    var sharedCost: MetadataPhoneNumberDesc?
    var personalNumber: MetadataPhoneNumberDesc?
    var voip: MetadataPhoneNumberDesc?
    var pager: MetadataPhoneNumberDesc?
    var uan: MetadataPhoneNumberDesc?
    var emergency: MetadataPhoneNumberDesc?
    var voicemail: MetadataPhoneNumberDesc?
    var codeID: String
    var countryCode: UInt64
    var internationalPrefix: String?
    var nationalPrefix: String?
    var nationalPrefixForParsing: String?
    var nationalPrefixTransformRule: String?
    var mainCountryForCode: Bool = false
}

extension MetadataTerritory {
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

extension MetadataPhoneNumberDesc {
    init(jsondDict: NSDictionary?) {
        self.nationalNumberPattern = jsondDict?.valueForKey("nationalNumberPattern") as? String
        self.possibleNumberPattern = jsondDict?.valueForKey("possibleNumberPattern") as? String
        self.exampleNumber = jsondDict?.valueForKey("exampleNumber") as? String

    }
}

struct MetadataPhoneNumberDesc {
    var nationalNumberPattern: String?
    var possibleNumberPattern: String?
    var exampleNumber: String?

}

struct MetadataPhoneNumberFormat {
    var pattern: String
    var format: String
    var leadingDigitsPatterns: [String]
    var nationalPrefixFormattingRule: String
    var nationalPrefixOptionalWhenFormatting: Bool
    var domesticCarrierCodeFormattingRule: String
}

