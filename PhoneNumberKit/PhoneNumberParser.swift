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
        var rawNumber: String = ""
        var leadingZero: Bool = false
        var numberExtension: String?
    }
    
    func parsePhoneNumber(rawNumber: String, region: String) throws -> InternalPhoneNumber {
        let phoneNumber = InternalPhoneNumber()
        phoneNumber.rawNumber = rawNumber
        
        var nationalNumber = rawNumber
        let matches = try regex.phoneDataDetectorMatches(rawNumber)
        if let phoneNumber = matches.first?.phoneNumber {
            nationalNumber = phoneNumber
        }
        
        let extn = stripExtension(&nationalNumber)
        if let numberExtension = extn {
            phoneNumber.numberExtension = numberExtension
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
        
        nationalNumber = normalizePhoneNumber(nationalNumber)

        // Length Validations
        
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
        stripNationalPrefix(&nationalNumber, metadata: regionMetaData!)
        
        let generalNumberDesc = regionMetaData!.generalDesc
        if (regex.hasValue(generalNumberDesc!.nationalNumberPattern) == false || isNumberMatchingDesc(nationalNumber, numberDesc: generalNumberDesc!) == false) {
            throw PNParsingError.NotANumber
        }

        phoneNumber.leadingZero = nationalNumber.hasPrefix("0")
        phoneNumber.nationalNumber = UInt64(nationalNumber)!
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
    func extractPossibleNumber(number: String) -> String {
        let nsString = number as NSString
        var possibleNumber : String = ""
        let start = regex.stringPositionByRegex(PNValidStartPattern, string: number as String)
        if (start >= 0)
        {
            possibleNumber = nsString.substringFromIndex(start)
            possibleNumber = regex.replaceStringByRegex(PNUnwantedEndPattern, string: possibleNumber as String)
            let secondNumberStart = regex.stringPositionByRegex(PNSecondNumberStartPattern, string: number as String)
            if (secondNumberStart > 0) {
                possibleNumber = possibleNumber.substringWithNSRange(NSMakeRange(0, secondNumberStart - 1))
            }
        }
        return possibleNumber
    }

    // Extract potential country code
    func extractPotentialCountryCode(fullNumber: String, inout nationalNumber: String) -> UInt64? {
        let nsFullNumber = fullNumber as NSString
        if ((nsFullNumber.length == 0) || (nsFullNumber.substringToIndex(1) == "0")) {
            return 0
        }
        let numberLength = nsFullNumber.length
        var maxCountryCode = PNMaxLengthCountryCode
        if (fullNumber.hasPrefix("+")) {
            maxCountryCode = PNMaxLengthCountryCode + 1
        }
        for var i = 1; i <= maxCountryCode && i <= numberLength; i++ {
            let stringRange = NSMakeRange(0, i)
            let subNumber = nsFullNumber.substringWithRange(stringRange)
            let potentialCountryCode = UInt64(subNumber)
            let regionCodes = metadata.metadataPerCode[potentialCountryCode!]
            if (regionCodes != nil) {
                nationalNumber = nsFullNumber.substringFromIndex(i)
                return potentialCountryCode
            }
        }
        return 0
    }
    
    // Extract country code
    func extractCountryCode(number: String, inout nationalNumber: String, metadata: MetadataTerritory) throws -> UInt64 {
        var fullNumber = number
        let possibleCountryIddPrefix = metadata.internationalPrefix
        let countryCodeSource = stripInternationalPrefixAndNormalize(&fullNumber, possibleIddPrefix: possibleCountryIddPrefix)
        if (countryCodeSource != .DefaultCountry) {
            if (fullNumber.characters.count <= PNMinLengthForNSN) {
                throw PNParsingError.TooShort
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
                let nsFullNumber = fullNumber as NSString
                var potentialNationalNumber = nsFullNumber.substringFromIndex(defaultCountryCode.characters.count)
                let validNumberPattern = metadata.generalDesc?.nationalNumberPattern
                stripNationalPrefix(&potentialNationalNumber, metadata: metadata)
                let potentialNationalNumberStr = potentialNationalNumber.copy()
                let possibleNumberPattern = metadata.generalDesc?.possibleNumberPattern
                if ((!regex.matchesEntirely(validNumberPattern!, string: fullNumber as String) && regex.matchesEntirely(validNumberPattern!, string: potentialNationalNumberStr as! String)) || regex.testStringLengthAgainstPattern(possibleNumberPattern!, string: fullNumber as String) == PNValidationResult.TooLong) {
                    nationalNumber = potentialNationalNumberStr as! String
                    return UInt64(defaultCountryCode)!
                }
            }
        }
        throw PNParsingError.NotANumber
    }
    
    // Extract number type
    func extractNumberType(nationalNumber: String, countryCode: UInt64) -> PNPhoneNumberType {
        let metadata : MetadataTerritory =  Metadata.sharedInstance.metadataPerCode[countryCode]!
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
    func checkRegionForParsing(rawNumber: String, defaultRegion: String) -> Bool {
        return (metadata.metadataPerCountry[defaultRegion] != nil)
    }
    
    // MARK: Parse
    
    // Try and parse prefix as IDD
    func parsePrefixAsIdd(inout number: String, iddPattern: String) -> Bool {
        if (regex.stringPositionByRegex(iddPattern, string: number) == 0) {
            do {
                let nsString = number as NSString
                let matched = try regex.regexMatches(iddPattern as String, string: number as String).first
                let matchedString = number.substringWithNSRange(matched!.range)
                let matchEnd = matchedString.characters.count
                let remainString : NSString = nsString.substringFromIndex(matchEnd)
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
                number = remainString as String
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
    func stripExtension(inout number: String) -> String? {
        do {
            let matches = try regex.regexMatches("\\;(.*)", string: number)
            if let match = matches.first {
                let adjustedRange = NSMakeRange(match.range.location + 1, match.range.length - 1)
                let matchString = number.substringWithNSRange(adjustedRange)
                let stringRange = NSMakeRange(0, match.range.location)
                number = number.substringWithNSRange(stringRange)
                return matchString
            }
            return nil
        }
        catch {
            return nil
        }
    }
    
    // Strip international prefix
    func stripInternationalPrefixAndNormalize(inout number: String, possibleIddPrefix: String?) -> PNCountryCodeSource {
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

