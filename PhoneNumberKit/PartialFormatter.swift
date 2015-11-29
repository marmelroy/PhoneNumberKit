//
//  PartialFormatter.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class PartialFormatter {
    
    let metadata = Metadata.sharedInstance
    let parser = PhoneNumberParser()
    let regex = RegularExpressions.sharedInstance

    /**
     Partial number formatter
     - Parameter rawNumber: Phone number object.
     - Parameter region: Default region code.
     - Returns: Modified national number ready for display.
     */
    func formatPartial(rawNumber: String, region: String) throws -> String {
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercaseString
        // Extract number (2)
        var nationalNumber = rawNumber
        // Country code parse (3)
        if (self.metadata.metadataPerCountry[region] == nil) {
            throw PNParsingError.InvalidCountryCode
        }
        var regionMetaData =  self.metadata.metadataPerCountry[region]!
        var countryCode: UInt64 = 0
        do {
            countryCode = try self.parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData)
        }
        catch {
            do {
                let plusRemovedNumberString = self.regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try self.parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetaData)
            }
            catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if (countryCode == 0) {
            countryCode = regionMetaData.countryCode
        }
        // Nomralized number (5)
        nationalNumber = self.parser.normalizePhoneNumber(nationalNumber)
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetaData.countryCode {
            regionMetaData = self.metadata.metadataPerCode[countryCode]!
        }
        // National Prefix Strip (7)
        self.parser.stripNationalPrefix(&nationalNumber, metadata: regionMetaData)
        
        print("\(countryCode) and \(nationalNumber)")
        return "BOOM"
    }
    
}