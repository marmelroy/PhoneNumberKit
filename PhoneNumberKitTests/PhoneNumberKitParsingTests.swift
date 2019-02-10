//
//  PhoneNumberKitParsingTests.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

import XCTest
@testable import PhoneNumberKit

class PhoneNumberKitParsingTests: XCTestCase {
    
    let phoneNumberKit = PhoneNumberKit()
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFailingNumber() {
        do {
            _ = try phoneNumberKit.parse("+5491187654321 ABC123", withRegion: "AR")
            XCTFail()
        }
        catch {
            XCTAssertTrue(true)
        }
    }

    func testUSMetadata() {
        let sut = phoneNumberKit.metadataManager.territoriesByCountry["US"]!
        XCTAssertEqual(sut.codeID, "US")
        XCTAssertEqual(sut.countryCode, 1)
        XCTAssertEqual(sut.internationalPrefix, "011")
        XCTAssertEqual(sut.mainCountryForCode, true)
        XCTAssertEqual(sut.nationalPrefix, "1")
        XCTAssertNil(sut.nationalPrefixFormattingRule)
        XCTAssertEqual(sut.nationalPrefixForParsing, "1")
        XCTAssertNil(sut.nationalPrefixTransformRule)
        XCTAssertNil(sut.preferredExtnPrefix)
        let fixedLine = sut.fixedLine!
        XCTAssertEqual(fixedLine.exampleNumber, "2015550123")
        XCTAssertEqual(fixedLine.nationalNumberPattern, "(?:2(?:0[1-35-9]|1[02-9]|2[03-589]|3[149]|4[08]|5[1-46]|6[0279]|7[0269]|8[13])|3(?:0[1-57-9]|1[02-9]|2[0135]|3[0-24679]|4[67]|5[12]|6[014]|8[056])|4(?:0[124-9]|1[02-579]|2[3-5]|3[0245]|4[0235]|58|6[39]|7[0589]|8[04])|5(?:0[1-57-9]|1[0235-8]|20|3[0149]|4[01]|5[19]|6[1-47]|7[013-5]|8[056])|6(?:0[1-35-9]|1[024-9]|2[03689]|[34][016]|5[017]|6[0-279]|78|8[0-2])|7(?:0[1-46-8]|1[2-9]|2[04-7]|3[1247]|4[037]|5[47]|6[02359]|7[02-59]|8[156])|8(?:0[1-68]|1[02-8]|2[08]|3[0-28]|4[3578]|5[046-9]|6[02-5]|7[028])|9(?:0[1346-9]|1[02-9]|2[0589]|3[0146-8]|4[0179]|5[12469]|7[0-389]|8[04-69]))[2-9]\\d{6}")
        XCTAssertNil(fixedLine.possibleNumberPattern)
        let generalDesc = sut.generalDesc!
        XCTAssertNil(generalDesc.exampleNumber)
        XCTAssertEqual(generalDesc.nationalNumberPattern, "[2-9]\\d{9}")
        XCTAssertNil(generalDesc.possibleNumberPattern)
        let mobile = sut.mobile!
        XCTAssertEqual(mobile.exampleNumber, "2015550123")
        XCTAssertEqual(mobile.nationalNumberPattern, "(?:2(?:0[1-35-9]|1[02-9]|2[03-589]|3[149]|4[08]|5[1-46]|6[0279]|7[0269]|8[13])|3(?:0[1-57-9]|1[02-9]|2[0135]|3[0-24679]|4[67]|5[12]|6[014]|8[056])|4(?:0[124-9]|1[02-579]|2[3-5]|3[0245]|4[0235]|58|6[39]|7[0589]|8[04])|5(?:0[1-57-9]|1[0235-8]|20|3[0149]|4[01]|5[19]|6[1-47]|7[013-5]|8[056])|6(?:0[1-35-9]|1[024-9]|2[03689]|[34][016]|5[017]|6[0-279]|78|8[0-2])|7(?:0[1-46-8]|1[2-9]|2[04-7]|3[1247]|4[037]|5[47]|6[02359]|7[02-59]|8[156])|8(?:0[1-68]|1[02-8]|2[08]|3[0-28]|4[3578]|5[046-9]|6[02-5]|7[028])|9(?:0[1346-9]|1[02-9]|2[0589]|3[0146-8]|4[0179]|5[12469]|7[0-389]|8[04-69]))[2-9]\\d{6}")
        XCTAssertNil(mobile.possibleNumberPattern)
        let personalNumber = sut.personalNumber!
        XCTAssertEqual(personalNumber.exampleNumber, "5002345678")
        XCTAssertEqual(personalNumber.nationalNumberPattern, "5(?:00|2[12]|33|44|66|77|88)[2-9]\\d{6}")
        XCTAssertNil(personalNumber.possibleNumberPattern)
        let premiumRate = sut.premiumRate!
        XCTAssertEqual(premiumRate.exampleNumber, "9002345678")
        XCTAssertEqual(premiumRate.nationalNumberPattern, "900[2-9]\\d{6}")
        XCTAssertNil(premiumRate.possibleNumberPattern)
        let tollFree = sut.tollFree!
        XCTAssertEqual(tollFree.exampleNumber, "8002345678")
        XCTAssertEqual(tollFree.nationalNumberPattern, "8(?:00|33|44|55|66|77|88)[2-9]\\d{6}")
        XCTAssertNil(tollFree.possibleNumberPattern)
        let uan = sut.uan!
        XCTAssertEqual(uan.exampleNumber, "7102123456")
        XCTAssertEqual(uan.nationalNumberPattern, "710[2-9]\\d{6}")
        XCTAssertNil(uan.possibleNumberPattern)
        var numberFormats = sut.numberFormats
        let firstNumberFormat: MetadataPhoneNumberFormat = numberFormats[0]
        XCTAssertEqual(firstNumberFormat.pattern, "(\\d{3})(\\d{4})")
        XCTAssertEqual(firstNumberFormat.format, "$1-$2")
        XCTAssertEqual(firstNumberFormat.intlFormat, "NA")
        let firstLeadingDigits = firstNumberFormat.leadingDigitsPatterns!.first
        XCTAssertEqual(firstLeadingDigits, "[2-9]")
        XCTAssertNil(firstNumberFormat.nationalPrefixFormattingRule)
        XCTAssertFalse(firstNumberFormat.nationalPrefixOptionalWhenFormatting!)
        XCTAssertNil(firstNumberFormat.domesticCarrierCodeFormattingRule)
        let secondNumberFormat: MetadataPhoneNumberFormat = numberFormats[1]
        XCTAssertEqual(secondNumberFormat.pattern, "(\\d{3})(\\d{3})(\\d{4})")
        XCTAssertEqual(secondNumberFormat.format, "($1) $2-$3")
        XCTAssertEqual(secondNumberFormat.intlFormat, "$1-$2-$3")
        let secondLeadingDigits = secondNumberFormat.leadingDigitsPatterns!.first
        XCTAssertEqual(secondLeadingDigits, "[2-9]")
        XCTAssertNil(secondNumberFormat.nationalPrefixFormattingRule)
        XCTAssertTrue(secondNumberFormat.nationalPrefixOptionalWhenFormatting!)
        XCTAssertNil(secondNumberFormat.domesticCarrierCodeFormattingRule)
        XCTAssertNil(sut.leadingDigits)
    }
    
    func testUSNumberNoPrefix() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("650 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international, withPrefix: false)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "650-253-0000")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national, withPrefix: false)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(650) 253-0000")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164, withPrefix: false)
            XCTAssertTrue(phoneNumberE164Format1 == "6502530000")
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international, withPrefix: false)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "800-253-0000")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national, withPrefix: false)
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164, withPrefix: false)
            XCTAssertTrue(phoneNumberE164Format2 == "8002530000")
        }
        catch {
            XCTFail()
        }
    }
    
    func testUSNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("650 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 650-253-0000")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(650) 253-0000")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+16502530000")
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+1 800-253-0000")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+18002530000")
            let phoneNumber3 = try phoneNumberKit.parse("900 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+1 900-253-0000")
            let phoneNumberNationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat3 == "(900) 253-0000")
            let phoneNumberE164Format3 = phoneNumberKit.format(phoneNumber3, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format3 == "+19002530000")
        }
        catch {
            XCTFail()
        }
    }
    
    func testBSNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("242 365 1234", withRegion: "BS")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 242-365-1234")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(242) 365-1234")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+12423651234")
        }
        catch {
            XCTFail()
        }
    }
    
    func testGBNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("(020) 7031 3000", withRegion: "GB")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+44 20 7031 3000")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "020 7031 3000")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+442070313000")
            let phoneNumber2 = try phoneNumberKit.parse("(07912) 345 678", withRegion: "GB")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+44 7912 345678")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "07912 345678")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+447912345678")
        }
        catch {
            XCTFail()
        }
    }
    
    func testDENumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("0291 12345678", withRegion: "DE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+49 291 12345678")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "0291 12345678")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+4929112345678")
            let phoneNumber2 = try phoneNumberKit.parse("04134 1234", withRegion: "DE")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+49 4134 1234")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "04134 1234")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+4941341234")
            let phoneNumber3 = try phoneNumberKit.parse("+49 8021 2345", withRegion: "DE")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+49 8021 2345")
            let phoneNumberNationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat3 == "08021 2345")
            let phoneNumberE164Format3 = phoneNumberKit.format(phoneNumber3, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format3 == "+4980212345")
        }
        catch {
            XCTFail()
        }
    }
    
    func testITNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("02 3661 8300", withRegion: "IT")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+39 02 3661 8300")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "02 3661 8300")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+390236618300")
        }
        catch {
            XCTFail()
        }
    }
    
    func testAUNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("02 3661 8300", withRegion: "AU")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+61 2 3661 8300")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(02) 3661 8300")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+61236618300")
            let phoneNumber2 = try phoneNumberKit.parse("+61 1800 123 456", withRegion: "AU")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+61 1800 123 456")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "1800 123 456")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+611800123456")
        }
        catch {
            XCTFail()
        }
    }
    
    func testAllExampleNumbers() {
        let metaDataArray = phoneNumberKit.metadataManager.territories.filter{$0.codeID.count == 2}
        for metadata in metaDataArray {
            let codeID = metadata.codeID
            let metadataWithTypes: [(MetadataPhoneNumberDesc?, PhoneNumberType?)] = [
                (metadata.generalDesc, nil),
                (metadata.fixedLine, .fixedLine),
                (metadata.mobile, .mobile),
                (metadata.tollFree, .tollFree),
                (metadata.premiumRate, .premiumRate),
                (metadata.sharedCost, .sharedCost),
                (metadata.voip, .voip),
                (metadata.voicemail, .voicemail),
                (metadata.pager, .pager),
                (metadata.uan, .uan),
                (metadata.emergency, nil),
            ]
            metadataWithTypes.forEach { record in
                if let desc = record.0 {
                    if let exampleNumber = desc.exampleNumber {
                        do {
                            let phoneNumber = try phoneNumberKit.parse(exampleNumber, withRegion: codeID)
                            XCTAssertNotNil(phoneNumber)
                            if let type = record.1 {
                                if phoneNumber.type == .fixedOrMobile {
                                    XCTAssert(type == .fixedLine || type == .mobile)
                                } else {
                                    XCTAssertEqual(phoneNumber.type, type, "Expected type \(type) for number \(phoneNumber)")
                                }
                            }
                        } catch (let e) {
                            XCTFail("Failed to create PhoneNumber for \(exampleNumber): \(e)")
                        }
                    }
                }
            }
        }
    }

    func testRegexMatchesEntirely() {
        let pattern = "[2-9]\\d{8}|860\\d{9}"
        let number = "860123456789"
        let regex = RegexManager()
        XCTAssert(regex.matchesEntirely(pattern, string: number))
        XCTAssertFalse(regex.matchesEntirely("8", string: number))
    }

    func testUSTollFreeNumberType() {
        guard let number = try? phoneNumberKit.parse("8002345678", withRegion: "US") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.tollFree)
    }

    func testBelizeTollFreeType() {
        guard let number = try? phoneNumberKit.parse("08001234123", withRegion: "BZ") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.tollFree)
    }

    func testItalyFixedLineType() {
        guard let number = try? phoneNumberKit.parse("0669812345", withRegion: "IT") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.fixedLine)
    }

    func testMaldivesMobileNumber() {
        guard let number = try? phoneNumberKit.parse("7812345", withRegion: "MV") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.mobile)
    }

    func testZimbabweVoipType() {
        guard let number = try? phoneNumberKit.parse("8686123456", withRegion: "ZW") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.voip)

    }

    func testAntiguaPagerNumberType() {
        guard let number = try? phoneNumberKit.parse("12684061234", withRegion: "US") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.pager)
    }

    func testFranceMobileNumberType() {
        guard let number = try? phoneNumberKit.parse("+33 612-345-678") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.mobile)
    }

    func testPerformanceSimple() {
        let numberOfParses = 1000
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0 ..< numberOfParses {
            numberArray.append("+5491187654321")
        }
        _ = phoneNumberKit.parse(numberArray, withRegion: "AR", ignoreType: true)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertTrue(timeInterval < 5)
    }

    func testMultipleMutated() {
        let numberOfParses = 500
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0 ..< numberOfParses {
            numberArray.append("+5491187654321")
        }
        let phoneNumbers = phoneNumberKit.parseManager.parseMultiple(numberArray, withRegion: "AR", ignoreType: true) {
            numberArray.remove(at: 100)
        }
        XCTAssertTrue(phoneNumbers.count == numberOfParses)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
    }

    func testUANumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("380501887766", withRegion: "UA")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+380 50 188 7766")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "050 188 7766")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+380501887766")
            let phoneNumber2 = try phoneNumberKit.parse("050 188 7766", withRegion: "UA")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+380 50 188 7766")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "050 188 7766")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+380501887766")
            let phoneNumber3 = try phoneNumberKit.parse("050 188 7766", withRegion: "UA")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+380 50 188 7766")
            let phoneNumberNationalFormat3 = phoneNumberKit.format(phoneNumber3, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat3 == "050 188 7766")
            let phoneNumberE164Format3 = phoneNumberKit.format(phoneNumber3, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format3 == "+380501887766")
        }
        catch {
            XCTFail()
        }
    }

}
