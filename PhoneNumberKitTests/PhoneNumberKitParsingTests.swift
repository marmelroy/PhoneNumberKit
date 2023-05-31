//
//  PhoneNumberKitParsingTests.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 29/10/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import Foundation

@testable import PhoneNumberKit
import XCTest

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
            _ = try self.phoneNumberKit.parse("+5491187654321 ABC123", withRegion: "AR")
            XCTFail()
        } catch {
            XCTAssertTrue(true)
        }
    }

    func testUSNumberNoPrefix() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("650 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international, withPrefix: false)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "650-253-0000")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national, withPrefix: false)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(650) 253-0000")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164, withPrefix: false)
            XCTAssertTrue(phoneNumberE164Format1 == "6502530000")
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .international, withPrefix: false)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "800-253-0000")
            let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .national, withPrefix: false)
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2, toType: .e164, withPrefix: false)
            XCTAssertTrue(phoneNumberE164Format2 == "8002530000")
        } catch {
            XCTFail()
        }
    }

    func testUSNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("650 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 650-253-0000")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(650) 253-0000")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+16502530000")
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+1 800-253-0000")
            let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+18002530000")
            let phoneNumber3 = try phoneNumberKit.parse("900 253 0000", withRegion: "US")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = self.phoneNumberKit.format(phoneNumber3, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+1 900-253-0000")
            let phoneNumberNationalFormat3 = self.phoneNumberKit.format(phoneNumber3, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat3 == "(900) 253-0000")
            let phoneNumberE164Format3 = self.phoneNumberKit.format(phoneNumber3, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format3 == "+19002530000")
        } catch {
            XCTFail()
        }
    }

    func testBSNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("242 365 1234", withRegion: "BS")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 242-365-1234")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(242) 365-1234")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+12423651234")
        } catch {
            XCTFail()
        }
    }

    func testGBNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("(020) 7031 3000", withRegion: "GB")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+44 20 7031 3000")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "020 7031 3000")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+442070313000")
            let phoneNumber2 = try phoneNumberKit.parse("(07912) 345 678", withRegion: "GB")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+44 7912 345678")
            let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "07912 345678")
            let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+447912345678")
        } catch {
            XCTFail()
        }
    }

    func testDENumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("0291 12345678", withRegion: "DE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+49 291 12345678")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "0291 12345678")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+4929112345678")
            let phoneNumber2 = try phoneNumberKit.parse("04134 1234", withRegion: "DE")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+49 4134 1234")
            let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "04134 1234")
            let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+4941341234")
            let phoneNumber3 = try phoneNumberKit.parse("+49 8021 2345", withRegion: "DE")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = self.phoneNumberKit.format(phoneNumber3, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+49 8021 2345")
            let phoneNumberNationalFormat3 = self.phoneNumberKit.format(phoneNumber3, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat3 == "08021 2345")
            let phoneNumberE164Format3 = self.phoneNumberKit.format(phoneNumber3, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format3 == "+4980212345")
        } catch {
            XCTFail()
        }
    }

    func testITNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("02 3661 8300", withRegion: "IT")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+39 02 3661 8300")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "02 3661 8300")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+390236618300")
        } catch {
            XCTFail()
        }
    }

    func testAUNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("02 3661 8300", withRegion: "AU")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+61 2 3661 8300")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "(02) 3661 8300")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+61236618300")
            let phoneNumber2 = try phoneNumberKit.parse("+61 1800 123 456", withRegion: "AU")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+61 1800 123 456")
            let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "1800 123 456")
            let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+611800123456")
        } catch {
            XCTFail()
        }
    }

    func testAllExampleNumbers() {
        let metaDataArray = self.phoneNumberKit.metadataManager.territories.filter { $0.codeID.count == 2 }
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

    func testAENumberWithHinduArabicNumerals() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("+٩٧١٥٠٠٥٠٠٥٥٠", withRegion: "AE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+971 50 050 0550")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "050 050 0550")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+971500500550")
        } catch {
            XCTFail()
        }
    }

    func testAENumberWithMixedHinduArabicNumerals() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("+٩٧١5٠٠5٠٠55٠", withRegion: "AE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+971 50 050 0550")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "050 050 0550")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+971500500550")
        } catch {
            XCTFail()
        }
    }

    func testAENumberWithEasternArabicNumerals() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("+۹۷۱۵۰۰۵۰۰۵۵۰", withRegion: "AE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+971 50 050 0550")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "050 050 0550")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+971500500550")
        } catch {
            XCTFail()
        }
    }

    func testAENumberWithMixedEasternArabicNumerals() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("+۹۷۱5۰۰5۰۰55۰", withRegion: "AE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+971 50 050 0550")
            let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "050 050 0550")
            let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+971500500550")
        } catch {
            XCTFail()
        }
    }
    
    func testPerformanceSimple() {
        let numberOfParses = 1000
        let startTime = Date()
        var endTime = Date()
        var numberArray: [String] = []
        for _ in 0..<numberOfParses {
            numberArray.append("+5491187654321")
        }
        _ = self.phoneNumberKit.parse(numberArray, withRegion: "AR", ignoreType: true)
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
            _ = try? self.phoneNumberKit.parse("+5491187654321", ignoreType: true)
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
        _ = self.phoneNumberKit.parse(numberArray, ignoreType: true)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 2)
    }
    
    func testPerformanceNonOptimizedParsingUsageWithoutDefaultRegion() {
        let numberOfParses = 2000
        let startTime = Date()
        var endTime = Date()
        for _ in 0..<numberOfParses {
            _ = try? self.phoneNumberKit.parse("+5491187654321", ignoreType: true)
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
        let phoneNumbers = self.phoneNumberKit.parseManager.parseMultiple(numberArray, withRegion: "AR", ignoreType: true)
        XCTAssertTrue(phoneNumbers.count == numberOfParses)
        endTime = Date()
        let timeInterval = endTime.timeIntervalSince(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertLessThan(timeInterval, 1)
    }

    func testUANumber() {
        let phoneNumber1 = try? phoneNumberKit.parse("501887766", withRegion: "UA")
        XCTAssertNotNil(phoneNumber1)
        let phoneNumberInternationalFormat1 = self.phoneNumberKit.format(phoneNumber1!, toType: .international)
        XCTAssertTrue(phoneNumberInternationalFormat1 == "+380 50 188 7766")
        let phoneNumberNationalFormat1 = self.phoneNumberKit.format(phoneNumber1!, toType: .national)
        XCTAssertTrue(phoneNumberNationalFormat1 == "050 188 7766")
        let phoneNumberE164Format1 = self.phoneNumberKit.format(phoneNumber1!, toType: .e164)
        XCTAssertTrue(phoneNumberE164Format1 == "+380501887766")
        
        let phoneNumber2 = try? phoneNumberKit.parse("050 188 7766", withRegion: "UA")
        XCTAssertNotNil(phoneNumber2)
        let phoneNumberInternationalFormat2 = self.phoneNumberKit.format(phoneNumber2!, toType: .international)
        XCTAssertTrue(phoneNumberInternationalFormat2 == "+380 50 188 7766")
        let phoneNumberNationalFormat2 = self.phoneNumberKit.format(phoneNumber2!, toType: .national)
        XCTAssertTrue(phoneNumberNationalFormat2 == "050 188 7766")
        let phoneNumberE164Format2 = self.phoneNumberKit.format(phoneNumber2!, toType: .e164)
        XCTAssertTrue(phoneNumberE164Format2 == "+380501887766")
    }
    
    func testExtensionWithCommaParsing() {
        guard let number = try? phoneNumberKit.parse("+33 612-345-678,22") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.mobile)
        XCTAssertEqual(number.numberExtension, "22")
    }
    
    func testExtensionWithSemiColonParsing() {
        guard let number = try? phoneNumberKit.parse("+33 612-345-678;22") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.mobile)
        XCTAssertEqual(number.numberExtension, "22")
    }

    func testNonAmbiguousPhoneNumber() {
        // This phone number was incorrectly identified as ambiguous.
        let address = "+1 345 916 1234"
        try XCTAssertNotNil(phoneNumberKit.parse(address, withRegion: "JM"))
    }
    
    func testRegionCountryCodeConflict() {
        XCTAssertThrowsError(try phoneNumberKit.parse("212-2344", withRegion: "US")) { error in
            XCTAssertEqual(error as? PhoneNumberError, PhoneNumberError.invalidNumber)
        }
        XCTAssertThrowsError(try phoneNumberKit.parse("352-2344", withRegion: "US")) { error in
            XCTAssertEqual(error as? PhoneNumberError, PhoneNumberError.invalidNumber)
        }
    }
}
