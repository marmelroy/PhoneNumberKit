//
//  ParseManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 01/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

/**
Manager for parsing flow.
*/
class ParseManager {
    
    weak var metadataManager: MetadataManager?
    let parser: PhoneNumberParser
    weak var regexManager: RegexManager?

    init(metadataManager: MetadataManager, regexManager: RegexManager) {
        self.metadataManager = metadataManager
        self.parser = PhoneNumberParser(regex: regexManager, metadata: metadataManager)
        self.regexManager = regexManager
    }
    
    private var multiParseArray = SynchronizedArray<PhoneNumber>()
    
    /**
    Parse a string into a phone number object with a custom region. Can throw.
    - Parameter numberString: String to be parsed to phone number struct.
    - Parameter region: ISO 639 compliant region code.
    */
    func parsePhoneNumber(_ numberString: String, withRegion region: String) throws -> PhoneNumber {
        guard let metadataManager = metadataManager, let regexManager = regexManager else { throw PhoneNumberError.generalError }
        // Make sure region is in uppercase so that it matches metadata (1)
        let region = region.uppercased()
        // Extract number (2)
        var nationalNumber = numberString
        let matches = try regexManager.phoneDataDetectorMatches(numberString)
        if let phoneNumber = matches.first?.phoneNumber {
            nationalNumber = phoneNumber
        }
        // Strip and extract extension (3)
        let numberExtension = parser.stripExtension(&nationalNumber)
        // Country code parse (4)
        guard var regionMetadata =  metadataManager.territoriesByCountry[region] else {
            throw PhoneNumberError.invalidCountryCode
        }
        var countryCode: UInt64 = 0
        do {
            countryCode = try parser.extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetadata)
        }
        catch {
            do {
                let plusRemovedNumberString = regexManager.replaceStringByRegex(PhoneNumberPatterns.leadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try parser.extractCountryCode(plusRemovedNumberString, nationalNumber: &nationalNumber, metadata: regionMetadata)
            }
            catch {
                throw PhoneNumberError.invalidCountryCode
            }
        }
        if countryCode == 0 {
            countryCode = regionMetadata.countryCode
        }
        // Nomralized number (5)
        let normalizedNationalNumber = parser.normalizePhoneNumber(nationalNumber)
        nationalNumber = normalizedNationalNumber
        // If country code is not default, grab correct metadata (6)
        if countryCode != regionMetadata.countryCode, let countryMetadata = metadataManager.territoriesByCode[countryCode] {
            regionMetadata = countryMetadata
        }
        // National Prefix Strip (7)
        parser.stripNationalPrefix(&nationalNumber, metadata: regionMetadata)
		
        // Test number against general number description for correct metadata (8)
        if let generalNumberDesc = regionMetadata.generalDesc, (regexManager.hasValue(generalNumberDesc.nationalNumberPattern) == false || parser.isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            throw PhoneNumberError.notANumber
        }
        // Finalize remaining parameters and create phone number object (9)
        let leadingZero = nationalNumber.hasPrefix("0")
        guard let finalNationalNumber = UInt64(nationalNumber) else{
            throw PhoneNumberError.notANumber
        }
        
        let type = parser.checkNumberType(String(nationalNumber), metadata: regionMetadata, leadingZero: leadingZero)
        if type == .unknown {
            throw PhoneNumberError.unknownType
        }
        let phoneNumber = PhoneNumber(numberString: numberString, countryCode: countryCode, leadingZero: leadingZero, nationalNumber: finalNationalNumber, numberExtension: numberExtension, type: type)
        return phoneNumber
    }
    
    // Parse task
    
    /**
    Fastest way to parse an array of phone numbers. Uses custom region code.
    - Parameter numberStrings: An array of raw number strings.
    - Parameter region: ISO 639 compliant region code.
    - Returns: An array of valid PhoneNumber objects.
    */
    func parseMultiple(_ numberStrings: [String], withRegion region: String, testCallback: (()->())? = nil) -> [PhoneNumber] {
        self.multiParseArray = SynchronizedArray<PhoneNumber>()
        let queue = OperationQueue()
        var operationArray: [ParseOperation<PhoneNumber>] = []
        let completionOperation = ParseOperation<Bool>()
        completionOperation.onStart { asyncOp in
            asyncOp.finish(with: true)
        }
        completionOperation.whenFinished { asyncOp in
        }
        for (index, numberString) in numberStrings.enumerated() {
            let parseTask = parseOperation(numberString, withRegion:region)
            parseTask.whenFinished { operation in
                if let phoneNumber = operation.output.value {
                    self.multiParseArray.append(phoneNumber)
                }
            }
            operationArray.append(parseTask)
            completionOperation.addDependency(parseTask)
            if index == numberStrings.count/2 {
                testCallback?()
            }
        }
        queue.addOperations(operationArray, waitUntilFinished: false)
        queue.addOperations([completionOperation], waitUntilFinished: true)
        let localMultiParseArray = self.multiParseArray
        return localMultiParseArray.array
    }
    
    /**
     Single parsing task, used as an element of parseMultiple.
     - Parameter rawNumbers: An array of raw number strings.
     - Parameter region: ISO 639 compliant region code.
     - Returns: Parse operation with an implementation handler and no completion handler.
     */
    func parseOperation(_ numberString: String, withRegion region: String) -> ParseOperation<PhoneNumber> {
        let operation = ParseOperation<PhoneNumber>()
        operation.onStart { asyncOp in
            let phoneNumber = try self.parsePhoneNumber(numberString, withRegion: region)
            asyncOp.finish(with: phoneNumber)
        }
        return operation
    }
    
    func checkNumberType(_ phoneNumber: PhoneNumber) -> PhoneNumberType {
        guard let region = self.getRegionCodeForNumber(nationalNumber: phoneNumber.nationalNumber, countryCode: phoneNumber.countryCode, leadingZero: phoneNumber.leadingZero) else {
            return .unknown
        }
        guard let metadata = metadataManager?.filterTerritories(byCountry: region) else {
            return .unknown
        }
        return parser.checkNumberType(String(phoneNumber.nationalNumber), metadata: metadata, leadingZero: phoneNumber.leadingZero)
    }
    
    func getRegionCodeForNumber(nationalNumber: UInt64, countryCode: UInt64, leadingZero: Bool) -> String? {
        guard let regexManager = regexManager, let metadataManager = metadataManager else { return nil }

        let regions = metadataManager.territories.filter { $0.countryCode == countryCode }
        if regions.count == 1 {
            return regions[0].codeID
        }

        let nationalNumberString = String(nationalNumber)
        for region in regions {
            if let leadingDigits = region.leadingDigits {
                if regexManager.matchesAtStart(leadingDigits, string: nationalNumberString) {
                    return region.codeID
                }
            }
            if leadingZero && parser.checkNumberType("0" + nationalNumberString, metadata: region) != .unknown {
                return region.codeID
            }
            if parser.checkNumberType(nationalNumberString, metadata: region) != .unknown {
                return region.codeID
            }
        }
        return nil
    }

}

/**
Thread safe Swift array generic that locks on write.
*/
class SynchronizedArray<T> {
    var array: [T] = []
    private let accessQueue = DispatchQueue(label: "SynchronizedArrayAccess")
    func append(_ newElement: T) {
        self.accessQueue.async {
            self.array.append(newElement)
        }
    }
}
