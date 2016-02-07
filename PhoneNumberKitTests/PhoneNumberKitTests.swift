//
//  PhoneNumberKitTests.swift
//  PhoneNumberKitTests
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import PhoneNumberKit

import PhoneNumberKit

class PhoneNumberKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testPartialFormatter() {
        let partialFormatter = PartialFormatter(region: "FR")
        partialFormatter.formatPartial("001689017")
    }
    
    func testMetadataMainCountryFetch() {
        let countryMetadata = Metadata.sharedInstance.fetchMainCountryMetadataForCode(1)
        XCTAssertEqual(countryMetadata?.codeID, "US")
    }
    
    // Invalid american number, GitHub issue #8 by j-pk
    func testInvalidNumberE() {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: "202 00e 0000", region: "US")
            print(phoneNumber.toE164())
            XCTFail()
        }
        catch {
            XCTAssert(true)
        }
    }
    
    // Invalid american number, GitHub issue #9 by lobodin
    func testAmbiguousFixedOrMobileNumber() {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: "+16307792428", region: "US")
            print(phoneNumber.toE164())
            XCTAssertEqual(phoneNumber.type, PhoneNumberType.FixedOrMobile)
        }
        catch {
            XCTFail()
        }
    }


    // Italian number with a leading zero
    func testItalianLeadingZero() {
        let testNumber = "+39 0549555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
//            XCTAssertEqual(phoneNumber.toInternational(), testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 39)
            XCTAssertEqual(phoneNumber.nationalNumber, 549555555)
            XCTAssertEqual(phoneNumber.leadingZero, true)
        }
        catch {
            XCTFail()
        }
    }
    
    // French number with extension
    func testNumberWithExtension() {
        let testNumber = "+33-689-5-5555-5 ext. 84"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.numberExtension, "84")
            XCTAssertEqual(phoneNumber.nationalNumber, 689555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }

    // French number with a plus
    func testValidNumberWithPlusNoWhiteSpace() {
        let testNumber = "+33689555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.nationalNumber, 689555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
            XCTAssertEqual(phoneNumber.type, PhoneNumberType.Mobile)
        }
        catch {
            XCTFail()
        }
    }
    
    // 'Noisy' Japanese number with a plus
    func testValidNumberWithPlusWhiteSpace() {
        let testNumber = "+81 601 55-5-5 5 5"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+81601555555")
            XCTAssertEqual(phoneNumber.countryCode, 81)
            XCTAssertEqual(phoneNumber.nationalNumber, 601555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }


    // English number with an American IDD (default region for testing enivronment)
    func testValidNumberWithAmericanIDDNoWhiteSpace() {
        let testNumber = "011447739555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+447739555555")
            XCTAssertEqual(phoneNumber.countryCode, 44)
            XCTAssertEqual(phoneNumber.nationalNumber, 7739555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }

    // 'Noisy' Brazilian number with an American IDD (default region for testing enivronment)
    func testValidNumberWithAmericanIDDWhiteSpace() {
        let testNumber = "01155 11 9 6 555 55 55"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+5511965555555")
            XCTAssertEqual(phoneNumber.countryCode, 55)
            XCTAssertEqual(phoneNumber.nationalNumber, 11965555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }
    
    //  American number with no prefix from an American phone (default region for testing enivronment)
    func testValidLocalNumberWithNoPrefixNoWhiteSpace() {
        let testNumber = "2015555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+12015555555")
            XCTAssertEqual(phoneNumber.countryCode, 1)
            XCTAssertEqual(phoneNumber.nationalNumber, 2015555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }
    
    //  'Noisy' American number with no prefix from an American phone (default region for testing enivronment)
    func testValidLocalNumberWithNoPrefixWhiteSpace() {
        let testNumber = "500-2-55-555-5"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+15002555555")
            XCTAssertEqual(phoneNumber.countryCode, 1)
            XCTAssertEqual(phoneNumber.nationalNumber, 5002555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
        }
        catch {
            XCTFail()
        }
    }
    
    //  Invalid number too short
    func testInvalidNumberTooShort() {
        let testNumber = "+44 32"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            phoneNumber.toE164()
            XCTFail()
        }
        catch {
            XCTAssert(true)
        }
    }

    //  Invalid number too long
    func testInvalidNumberTooLong() {
        let testNumber = "+44 3243894723084732047023472"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            phoneNumber.toE164()
            XCTFail()
        }
        catch {
            XCTAssert(true)
        }
    }

    //  Invalid number not a number, random string
    func testInvalidNumberNotANumber() {
        let testNumber = "ae4c08c6-be33-40ef-a417-e5166e307b5e"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            phoneNumber.toE164()
            XCTFail()
        }
        catch {
            XCTAssert(true)
        }
    }

    //  Invalid number invalid format
    func testInvalidNumberNotANumberInvalidFormat() {
        let testNumber = "+33(02)689555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            phoneNumber.toE164()
            XCTFail()
        }
        catch PhoneNumberError.NotANumber {
            XCTAssert(true)
        }
        catch {
            XCTAssert(false)
        }
    }
    
    //  Test that metadata initiates correctly by checking all countries
    func testAllCountries() {
        let phoneNumberKit = PhoneNumberKit()
        let allCountries = phoneNumberKit.allCountries()
        XCTAssert(allCountries.count > 0)
    }

    //  Test code for country function -  valid country
    func testCodeForCountryValid() {
        let phoneNumberKit = PhoneNumberKit()
        XCTAssertEqual(phoneNumberKit.codeForCountry("FR"), 33)
    }
    
    //  Test code for country function - invalid country
    func testCodeForCountryInvalid() {
        let phoneNumberKit = PhoneNumberKit()
        XCTAssertEqual(phoneNumberKit.codeForCountry("FOOBAR"), nil)
    }
    
    //  Test countries for code function
    func testCountriesForCodeValid() {
        let phoneNumberKit = PhoneNumberKit()
        XCTAssertEqual(phoneNumberKit.countriesForCode(1)?.count, 25)
    }

    //  Test countries for code function
    func testCountriesForCodeInvalid() {
        let phoneNumberKit = PhoneNumberKit()
        XCTAssertEqual(phoneNumberKit.countriesForCode(424242)?.count, 0)
    }

}
