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
            let phoneNumber1 = try phoneNumberKit.parse("+5491187654321 ABC123", withRegion: "AR")
            XCTAssertNotNil(phoneNumber1)
        }
        catch {
            XCTFail()
        }
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
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000")
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
            let phoneNumber2 = try phoneNumberKit.parse("800 253 0000")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+1 800-253-0000")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+18002530000")
            let phoneNumber3 = try phoneNumberKit.parse("900 253 0000")
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
    //
    func testARNumber() {
        do {
            let phoneNumber1 = try phoneNumberKit.parse("011 8765-4321", withRegion: "AR")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+54 11 8765-4321")
            let phoneNumberNationalFormat1 = phoneNumberKit.format(phoneNumber1, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat1 == "011 8765-4321")
            let phoneNumberE164Format1 = phoneNumberKit.format(phoneNumber1, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format1 == "+541187654321")
            let phoneNumber2 = try phoneNumberKit.parse("011 15 8765-4321", withRegion: "AR")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .international)
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+54 9 11 8765-4321")
            let phoneNumberNationalFormat2 = phoneNumberKit.format(phoneNumber2, toType: .national)
            XCTAssertTrue(phoneNumberNationalFormat2 == "011 15-8765-4321")
            let phoneNumberE164Format2 = phoneNumberKit.format(phoneNumber2, toType: .e164)
            XCTAssertTrue(phoneNumberE164Format2 == "+5491187654321")
        }
        catch {
            XCTFail()
        }
    }
    
    func testAllExampleNumbers() {
        let metaDataArray = phoneNumberKit.metadataManager.territories.filter{$0.codeID.characters.count == 2}
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
        guard let number = try? phoneNumberKit.parse("8002345678") else {
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

    func testMaldivesPagerNumber() {
        guard let number = try? phoneNumberKit.parse("7812345", withRegion: "MV") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.pager)
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
//
//    func testPerformanceSimple() {
//        let numberOfParses = 1000
//        let startTime = Date()
//        var endTime = Date()
//        var numberArray: [String] = []
//        for _ in 0 ..< numberOfParses {
//            numberArray.append("+5491187654321")
//        }
//        _ = phoneNumberKit.parse(numberArray, withRegion: "AR")
//        endTime = Date()
//        let timeInterval = endTime.timeIntervalSince(startTime)
//        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
//        XCTAssertTrue(timeInterval < 5)
//    }

//    func testMultipleMutated() {
//        let numberOfParses = 500
//        let startTime = Date()
//        var endTime = Date()
//        var numberArray: [String] = []
//        for _ in 0 ..< numberOfParses {
//            numberArray.append("+5491187654321")
//        }
//        let phoneNumbers = phoneNumberKit.parseManager.parseMultiple(numberArray, withRegion: "AR") {
//            numberArray.remove(at: 100)
//        }
//        XCTAssertTrue(phoneNumbers.count == numberOfParses)
//        endTime = Date()
//        let timeInterval = endTime.timeIntervalSince(startTime)
//        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
//    }


}
