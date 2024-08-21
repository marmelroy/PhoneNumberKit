//
//  MetadataParsing.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 2019-02-10.
//  Copyright © 2019 Roy Marmelstein. All rights reserved.
//

import Foundation

// MARK: - MetadataTerritory

public extension MetadataTerritory {
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Custom parsing logic
        codeID = try container.decode(String.self, forKey: .codeID)
        let code = try! container.decode(String.self, forKey: .countryCode)
        countryCode = UInt64(code)!
        mainCountryForCode = container.decodeBoolString(forKey: .mainCountryForCode)
        let possibleNationalPrefixForParsing: String? = try container.decodeIfPresent(String.self, forKey: .nationalPrefixForParsing)
        let possibleNationalPrefix: String? = try container.decodeIfPresent(String.self, forKey: .nationalPrefix)
        nationalPrefix = possibleNationalPrefix
        let nationalPrefixForParsing = (possibleNationalPrefixForParsing == nil && possibleNationalPrefix != nil) ? nationalPrefix : possibleNationalPrefixForParsing
        self.nationalPrefixForParsing = nationalPrefixForParsing != nil ? nationalPrefixForParsing!.replacingOccurrences(of: "\\", with: #"\\"#) : nil
        nationalPrefixFormattingRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixFormattingRule)
        let availableFormats = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .availableFormats)
        let temporaryFormatList: [MetadataPhoneNumberFormat] = availableFormats?.decodeArrayOrObject(forKey: .numberFormats) ?? [MetadataPhoneNumberFormat]()
        numberFormats = temporaryFormatList.withDefaultNationalPrefixFormattingRule(nationalPrefixFormattingRule)

        // Default parsing logic
        internationalPrefix = try container.decodeIfPresent(String.self, forKey: .internationalPrefix)
        nationalPrefixTransformRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixTransformRule)
        preferredExtnPrefix = try container.decodeIfPresent(String.self, forKey: .preferredExtnPrefix)
        emergency = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .emergency)
        fixedLine = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .fixedLine)
        generalDesc = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .generalDesc)
        mobile = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .mobile)
        pager = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .pager)
        personalNumber = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .personalNumber)
        premiumRate = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .premiumRate)
        sharedCost = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .sharedCost)
        tollFree = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .tollFree)
        voicemail = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .voicemail)
        voip = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .voip)
        uan = try container.decodeIfPresent(MetadataPhoneNumberDesc.self, forKey: .uan)
        leadingDigits = try container.decodeIfPresent(String.self, forKey: .leadingDigits)
    }
}

// MARK: - MetadataPhoneNumberFormat

public extension MetadataPhoneNumberFormat {
    enum CodingKeys: String, CodingKey {
        case pattern
        case format
        case intlFormat
        case leadingDigitsPatterns = "leadingDigits"
        case nationalPrefixFormattingRule
        case nationalPrefixOptionalWhenFormatting
        case domesticCarrierCodeFormattingRule = "carrierCodeFormattingRule"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Custom parsing logic
        leadingDigitsPatterns = container.decodeArrayOrObject(forKey: .leadingDigitsPatterns)
        nationalPrefixOptionalWhenFormatting = container.decodeBoolString(forKey: .nationalPrefixOptionalWhenFormatting)

        // Default parsing logic
        pattern = try container.decodeIfPresent(String.self, forKey: .pattern)
        format = try container.decodeIfPresent(String.self, forKey: .format)
        intlFormat = try container.decodeIfPresent(String.self, forKey: .intlFormat)
        nationalPrefixFormattingRule = try container.decodeIfPresent(String.self, forKey: .nationalPrefixFormattingRule)
        domesticCarrierCodeFormattingRule = try container.decodeIfPresent(String.self, forKey: .domesticCarrierCodeFormattingRule)
    }
}

// MARK: - PhoneNumberMetadata

extension PhoneNumberMetadata {
    enum CodingKeys: String, CodingKey {
        case phoneNumberMetadata
        case territories
        case territory
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let metadataObject = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .phoneNumberMetadata)
        let territoryObject = try metadataObject.nestedContainer(keyedBy: CodingKeys.self, forKey: .territories)
        territories = try territoryObject.decode([MetadataTerritory].self, forKey: .territory)
    }
}

// MARK: - Parsing helpers

private extension KeyedDecodingContainer where K: CodingKey {
    /// Decodes a string to a boolean. Returns false if empty.
    ///
    /// - Parameter key: Coding key to decode
    func decodeBoolString(forKey key: KeyedDecodingContainer<K>.Key) -> Bool {
        guard let value: String = try? self.decode(String.self, forKey: key) else {
            return false
        }
        return Bool(value) ?? false
    }

    /// Decodes either a single object or an array into an array. Returns an empty array if empty.
    ///
    /// - Parameter key: Coding key to decode
    func decodeArrayOrObject<T: Decodable>(forKey key: KeyedDecodingContainer<K>.Key) -> [T] {
        guard let array: [T] = try? self.decode([T].self, forKey: key) else {
            guard let object: T = try? self.decode(T.self, forKey: key) else {
                return [T]()
            }
            return [object]
        }
        return array
    }
}

private extension Collection where Element == MetadataPhoneNumberFormat {
    func withDefaultNationalPrefixFormattingRule(_ nationalPrefixFormattingRule: String?) -> [Element] {
        return self.map { format -> MetadataPhoneNumberFormat in
            var modifiedFormat = format
            if modifiedFormat.nationalPrefixFormattingRule == nil {
                modifiedFormat.nationalPrefixFormattingRule = nationalPrefixFormattingRule
            }
            return modifiedFormat
        }
    }
}
