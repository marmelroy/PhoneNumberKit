//
//  MetadataTypes.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 02/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation


/// Internal object for metadata parsing
internal struct PhoneNumberMetadata: Decodable {
    enum CodingKeys: String, CodingKey {
        case phoneNumberMetadata
        case territories
        case territory
    }
    var territories: [MetadataTerritory]

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metadataObject = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .phoneNumberMetadata)
        let territoryObject = try metadataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .territories)
        territories = try territoryObject.decode([MetadataTerritory].self, forKey: .territory)
    }
}

/**
MetadataTerritory object
- Parameter codeID: ISO 639 compliant region code
- Parameter countryCode: International country code
- Parameter internationalPrefix: International prefix. Optional.
- Parameter mainCountryForCode: Whether the current metadata is the main country for its country code.
- Parameter nationalPrefix: National prefix
- Parameter nationalPrefixFormattingRule: National prefix formatting rule
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
- Parameter leadingDigits: Optional leading digits for the territory
*/
struct MetadataTerritory: Decodable {
    enum CodingKeys: String, CodingKey {
        case codeID = "id"
        case countryCode
        case internationalPrefix
        case mainCountryForCode
        case nationalPrefix
        case nationalPrefixFormattingRule
        case nationalPrefixForParsing
        case nationalPrefixTransformRule
        case preferredExtnPrefix
        case emergency
        case fixedLine
        case generalDesc
        case mobile
        case pager
        case personalNumber
        case premiumRate
        case sharedCost
        case tollFree
        case voicemail
        case voip
        case uan
        case numberFormats = "numberFormat"
        case leadingDigits
        case availableFormats
    }

    let codeID: String
    let countryCode: UInt64
    let internationalPrefix: String?
    let mainCountryForCode: Bool
    let nationalPrefix: String?
    let nationalPrefixFormattingRule: String?
    let nationalPrefixForParsing: String?
    let nationalPrefixTransformRule: String?
    let preferredExtnPrefix: String?
    let emergency: MetadataPhoneNumberDesc?
    let fixedLine: MetadataPhoneNumberDesc?
    let generalDesc: MetadataPhoneNumberDesc?
    let mobile: MetadataPhoneNumberDesc?
    let pager: MetadataPhoneNumberDesc?
    let personalNumber: MetadataPhoneNumberDesc?
    let premiumRate: MetadataPhoneNumberDesc?
    let sharedCost: MetadataPhoneNumberDesc?
    let tollFree: MetadataPhoneNumberDesc?
    let voicemail: MetadataPhoneNumberDesc?
    let voip: MetadataPhoneNumberDesc?
    let uan: MetadataPhoneNumberDesc?
    let numberFormats: [MetadataPhoneNumberFormat]
    let leadingDigits: String?
}

extension MetadataTerritory {

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        codeID = try container.decode(String.self, forKey: .codeID)
        let code = try! container.decode(String.self, forKey: .countryCode)
        countryCode = UInt64(code)!
        internationalPrefix = try? container.decode(String.self, forKey: .internationalPrefix)
        mainCountryForCode = parseBoolStringOrEmpty(container: container, codingKey: .mainCountryForCode)
        let possibleNationalPrefixForParsing: String? = try? container.decode(String.self, forKey: .nationalPrefixForParsing)
        let possibleNationalPrefix: String? = try? container.decode(String.self, forKey: .nationalPrefix)
        nationalPrefix = possibleNationalPrefix
        nationalPrefixForParsing = (possibleNationalPrefixForParsing == nil && possibleNationalPrefix != nil) ? nationalPrefix : possibleNationalPrefixForParsing
        nationalPrefixFormattingRule = try? container.decode(String.self, forKey: .nationalPrefixFormattingRule)
        nationalPrefixTransformRule = try? container.decode(String.self, forKey: .nationalPrefixTransformRule)
        preferredExtnPrefix = try? container.decode(String.self, forKey: .preferredExtnPrefix)
        emergency = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .emergency)
        fixedLine = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .fixedLine)
        generalDesc = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .generalDesc)
        mobile = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .mobile)
        pager = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .pager)
        personalNumber = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .personalNumber)
        premiumRate = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .premiumRate)
        sharedCost = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .sharedCost)
        tollFree = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .tollFree)
        voicemail = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .voicemail)
        voip = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .voip)
        uan = try? container.decode(MetadataPhoneNumberDesc.self, forKey: .uan)
        do {
            let availableFormats = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .availableFormats)
            let temporaryFormatList: [MetadataPhoneNumberFormat] = parseArrayOrObject(container: availableFormats, codingKey: .numberFormats)
            var processedNumberFormats = [MetadataPhoneNumberFormat]()
            for format in temporaryFormatList {
                var modifiedFormat = format
                if modifiedFormat.nationalPrefixFormattingRule == nil {
                    modifiedFormat.nationalPrefixFormattingRule = self.nationalPrefixFormattingRule
                }
                processedNumberFormats.append(modifiedFormat)
            }
            numberFormats = processedNumberFormats
        } catch {
            numberFormats = [MetadataPhoneNumberFormat]()
        }
        leadingDigits = try? container.decode(String.self, forKey: .leadingDigits)
    }
}


/**
MetadataPhoneNumberDesc object
- Parameter exampleNumber: An example phone number for the given type. Optional.
- Parameter nationalNumberPattern:  National number regex pattern. Optional.
- Parameter possibleNumberPattern:  Possible number regex pattern. Optional.
*/
struct MetadataPhoneNumberDesc: Decodable {
    let exampleNumber: String?
    let nationalNumberPattern: String?
    let possibleNumberPattern: String?
}

/**
 MetadataPhoneNumberFormat object
 - Parameter pattern: Regex pattern. Optional.
 - Parameter format: Formatting template. Optional.
 - Parameter intlFormat: International formatting template. Optional.

 - Parameter leadingDigitsPatterns: Leading digits regex pattern. Optional.
 - Parameter nationalPrefixFormattingRule: National prefix formatting rule. Optional.
 - Parameter nationalPrefixOptionalWhenFormatting: National prefix optional bool. Optional.
 - Parameter domesticCarrierCodeFormattingRule: Domestic carrier code formatting rule. Optional.
 */
struct MetadataPhoneNumberFormat: Decodable {
    enum CodingKeys: String, CodingKey {
        case pattern
        case format
        case intlFormat
        case leadingDigitsPatterns = "leadingDigits"
        case nationalPrefixFormattingRule
        case nationalPrefixOptionalWhenFormatting
        case domesticCarrierCodeFormattingRule = "carrierCodeFormattingRule"
    }

    let pattern: String?
    let format: String?
    let intlFormat: String?
    let leadingDigitsPatterns: [String]?
    var nationalPrefixFormattingRule: String?
    let nationalPrefixOptionalWhenFormatting: Bool?
    let domesticCarrierCodeFormattingRule: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pattern = try? container.decode(String.self, forKey: .pattern)
        format = try? container.decode(String.self, forKey: .format)
        intlFormat = try? container.decode(String.self, forKey: .intlFormat)
        leadingDigitsPatterns = parseArrayOrObject(container: container, codingKey: .leadingDigitsPatterns)
        nationalPrefixFormattingRule = try? container.decode(String.self, forKey: .nationalPrefixFormattingRule)
        nationalPrefixOptionalWhenFormatting = parseBoolStringOrEmpty(container: container, codingKey: .nationalPrefixOptionalWhenFormatting)
        domesticCarrierCodeFormattingRule = try? container.decode(String.self, forKey: .domesticCarrierCodeFormattingRule)
    }
}

//MARK: Parsing helpers

private func parseArrayOrObject<T: Decodable, Key: CodingKey>(container: KeyedDecodingContainer<Key>, codingKey: Key) -> [T]
{
    guard let array: [T] = try? container.decode([T].self, forKey: codingKey) else {
        guard let object: T = try? container.decode(T.self, forKey: codingKey) else {
            return [T]()
        }
        return [object]
    }
    return array
}

private func parseBoolStringOrEmpty<Key: CodingKey>(container: KeyedDecodingContainer<Key>, codingKey: Key) -> Bool {
    guard let value: String = try? container.decode(String.self, forKey: codingKey) else {
        return false
    }
    return Bool(value) ?? false
}
