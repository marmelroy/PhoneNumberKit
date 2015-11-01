//
//  PhoneNumberParser.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

class PhoneNumberParser {
    
    let regex = RegularExpressions.sharedInstance
    
    let metadata = Metadata.sharedInstance
    
    let queue = NSOperationQueue()
    
    class InternalPhoneNumber {
        var countryCode: UInt64 = 0
        var nationalNumber: UInt64 = 0
        var numberExtension: String?
        var rawNumber: String = ""
        var leadingZero: Bool = false
    }
    
    func parsePhoneNumber(rawNumber: String, region: String) throws -> InternalPhoneNumber {
        let phoneNumber = InternalPhoneNumber()
        phoneNumber.rawNumber = rawNumber
        
        var nationalNumber : NSString = rawNumber as NSString
        let matches = try regex.phoneDataDetectorMatches(rawNumber)
        if (matches.count > 0) {
            let firstMatch = matches.first
            nationalNumber = rawNumber.substringWithNSRange(firstMatch!.range)
        }
        
//        let validateRawNumber = ParseOperation<String, Bool>()
        
//        validateRawNumber.setin = rawNumber
//
//        validateRawNumber.onStart { asyncOp in
//            let rawNumber = asyncOp.input.value!
//            if (rawNumber.isEmpty) {
//                throw PNParsingError.NotANumber
//            } else if (rawNumber.characters.count > PNMaxInputStringLength) {
//                throw PNParsingError.TooLong
//            }
//
//            let dataTask = NSURLSession.sharedSessi
//            on().dataTaskWithURL(imageURL) { data, _, error in
//                if let data = data, image = UIImage(data: data) {
//                    asyncOp.finish(with: image)
//                } else {
//                    asyncOp.finish(with: error ?? AsyncOpError.Unspecified)
//                }
//            }
//            dataTask.resume()
//        }
//        
//        validateRawNumber.whenFinished { operation in
//            print(operation.output)
//        }

//        
//        if (checkRegionForParsing(nationalNumber, defaultRegion: region) == false) {
//            throw PNParsingError.InvalidCountryCode
//        }
        
        // Extension parsing
        let extn = stripExtension(&nationalNumber)
        if (extn != nil && extn?.characters.count > 0) {
            phoneNumber.numberExtension = extn
        }
        
        // Country code parsing
        var regionMetaData =  metadata.metadataPerCountry[region]
        var countryCode : UInt64 = 0
        do {
            countryCode = try extractCountryCode(nationalNumber, nationalNumber: &nationalNumber, metadata: regionMetaData!)
            phoneNumber.countryCode = countryCode
        } catch {
            do {
                let plusRemovedNumebrString = RegularExpressions.sharedInstance.replaceStringByRegex(PNLeadingPlusCharsPattern, string: nationalNumber as String)
                countryCode = try extractCountryCode(plusRemovedNumebrString, nationalNumber: &nationalNumber, metadata: regionMetaData!)
                phoneNumber.countryCode = countryCode
            } catch {
                throw PNParsingError.InvalidCountryCode
            }
        }
        if (countryCode == 0) {
            phoneNumber.countryCode = regionMetaData!.countryCode
        }

        // Length Validations
        var normalizedNationalNumber = normalizePhoneNumber(nationalNumber as String)
        
        // If country code is not default, grab countrycode metadata
        if (phoneNumber.countryCode != regionMetaData!.countryCode) {
        // Don't look up
            let countryMetadata = metadata.metadataPerCode[phoneNumber.countryCode]
            if  (countryMetadata == nil) {
                throw PNParsingError.InvalidCountryCode
            }
            regionMetaData = countryMetadata
        }
        
        // National Prefix Strip
        stripNationalPrefix(&normalizedNationalNumber, metadata: regionMetaData!)
        
        let generalNumberDesc = regionMetaData!.generalDesc
        if (regex.hasValue(generalNumberDesc!.nationalNumberPattern) == false || isNumberMatchingDesc(normalizedNationalNumber, numberDesc: generalNumberDesc!) == false) {
            throw PNParsingError.NotANumber
        }

//        phoneNumber.type = extractNumberType(normalizedNationalNumber, metadata: regionMetaData!)
//        if (phoneNumber.type == PNPhoneNumberType.Unknown) {
//            throw PNParsingError.NotANumber
//        }
        phoneNumber.leadingZero = normalizedNationalNumber.hasPrefix("0")
        phoneNumber.nationalNumber = UInt64(normalizedNationalNumber)!
        return phoneNumber
    }

    
    // MARK: Normalizations

    // Normalize phone number
    func normalizePhoneNumber(number: String) -> String {
        return regex.stringByReplacingOccurrences(number, map: PNAllNormalizationMappings, removeNonMatches: true)!
    }

    // Normalize non breaking space
    func normalizeNonBreakingSpace(string: String) -> String {
        return string.stringByReplacingOccurrencesOfString(PNNonBreakingSpace, withString: " ")
    }

    // MARK: Extractions
    
    // Extract possible number from string
    func extractPossibleNumber(number: NSString) -> NSString {
        var possibleNumber : NSString = ""
        let start = regex.stringPositionByRegex(PNValidStartPattern, string: number as String)
        if (start >= 0)
        {
            possibleNumber = number.substringFromIndex(start)
            possibleNumber = regex.replaceStringByRegex(PNUnwantedEndPattern, string: possibleNumber as String)
            let secondNumberStart = regex.stringPositionByRegex(PNSecondNumberStartPattern, string: number as String)
            if (secondNumberStart > 0) {
                possibleNumber = possibleNumber.substringWithRange(NSMakeRange(0, secondNumberStart - 1))
            }
        }
        return possibleNumber
    }

    // Extract potential country code
    func extractPotentialCountryCode(var fullNumber: NSString, inout nationalNumber: NSString) -> UInt64? {
        fullNumber = normalizeNonBreakingSpace(fullNumber as String) as NSString
        if ((fullNumber.length == 0) || (fullNumber.substringToIndex(1) == "0")) {
            return 0
        }
        let numberLength = fullNumber.length
        var maxCountryCode = PNMaxLengthCountryCode
        if (fullNumber.hasPrefix("+")) {
            maxCountryCode = PNMaxLengthCountryCode + 1
        }
        for var i = 1; i <= maxCountryCode && i <= numberLength; i++ {
            let stringRange = NSMakeRange(0, i)
            let subNumber = fullNumber.substringWithRange(stringRange)
            let potentialCountryCode = UInt64(subNumber)
            let regionCodes = metadata.metadataPerCode[potentialCountryCode!]
            if (regionCodes != nil) {
                nationalNumber = fullNumber.substringFromIndex(i)
                return potentialCountryCode
            }
        }
        return 0
    }
    
    // Extract country code
    func extractCountryCode(number: NSString, inout nationalNumber: NSString, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix)
        if (countryCodeSource != .DefaultCountry) {
            if (fullNumber.length <= PNMinLengthForNSN) {
                return 0
            }
            let potentialCountryCode = extractPotentialCountryCode(fullNumber, nationalNumber: &nationalNumber)
            if (potentialCountryCode != 0) {
                return potentialCountryCode!
            }
            else {
                throw PNParsingError.InvalidCountryCode
            }
        }
        else {
            let defaultCountryCode = String(metadata.countryCode)
            if (fullNumber.hasPrefix(defaultCountryCode)) {
                var potentialNationalNumber = fullNumber.substringFromIndex(defaultCountryCode.characters.count)
                let validNumberPattern = metadata.generalDesc?.nationalNumberPattern
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = potentialNationalNumber.copy()
                let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern
                if ((!regex.matchesEntirely(validNumberPattern!, string: fullNumber as String) && regex.matchesEntirely(validNumberPattern!, string: potentialNationalNumberStr as! String)) || regex.testStringLengthAgainstPattern(possibleNumberPattern!, string: fullNumber as String) == PNValidationResult.TooLong) {
                    nationalNumber = potentialNationalNumberStr as! NSString
                    return UInt64(defaultCountryCode)!
                }
            }
        }
        return 0
    }
    
    // Extract number type
    func extractNumberType(nationalNumber: String, metadata: MetadataTerritory) -> PNPhoneNumberType {
        let generalNumberDesc = metadata.generalDesc!
        if (regex.hasValue(generalNumberDesc.nationalNumberPattern) == false || isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc) == false) {
            return PNPhoneNumberType.Unknown
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.fixedLine)) {
            return PNPhoneNumberType.FixedLine
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.mobile)) {
            return PNPhoneNumberType.Mobile
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.premiumRate)) {
            return PNPhoneNumberType.PremiumRate
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.tollFree)) {
            return PNPhoneNumberType.TollFree
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.sharedCost)) {
            return PNPhoneNumberType.SharedCost
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voip)) {
            return PNPhoneNumberType.VOIP
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.personalNumber)) {
            return PNPhoneNumberType.PersonalNumber
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.pager)) {
            return PNPhoneNumberType.Pager
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.uan)) {
            return PNPhoneNumberType.UAN
        }
        if (isNumberMatchingDesc(nationalNumber, numberDesc: metadata.voicemail)) {
            return PNPhoneNumberType.Voicemail
        }
        return PNPhoneNumberType.Unknown
    }
    
    func isNumberMatchingDesc(nationalNumber: String, numberDesc: MetadataPhoneNumberDesc?) -> Bool {
        if (numberDesc == nil) {
            return false
        }
        let metadataDesc = numberDesc!
        if (regex.hasValue(metadataDesc.possibleNumberPattern) == false || metadataDesc.possibleNumberPattern == "NA") {
            return regex.matchesEntirely(metadataDesc.nationalNumberPattern, string: nationalNumber)
        }
        if (regex.hasValue(metadataDesc.nationalNumberPattern) == false || metadataDesc.nationalNumberPattern == "NA") {
            return regex.matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber)
        }
        return regex.matchesEntirely(metadataDesc.possibleNumberPattern, string: nationalNumber) || regex.matchesEntirely(metadataDesc.nationalNumberPattern, string: nationalNumber)
    }

    
    // MARK: Validations

    // Check if number is viable
//    func isViablePhoneNumber(number: String) -> Bool {
//        let numberToParse = normalizeNonBreakingSpace(number)
//        if (numberToParse.characters.count < PNMinLengthForNSN) {
//            return false;
//        }
//        return regex.matchesEntirely(PNValidPhoneNumberPattern, string: number)
//    }
    
    // Check region is valid for parsing
    func checkRegionForParsing(rawNumber: NSString, defaultRegion: String) -> Bool {
        return (metadata.metadataPerCountry[defaultRegion] != nil)
    }
    
    // MARK: Parse
    
    // Try and parse prefix as IDD
    func parsePrefixAsIdd(inout number: NSString, iddPattern: NSString) -> Bool {
        if (regex.stringPositionByRegex(iddPattern as String, string: number as String) == 0) {
            do {
                let matched = try regex.regexMatches(iddPattern as String, string: number as String).first
                let matchedString = number.substringWithRange(matched!.range)
                let matchEnd = matchedString.characters.count
                let remainString : NSString = number.substringFromIndex(matchEnd)
                let capturingDigitPatterns = try NSRegularExpression(pattern: PNCapturingDigitPattern, options:NSRegularExpressionOptions.CaseInsensitive)
                let matchedGroups = capturingDigitPatterns.matchesInString(remainString as String, options: [], range: NSMakeRange(0, remainString.length))
                if (matchedGroups.count > 0 && matchedGroups.first != nil) {
                    let digitMatched = remainString.substringWithRange(matchedGroups.first!.range) as NSString
                    if (digitMatched.length > 0) {
                        let normalizedGroup =  regex.stringByReplacingOccurrences(digitMatched as String, map: PNAllNormalizationMappings, removeNonMatches: true)
                        if (normalizedGroup == "0") {
                            return false
                        }
                    }
                }
                number = remainString
                return true
                
            }
            catch {
                return false
            }
        }
        return false
    }

    // MARK: Strip helpers
    
    // Strip extension
    func stripExtension(inout number: NSString) -> String? {
        let mStart = regex.stringPositionByRegex(PNExtnPattern, string: number as String)
        if (mStart >= 0) {
            do {
                let firstMatch = try regex.regexMatches(PNExtnPattern, string: number as String).first
                let matchedGroupsLength = firstMatch!.numberOfRanges
                for var i = 1; i < matchedGroupsLength; i++ {
                    let curRange = firstMatch?.rangeAtIndex(i)
                    if (curRange?.location != NSNotFound && curRange?.location < number.length) {
                        let matchString = number.substringWithRange(curRange!)
                        let stringRange = NSMakeRange(0, mStart)
                        number = number.substringWithRange(stringRange)
                        return matchString
                    }
                }
            }
            catch {
            }
        }
        return nil
    }
    
    // Strip international prefix
    func stripInternationalPrefixAndNormalize(inout number: NSString, possibleIddPrefix: NSString?) -> PNCountryCodeSource {
        if (regex.matchesAtStart(PNLeadingPlusCharsPattern, string: number as String)) {
            number = regex.replaceStringByRegex(PNLeadingPlusCharsPattern, string: number as String)
            return .NumberWithPlusSign
        }
        number = normalizePhoneNumber(number as String)
        if (possibleIddPrefix != nil) {
            let prefixResult = parsePrefixAsIdd(&number, iddPattern: possibleIddPrefix!)
            if (prefixResult == true) {
                return .NumberWithIDD
            }
            else {
                return .DefaultCountry
            }
        }
        return .NumberWithoutPlusSign
    }
    
    // Strip national prefix
    func stripNationalPrefix(inout number: String, metadata: MetadataTerritory) {
        if (metadata.nationalPrefixForParsing != nil) {
            let possibleNationalPrefix = metadata.nationalPrefixForParsing!
            let prefixPattern = String(format: "^(?:%@)", possibleNationalPrefix)
            do {
                let matches = try regex.regexMatches(prefixPattern, string: number)
                if (matches.isEmpty == false) {
                    let nationalNumberRule = metadata.generalDesc?.nationalNumberPattern
                    let firstMatch = matches.first
                    let firstMatchString = number.substringWithNSRange(firstMatch!.range)
                    let numOfGroups = firstMatch!.numberOfRanges - 1
                    let transformRule = metadata.nationalPrefixTransformRule
                    var transformedNumber : String = String()
                    let firstRange = firstMatch?.rangeAtIndex(numOfGroups)
                    let firstMatchStringWithGroup = (firstRange!.location != NSNotFound && firstRange!.location < number.characters.count) ? number.substringWithNSRange(firstRange!) :  String()
                    let noTransform = (transformRule == nil || transformRule?.characters.count == 0 || regex.hasValue(firstMatchStringWithGroup) == false)
                    if (noTransform ==  true) {
                        let index = number.startIndex.advancedBy(firstMatchString.characters.count)
                        transformedNumber = number.substringFromIndex(index)
                    }
                    else {
                        transformedNumber = regex.replaceFirstStringByRegex(prefixPattern, string: number, templateString: transformRule!)
                    }
                    if (regex.hasValue(nationalNumberRule!) && regex.matchesEntirely(nationalNumberRule!, string: number) && regex.matchesEntirely(nationalNumberRule!, string: transformedNumber) == false){
                        return
                    }
                    number = transformedNumber
                    return
                }
            }
            catch {
                return
            }
        }
    }

    
}

