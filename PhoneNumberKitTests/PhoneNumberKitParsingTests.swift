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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testFailingNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "+5491187654321 ABC123", region: "AR")
            XCTAssertNotNil(phoneNumber1)
        }
        catch {
            XCTFail()
        }
    }
    
    func testUSNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "650 253 0000", region: "US")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 650-253-0000")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "(650) 253-0000")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+16502530000")
            let phoneNumber2 = try PhoneNumber(rawNumber: "800 253 0000")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumber2.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+1 800-253-0000")
            let phoneNumberNationalFormat2 = phoneNumber2.toNational()
            XCTAssertTrue(phoneNumberNationalFormat2 == "(800) 253-0000")
            let phoneNumberE164Format2 = phoneNumber2.toE164()
            XCTAssertTrue(phoneNumberE164Format2 == "+18002530000")
            let phoneNumber3 = try PhoneNumber(rawNumber: "900 253 0000")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = phoneNumber3.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+1 900-253-0000")
            let phoneNumberNationalFormat3 = phoneNumber3.toNational()
            XCTAssertTrue(phoneNumberNationalFormat3 == "(900) 253-0000")
            let phoneNumberE164Format3 = phoneNumber3.toE164()
            XCTAssertTrue(phoneNumberE164Format3 == "+19002530000")
        }
        catch {
            XCTFail()
        }
    }
    
    func testBSNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "242 365 1234", region: "BS")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+1 242-365-1234")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "(242) 365-1234")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+12423651234")
        }
        catch {
            XCTFail()
        }
    }
    
    func testGBNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "(020) 7031 3000", region: "GB")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+44 20 7031 3000")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "020 7031 3000")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+442070313000")
            let phoneNumber2 = try PhoneNumber(rawNumber: "(07912) 345 678", region: "GB")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumber2.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+44 7912 345678")
            let phoneNumberNationalFormat2 = phoneNumber2.toNational()
            XCTAssertTrue(phoneNumberNationalFormat2 == "07912 345678")
            let phoneNumberE164Format2 = phoneNumber2.toE164()
            XCTAssertTrue(phoneNumberE164Format2 == "+447912345678")
        }
        catch {
            XCTFail()
        }
    }
    
    func testDENumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "0291 12345678", region: "DE")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+49 291 12345678")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "0291 12345678")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+4929112345678")
            let phoneNumber2 = try PhoneNumber(rawNumber: "04134 1234", region: "DE")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumber2.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+49 4134 1234")
            let phoneNumberNationalFormat2 = phoneNumber2.toNational()
            XCTAssertTrue(phoneNumberNationalFormat2 == "04134 1234")
            let phoneNumberE164Format2 = phoneNumber2.toE164()
            XCTAssertTrue(phoneNumberE164Format2 == "+4941341234")
            let phoneNumber3 = try PhoneNumber(rawNumber: "+49 8021 2345", region: "DE")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumberInternationalFormat3 = phoneNumber3.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat3 == "+49 8021 2345")
            let phoneNumberNationalFormat3 = phoneNumber3.toNational()
            XCTAssertTrue(phoneNumberNationalFormat3 == "08021 2345")
            let phoneNumberE164Format3 = phoneNumber3.toE164()
            XCTAssertTrue(phoneNumberE164Format3 == "+4980212345")
        }
        catch {
            XCTFail()
        }
    }
    
    func testITNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "02 3661 8300", region: "IT")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+39 02 3661 8300")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "02 3661 8300")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+390236618300")
        }
        catch {
            XCTFail()
        }
    }
    
    func testAUNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "02 3661 8300", region: "AU")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+61 2 3661 8300")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "(02) 3661 8300")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+61236618300")
            let phoneNumber2 = try PhoneNumber(rawNumber: "+61 1800 123 456", region: "AU")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumber2.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+61 1800 123 456")
            let phoneNumberNationalFormat2 = phoneNumber2.toNational()
            XCTAssertTrue(phoneNumberNationalFormat2 == "1800 123 456")
            let phoneNumberE164Format2 = phoneNumber2.toE164()
            XCTAssertTrue(phoneNumberE164Format2 == "+611800123456")
        }
        catch {
            XCTFail()
        }
    }
    //
    func testARNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "011 8765-4321", region: "AR")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumberInternationalFormat1 = phoneNumber1.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat1 == "+54 11 8765-4321")
            let phoneNumberNationalFormat1 = phoneNumber1.toNational()
            XCTAssertTrue(phoneNumberNationalFormat1 == "011 8765-4321")
            let phoneNumberE164Format1 = phoneNumber1.toE164()
            XCTAssertTrue(phoneNumberE164Format1 == "+541187654321")
            let phoneNumber2 = try PhoneNumber(rawNumber: "011 15 8765-4321", region: "AR")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumberInternationalFormat2 = phoneNumber2.toInternational()
            XCTAssertTrue(phoneNumberInternationalFormat2 == "+54 9 11 8765-4321")
            let phoneNumberNationalFormat2 = phoneNumber2.toNational()
            XCTAssertTrue(phoneNumberNationalFormat2 == "011 15-8765-4321")
            let phoneNumberE164Format2 = phoneNumber2.toE164()
            XCTAssertTrue(phoneNumberE164Format2 == "+5491187654321")
        }
        catch {
            XCTFail()
        }
    }
    
    func testAllExampleNumbers() {
        let metaDataArray = PhoneNumberKit().metadata.items.filter{$0.codeID.characters.count == 2}
        for metadata in metaDataArray {
            let codeID = metadata.codeID
            let metadataWithTypes: [(MetadataPhoneNumberDesc?, PhoneNumberType?)] = [
                (metadata.generalDesc, nil),
                (metadata.fixedLine, .FixedLine),
                (metadata.mobile, .Mobile),
                (metadata.tollFree, .TollFree),
                (metadata.premiumRate, .PremiumRate),
                (metadata.sharedCost, .SharedCost),
                (metadata.voip, .VOIP),
                (metadata.voicemail, .Voicemail),
                (metadata.pager, .Pager),
                (metadata.uan, .UAN),
                (metadata.emergency, nil),
            ]
            metadataWithTypes.forEach { record in
                if let desc = record.0 {
                    if let exampleNumber = desc.exampleNumber {
                        do {
                            let phoneNumber = try PhoneNumber(rawNumber: exampleNumber, region: codeID)
                            XCTAssertNotNil(phoneNumber)
                            if let type = record.1 {
                                if phoneNumber.type == .FixedOrMobile {
                                    XCTAssert(type == .FixedLine || type == .Mobile)
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
        let regex = RegularExpressions.sharedInstance
        XCTAssert(regex.matchesEntirely(pattern, string: number))
        XCTAssertFalse(regex.matchesEntirely("8", string: number))
    }

    func testUSTollFreeNumberType() {
        guard let number = try? PhoneNumber(rawNumber: "8002345678") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.TollFree)
    }

    func testBelizeTollFreeType() {
        guard let number = try? PhoneNumber(rawNumber: "08001234123", region: "BZ") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.TollFree)
    }

    func testItalyFixedLineType() {
        guard let number = try? PhoneNumber(rawNumber: "0669812345", region: "IT") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.FixedLine)
    }

    func testMaldivesPagerNumber() {
        guard let number = try? PhoneNumber(rawNumber: "7812345", region: "MV") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.Pager)
    }

    func testZimbabweVoipType() {
        guard let number = try? PhoneNumber(rawNumber: "8686123456", region: "ZW") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.VOIP)

    }

    func testAntiguaPagerNumberType() {
        guard let number = try? PhoneNumber(rawNumber: "12684061234") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.Pager)
    }

    func testFranceMobileNumberType() {
        guard let number = try? PhoneNumber(rawNumber: "+33 612-345-678") else {
            XCTFail()
            return
        }
        XCTAssertEqual(number.type, PhoneNumberType.Mobile)
    }

    func testPerformanceSimple() {
        let numberOfParses = 1000
        let startTime = NSDate()
        var endTime = NSDate()
        var numberArray: [String] = []
        for _ in 0 ..< numberOfParses {
            numberArray.append("+5491187654321")
        }
        let phoneNumbers = PhoneNumberKit().parseMultiple(numberArray, region: "AR")
        XCTAssertTrue(phoneNumbers.count == numberOfParses)
        endTime = NSDate()
        let timeInterval = endTime.timeIntervalSinceDate(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
        XCTAssertTrue(timeInterval < 5)
    }
    
    func testMultipleMutated() {
        let numberOfParses = 500
        let startTime = NSDate()
        var endTime = NSDate()
        var numberArray: [String] = []
        for _ in 0 ..< numberOfParses {
            numberArray.append("+5491187654321")
        }
        let phoneNumbers = ParseManager().parseMultiple(numberArray, region: "AR") { 
            numberArray.removeAtIndex(100)
        }
        XCTAssertTrue(phoneNumbers.count == numberOfParses)
        endTime = NSDate()
        let timeInterval = endTime.timeIntervalSinceDate(startTime)
        print("time to parse \(numberOfParses) phone numbers, \(timeInterval) seconds")
    }


}