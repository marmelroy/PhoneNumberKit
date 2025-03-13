//
//  PhoneNumberUtilityParsingTests.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/10/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

@testable import PhoneNumberKit
import XCTest

final class PhoneNumberUtilityParsingTests: XCTestCase {
    private var sut: PhoneNumberUtility!

    override func setUp() {
        super.setUp()
        sut = PhoneNumberUtility()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFailingNumber() {
        XCTAssertThrowsError(try self.sut.parse("+5491187654321 ABC123", withRegion: "AR")) { error in
            XCTAssertEqual(error as? PhoneNumberError, .invalidNumber)
        }
    }

    func testUSNumberNoPrefix() throws {
        let phoneNumber1 = try sut.parse("650 253 0000", withRegion: "US")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international, withPrefix: false)
        XCTAssertEqual(phoneNumberInternationalFormat1, "650-253-0000")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national, withPrefix: false)
        XCTAssertEqual(phoneNumberNationalFormat1, "(650) 253-0000")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164, withPrefix: false)
        XCTAssertEqual(phoneNumberE164Format1, "6502530000")

        let phoneNumber2 = try sut.parse("800 253 0000", withRegion: "US")
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international, withPrefix: false)
        XCTAssertEqual(phoneNumberInternationalFormat2, "800-253-0000")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national, withPrefix: false)
        XCTAssertEqual(phoneNumberNationalFormat2, "(800) 253-0000")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164, withPrefix: false)
        XCTAssertEqual(phoneNumberE164Format2, "8002530000")
    }

    func testUSNumber() throws {
        let phoneNumber1 = try sut.parse("650 253 0000", withRegion: "US")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+1 650-253-0000")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "(650) 253-0000")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+16502530000")

        let phoneNumber2 = try sut.parse("800 253 0000", withRegion: "US")
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat2, "+1 800-253-0000")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat2, "(800) 253-0000")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format2, "+18002530000")

        let phoneNumber3 = try sut.parse("900 253 0000", withRegion: "US")
        let phoneNumberInternationalFormat3 = self.sut.format(phoneNumber3, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat3, "+1 900-253-0000")
        let phoneNumberNationalFormat3 = self.sut.format(phoneNumber3, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat3, "(900) 253-0000")
        let phoneNumberE164Format3 = self.sut.format(phoneNumber3, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format3, "+19002530000")
    }

    func testBSNumber() throws {
        let phoneNumber1 = try sut.parse("242 365 1234", withRegion: "BS")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+1 242-365-1234")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "(242) 365-1234")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+12423651234")
    }

    func testGBNumber() throws {
        let phoneNumber1 = try sut.parse("(020) 7031 3000", withRegion: "GB")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+44 20 7031 3000")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "020 7031 3000")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+442070313000")

        let phoneNumber2 = try sut.parse("(07912) 345 678", withRegion: "GB")
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat2, "+44 7912 345678")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat2, "07912 345678")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format2, "+447912345678")
    }

    func testDENumber() throws {
        let phoneNumber1 = try sut.parse("0291 12345678", withRegion: "DE")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+49 291 12345678")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "0291 12345678")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+4929112345678")

        let phoneNumber2 = try sut.parse("04134 1234", withRegion: "DE")
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat2, "+49 4134 1234")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat2, "04134 1234")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format2, "+4941341234")

        let phoneNumber3 = try sut.parse("+49 8021 2345", withRegion: "DE")
        let phoneNumberInternationalFormat3 = self.sut.format(phoneNumber3, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat3, "+49 8021 2345")
        let phoneNumberNationalFormat3 = self.sut.format(phoneNumber3, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat3, "08021 2345")
        let phoneNumberE164Format3 = self.sut.format(phoneNumber3, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format3, "+4980212345")
    }

    func testITNumber() throws {
        let phoneNumber1 = try sut.parse("02 3661 8300", withRegion: "IT")
        XCTAssertNotNil(phoneNumber1)
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+39 02 3661 8300")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "02 3661 8300")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+390236618300")
    }

    func testAUNumber() throws {
        let phoneNumber1 = try sut.parse("02 3661 8300", withRegion: "AU")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+61 2 3661 8300")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "(02) 3661 8300")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+61236618300")

        let phoneNumber2 = try sut.parse("+61 1800 123 456", withRegion: "AU")
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat2, "+61 1800 123 456")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat2, "1800 123 456")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format2, "+611800123456")
    }

    func testAllExampleNumbers() {
        let metaDataArray = self.sut.metadataManager.territories.filter { $0.codeID.count == 2 }
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
                (metadata.emergency, nil)
            ]
            metadataWithTypes.forEach { record in
                if let desc = record.0 {
                    if let exampleNumber = desc.exampleNumber {
                        do {
                            let phoneNumber = try sut.parse(exampleNumber, withRegion: codeID)
                            XCTAssertNotNil(phoneNumber)
                            if let type = record.1 {
                                if phoneNumber.type == .fixedOrMobile {
                                    XCTAssert(type == .fixedLine || type == .mobile)
                                } else {
                                    XCTAssertEqual(phoneNumber.type, type, "Expected type \(type) for number \(phoneNumber)")
                                }
                            }
                        } catch let e {
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

    func testUSTollFreeNumberType() throws {
        let number = try sut.parse("8002345678", withRegion: "US")
        XCTAssertEqual(number.type, .tollFree)
    }

    func testBelizeTollFreeType() throws {
        let number = try sut.parse("08001234123", withRegion: "BZ")
        XCTAssertEqual(number.type, .tollFree)
    }

    func testItalyFixedLineType() throws {
        let number = try sut.parse("0669812345", withRegion: "IT")
        XCTAssertEqual(number.type, .fixedLine)
    }

    func testMaldivesMobileNumber() throws {
        let number = try sut.parse("7812345", withRegion: "MV")
        XCTAssertEqual(number.type, .mobile)
    }

    func testZimbabweVoipType() throws {
        let number = try sut.parse("8686123456", withRegion: "ZW")
        XCTAssertEqual(number.type, .voip)
    }

    func testAntiguaPagerNumberType() throws {
        let number = try sut.parse("12684061234", withRegion: "US")
        XCTAssertEqual(number.type, .pager)
    }

    func testFranceMobileNumberType() throws {
        let number = try sut.parse("+33 612-345-678")
        XCTAssertEqual(number.type, .mobile)
    }

    func testAENumberWithHinduArabicNumerals() throws {
        let phoneNumber1 = try sut.parse("+٩٧١٥٠٠٥٠٠٥٥٠", withRegion: "AE")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+971 50 050 0550")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "050 050 0550")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+971500500550")
    }

    func testAENumberWithMixedHinduArabicNumerals() throws {
        let phoneNumber1 = try sut.parse("+٩٧١5٠٠5٠٠55٠", withRegion: "AE")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+971 50 050 0550")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "050 050 0550")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+971500500550")
    }

    func testAENumberWithEasternArabicNumerals() throws {
        let phoneNumber1 = try sut.parse("+۹۷۱۵۰۰۵۰۰۵۵۰", withRegion: "AE")
        XCTAssertNotNil(phoneNumber1)
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+971 50 050 0550")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "050 050 0550")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+971500500550")
    }

    func testAENumberWithMixedEasternArabicNumerals() throws {
        let phoneNumber1 = try sut.parse("+۹۷۱5۰۰5۰۰55۰", withRegion: "AE")
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertEqual(phoneNumberInternationalFormat1, "+971 50 050 0550")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertEqual(phoneNumberNationalFormat1, "050 050 0550")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertEqual(phoneNumberE164Format1, "+971500500550")
    }

    func testPerformanceSimple() {
        let numberOfParses = 1000
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0..<numberOfParses {
            numberArray.append("+5491187654321")
        }
        _ = self.sut.parse(numberArray, withRegion: "AR", ignoreType: true)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 1)
    }

    func testPerformanceNonOptimizedSample() {
        let numberOfParses = 2000
        let startTime = Date()
        var endTime = Date()
        for _ in 0..<numberOfParses {
            _ = try? self.sut.parse("+5491187654321", ignoreType: true)
        }
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 2)
    }

    func testPerformanceWithoutSupplyingDefaultRegion() {
        let numberOfParses = 2000
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0..<numberOfParses {
            numberArray.append("+5491187654321")
        }
        _ = self.sut.parse(numberArray, ignoreType: true)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 2)
    }

    func testPerformanceNonOptimizedParsingUsageWithoutDefaultRegion() throws {
        let numberOfParses = 2000
        let startTime = Date()
        var endTime = Date()
        for _ in 0..<numberOfParses {
            _ = try self.sut.parse("+5491187654321", ignoreType: true)
        }
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 2)
    }

    func testMultipleMutated() {
        let numberOfParses = 500
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0..<numberOfParses {
            numberArray.append("+5491187654321")
        }
        let phoneNumbers = self.sut.parseManager.parseMultiple(numberArray, withRegion: "AR", ignoreType: true)
        XCTAssertTrue(phoneNumbers.count == numberOfParses)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 1)
    }

    func testUANumber() throws {
        let phoneNumber1 = try sut.parse("501887766", withRegion: "UA")
        XCTAssertNotNil(phoneNumber1)
        let phoneNumberInternationalFormat1 = self.sut.format(phoneNumber1, toType: .international)
        XCTAssertTrue(phoneNumberInternationalFormat1 == "+380 50 188 7766")
        let phoneNumberNationalFormat1 = self.sut.format(phoneNumber1, toType: .national)
        XCTAssertTrue(phoneNumberNationalFormat1 == "050 188 7766")
        let phoneNumberE164Format1 = self.sut.format(phoneNumber1, toType: .e164)
        XCTAssertTrue(phoneNumberE164Format1 == "+380501887766")

        let phoneNumber2 = try sut.parse("050 188 7766", withRegion: "UA")
        XCTAssertNotNil(phoneNumber2)
        let phoneNumberInternationalFormat2 = self.sut.format(phoneNumber2, toType: .international)
        XCTAssertTrue(phoneNumberInternationalFormat2 == "+380 50 188 7766")
        let phoneNumberNationalFormat2 = self.sut.format(phoneNumber2, toType: .national)
        XCTAssertTrue(phoneNumberNationalFormat2 == "050 188 7766")
        let phoneNumberE164Format2 = self.sut.format(phoneNumber2, toType: .e164)
        XCTAssertTrue(phoneNumberE164Format2 == "+380501887766")
    }

    func testExtensionWithCommaParsing() throws {
        let number = try sut.parse("+33 612-345-678,22")
        XCTAssertEqual(number.type, .mobile)
        XCTAssertEqual(number.numberExtension, "22")
    }

    func testExtensionWithSemiColonParsing() throws {
        let number = try sut.parse("+33 612-345-678;22")
        XCTAssertEqual(number.type, .mobile)
        XCTAssertEqual(number.numberExtension, "22")
    }

    func testNonAmbiguousPhoneNumber() {
        // This phone number was incorrectly identified as ambiguous.
        let address = "+1 345 916 1234"
        try XCTAssertNotNil(sut.parse(address, withRegion: "JM"))
    }

    func testRegionCountryCodeConflict() {
        XCTAssertThrowsError(try sut.parse("212-2344", withRegion: "US")) { error in
            XCTAssertEqual(error as? PhoneNumberError, .invalidNumber)
        }
        XCTAssertThrowsError(try sut.parse("352-2344", withRegion: "US")) { error in
            XCTAssertEqual(error as? PhoneNumberError, .invalidNumber)
        }
    }
}
