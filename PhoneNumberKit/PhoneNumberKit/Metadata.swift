//
//  Metadata.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 03/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public struct MetadataPhoneNumberDesc {
    var nationalNumberPattern: String
    var possibleNumberPattern: String
    var exampleNumber: String
}

public struct MetadataPhoneNumberFormat {
    var pattern: String
    var format: String
    var leadingDigitsPatterns: [String]
    var nationalPrefixFormattingRule: String
    var nationalPrefixOptionalWhenFormatting: Bool
    var domesticCarrierCodeFormattingRule: String
}

public struct MetadataTerritory {
    var generalDesc: MetadataPhoneNumberDesc
    var fixedLine: MetadataPhoneNumberDesc
    var mobile: MetadataPhoneNumberDesc
    var tollFree: MetadataPhoneNumberDesc
    var premiumRate: MetadataPhoneNumberDesc
    var sharedCost: MetadataPhoneNumberDesc
    var personalNumber: MetadataPhoneNumberDesc
    var voip: MetadataPhoneNumberDesc
    var pager: MetadataPhoneNumberDesc
    var uan: MetadataPhoneNumberDesc
    var emergency: MetadataPhoneNumberDesc
    var voicemail: MetadataPhoneNumberDesc
    var noInternationalDialling: MetadataPhoneNumberDesc
    var codeID: String
    var countryCode: UInt
    var internationalPrefix: String
    var preferredInternationalPrefix: String
    var nationalPrefix: String
    var preferredExtnPrefix: String
    var nationalPrefixForParsing: String
    var nationalPrefixTransformRule: String
    var sameMobileAndFixedLinePattern: Bool
    var numberFormats: [MetadataPhoneNumberFormat]
    var intlNumberFormats: [MetadataPhoneNumberFormat]
    var mainCountryForCode: Bool
    var leadingDigits: String
    var leadingZeroPossible: Bool
}

extension MetadataTerritory {
    init(dictionary: NSDictionary) {
        self.id = managedTask.valueForKey("id") as! String
        self.title = managedTask.valueForKey("title") as! String
        self.dueDate = managedTask.valueForKey("dueDate") as! NSDate
    }
}