//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

struct MetadataPhoneNumberDesc {
    var nationalNumberPattern: String?
    var possibleNumberPattern: String?
}

struct MetadataPhoneNumberFormat {
    var pattern: String
    var format: String
    var leadingDigitsPatterns: [String]
    var nationalPrefixFormattingRule: String
    var nationalPrefixOptionalWhenFormatting: Bool
    var domesticCarrierCodeFormattingRule: String
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
    var countryCode: UInt
    var internationalPrefix: String?
    var nationalPrefixForParsing: String?
    var nationalPrefixTransformRule: String?
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
        self.countryCode = UInt(jsondDict.valueForKey("_countryCode") as! String)!
        self.internationalPrefix = jsondDict.valueForKey("_internationalPrefix") as? String
        self.nationalPrefixForParsing = jsondDict.valueForKey("_nationalPrefixForParsing") as? String
        self.nationalPrefixTransformRule = jsondDict.valueForKey("_nationalPrefixTransformRule") as? String
    }
}

extension MetadataPhoneNumberDesc {
    init(jsondDict: NSDictionary?) {
        let nationalNumberPattern = jsondDict?.valueForKey("nationalNumberPattern") as? String
        let possibleNumberPattern = jsondDict?.valueForKey("possibleNumberPattern") as? String
        if (nationalNumberPattern != nil) {
            let trimmedNationalNumberPattern = nationalNumberPattern!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.nationalNumberPattern = trimmedNationalNumberPattern
        }
        if (possibleNumberPattern != nil) {
            let trimmedpossibleNumberPattern = possibleNumberPattern!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            self.possibleNumberPattern = trimmedpossibleNumberPattern
        }
    }
}