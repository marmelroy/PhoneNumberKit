//
//  PhoneNumberKitTests.swift
//  PhoneNumberKitTests
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import PhoneNumberKit

class PhoneNumberKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    // Italian number with a leading zero
    func testItalianLeadingZero() {
        let testNumber = "+39 0549555555"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toInternational(), testNumber)
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
        let testNumber = "+33689555555 ext. 84"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.nationalNumber, 689555555)
            XCTAssertEqual(phoneNumber.leadingZero, false)
            XCTAssertEqual(phoneNumber.numberExtension, "84")
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
            XCTAssertEqual(phoneNumber.type, PNPhoneNumberType.Mobile)
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

    
    // French number with brackets
    func testValidNumberWithBrackets() {
        let testNumber = "+33 (0) 6 89 01 73 83"
        do {
            let phoneNumber = try PhoneNumber(rawNumber: testNumber)
            XCTAssertEqual(phoneNumber.toE164(), "+33689017383")
            XCTAssertEqual(phoneNumber.countryCode, 33)
            XCTAssertEqual(phoneNumber.nationalNumber, 689017383)
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
        catch PNParsingError.TooLong {
            XCTAssert(true)
        }
        catch {
            XCTAssert(false)
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
        catch PNParsingError.NotANumber {
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
    
    func testUSNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "650 253 0000")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumber2 = try PhoneNumber(rawNumber: "+1 650 253 0000")
            XCTAssertNotNil(phoneNumber2)
            let phoneNumber3 = try PhoneNumber(rawNumber: "800 253 0000")
            XCTAssertNotNil(phoneNumber3)
            let phoneNumber4 = try PhoneNumber(rawNumber: "+1 800 253 0000")
            XCTAssertNotNil(phoneNumber4)
            let phoneNumber5 = try PhoneNumber(rawNumber: "900 253 0000")
            XCTAssertNotNil(phoneNumber5)
            let phoneNumber6 = try PhoneNumber(rawNumber: "+1 900 253 0000")
            XCTAssertNotNil(phoneNumber6)
            let phoneNumber7 = try PhoneNumber(rawNumber: "+1 900 253 0000")
            XCTAssertNotNil(phoneNumber7)
        }
        catch {
            XCTFail()
        }
    }
    
    func testBSNumber() {
        do {
            let phoneNumber1 = try PhoneNumber(rawNumber: "+1 242 365 1234")
            XCTAssertNotNil(phoneNumber1)
            let phoneNumber2 = try PhoneNumber(rawNumber: "+1 242 365 1234")
            XCTAssertNotNil(phoneNumber2)
        }
        catch {
            XCTFail()
        }
    }

    
//
//    
//    #pragma mark - testFormatGBNumber
//    {
//    XCTAssertEqualObjects(@"(020) 7031 3000", [_aUtil format:GB_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+44 20 7031 3000", [_aUtil format:GB_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"(07912) 345 678", [_aUtil format:GB_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+44 7912 345 678", [_aUtil format:GB_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    }
//    
//    
//    #pragma mark - testFormatDENumber
//    {
//    id deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@301234];
//    XCTAssertEqualObjects(@"030/1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 30/1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"tel:+49-30-1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatRFC3966]);
//    
//    deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@291123];
//    XCTAssertEqualObjects(@"0291 123", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 291 123", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    
//    deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@29112345678];
//    XCTAssertEqualObjects(@"0291 12345678", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 291 12345678", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    
//    deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@912312345];
//    XCTAssertEqualObjects(@"09123 12345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 9123 12345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    
//    deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@80212345];
//    XCTAssertEqualObjects(@"08021 2345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 8021 2345", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    
//    // Note this number is correctly formatted without national prefix. Most of
//    // the numbers that are treated as invalid numbers by the library are short
//    // numbers, and they are usually not dialed with national prefix.
//    XCTAssertEqualObjects(@"1234", [_aUtil format:DE_SHORT_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+49 1234", [_aUtil format:DE_SHORT_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    
//    deNumber = [[NBPhoneNumber alloc] init];
//    [deNumber setCountryCode:@49];
//    [deNumber setNationalNumber:@41341234];
//    XCTAssertEqualObjects(@"04134 1234", [_aUtil format:deNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    }
//    
//    #pragma mark - testFormatITNumber
//    {
//    XCTAssertEqualObjects(@"02 3661 8300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+39 02 3661 8300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+390236618300", [_aUtil format:IT_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
//    XCTAssertEqualObjects(@"345 678 901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+39 345 678 901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+39345678901", [_aUtil format:IT_MOBILE numberFormat:NBEPhoneNumberFormatE164]);
//    }
//    
//    #pragma mark - testFormatAUNumber
//    {
//    XCTAssertEqualObjects(@"02 3661 8300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+61 2 3661 8300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+61236618300", [_aUtil format:AU_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
//    
//    id auNumber = [[NBPhoneNumber alloc] init];
//    [auNumber setCountryCode:@61];
//    [auNumber setNationalNumber:@1800123456];
//    XCTAssertEqualObjects(@"1800 123 456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+61 1800 123 456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+611800123456", [_aUtil format:auNumber numberFormat:NBEPhoneNumberFormatE164]);
//    }
//    
//    #pragma mark - testFormatARNumber
//    {
//    XCTAssertEqualObjects(@"011 8765-4321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+54 11 8765-4321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+541187654321", [_aUtil format:AR_NUMBER numberFormat:NBEPhoneNumberFormatE164]);
//    XCTAssertEqualObjects(@"011 15 8765-4321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+54 9 11 8765 4321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+5491187654321", [_aUtil format:AR_MOBILE numberFormat:NBEPhoneNumberFormatE164]);
//    }
//    
//    #pragma mark - testFormatMXNumber
//    {
//    XCTAssertEqualObjects(@"045 234 567 8900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+52 1 234 567 8900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+5212345678900", [_aUtil format:MX_MOBILE1 numberFormat:NBEPhoneNumberFormatE164]);
//    XCTAssertEqualObjects(@"045 55 1234 5678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+52 1 55 1234 5678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+5215512345678", [_aUtil format:MX_MOBILE2 numberFormat:NBEPhoneNumberFormatE164]);
//    XCTAssertEqualObjects(@"01 33 1234 5678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+52 33 1234 5678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+523312345678", [_aUtil format:MX_NUMBER1 numberFormat:NBEPhoneNumberFormatE164]);
//    XCTAssertEqualObjects(@"01 821 123 4567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatNATIONAL]);
//    XCTAssertEqualObjects(@"+52 821 123 4567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatINTERNATIONAL]);
//    XCTAssertEqualObjects(@"+528211234567", [_aUtil format:MX_NUMBER2 numberFormat:NBEPhoneNumberFormatE164]);
//    }
//    
//    #pragma mark - testFormatOutOfCountryCallingNumber
//    {
//    XCTAssertEqualObjects(@"00 1 900 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_PREMIUM regionCallingFrom:@"DE"]);
//    XCTAssertEqualObjects(@"1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"BS"]);
//    XCTAssertEqualObjects(@"00 1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"PL"]);
//    XCTAssertEqualObjects(@"011 44 7912 345 678", [_aUtil formatOutOfCountryCallingNumber:GB_MOBILE regionCallingFrom:@"US"]);
//    XCTAssertEqualObjects(@"00 49 1234", [_aUtil formatOutOfCountryCallingNumber:DE_SHORT_NUMBER regionCallingFrom:@"GB"]);
//    // Note this number is correctly formatted without national prefix. Most of
//    // the numbers that are treated as invalid numbers by the library are short
//    // numbers, and they are usually not dialed with national prefix.
//    XCTAssertEqualObjects(@"1234", [_aUtil formatOutOfCountryCallingNumber:DE_SHORT_NUMBER regionCallingFrom:@"DE"]);
//    XCTAssertEqualObjects(@"011 39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"US"]);
//    XCTAssertEqualObjects(@"02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"IT"]);
//    XCTAssertEqualObjects(@"+39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"SG"]);
//    XCTAssertEqualObjects(@"6521 8000", [_aUtil formatOutOfCountryCallingNumber:SG_NUMBER regionCallingFrom:@"SG"]);
//    XCTAssertEqualObjects(@"011 54 9 11 8765 4321", [_aUtil formatOutOfCountryCallingNumber:AR_MOBILE regionCallingFrom:@"US"]);
//    XCTAssertEqualObjects(@"011 800 1234 5678", [_aUtil formatOutOfCountryCallingNumber:INTERNATIONAL_TOLL_FREE regionCallingFrom:@"US"]);
//    
//    id arNumberWithExtn = [AR_MOBILE copy];
//    [arNumberWithExtn setExtension:@"1234"];
//    XCTAssertEqualObjects(@"011 54 9 11 8765 4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"US"]);
//    XCTAssertEqualObjects(@"0011 54 9 11 8765 4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"AU"]);
//    XCTAssertEqualObjects(@"011 15 8765-4321 ext. 1234", [_aUtil formatOutOfCountryCallingNumber:arNumberWithExtn regionCallingFrom:@"AR"]);
//    }
//    
//    
//    #pragma mark - testFormatOutOfCountryWithInvalidRegion
//    {
//    // AQ/Antarctica isn't a valid region code for phone number formatting,
//    // so this falls back to intl formatting.
//    XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"AQ"]);
//    // For region code 001, the out-of-country format always turns into the
//    // international format.
//    XCTAssertEqualObjects(@"+1 650 253 0000", [_aUtil formatOutOfCountryCallingNumber:US_NUMBER regionCallingFrom:@"001"]);
//    }
//    
//    
//    #pragma mark - testFormatOutOfCountryWithPreferredIntlPrefix
//    {
//    // This should use 0011, since that is the preferred international prefix
//    // (both 0011 and 0012 are accepted as possible international prefixes in our
//    // test metadta.)
//    XCTAssertEqualObjects(@"0011 39 02 3661 8300", [_aUtil formatOutOfCountryCallingNumber:IT_NUMBER regionCallingFrom:@"AU"]);
//    }
//    
//    
//    #pragma mark - testFormatOutOfCountryKeepingAlphaChars
//    {
//    id alphaNumericNumber = [[NBPhoneNumber alloc] init];
//    [alphaNumericNumber setCountryCode:@1];
//    [alphaNumericNumber setNationalNumber:@8007493524];
//    [alphaNumericNumber setRawInput:@"1800 six-flag"];
//    XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
//    XCTAssertEqualObjects(@"0011 1 800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    [alphaNumericNumber setRawInput:@"Call us from UK: 00 1 800 SIX-flag"];
//    XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    [alphaNumericNumber setRawInput:@"800 SIX-flag"];
//    XCTAssertEqualObjects(@"0011 1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    // Formatting from within the NANPA region.
//    XCTAssertEqualObjects(@"1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"US"]);
//    XCTAssertEqualObjects(@"1 800 SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"BS"]);
//    
//    // Testing that if the raw input doesn't exist, it is formatted using
//    // formatOutOfCountryCallingNumber.
//    [alphaNumericNumber setRawInput:nil];
//    XCTAssertEqualObjects(@"00 1 800 749 3524", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
//    
//    // Testing AU alpha number formatted from Australia.
//    [alphaNumericNumber setCountryCode:@61];
//    [alphaNumericNumber setNationalNumber:@827493524];
//    [alphaNumericNumber setRawInput:@"+61 82749-FLAG"];
//    // This number should have the national prefix fixed.
//    XCTAssertEqualObjects(@"082749-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    [alphaNumericNumber setRawInput:@"082749-FLAG"];
//    XCTAssertEqualObjects(@"082749-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    [alphaNumericNumber setNationalNumber:@18007493524];
//    [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
//    // This number should not have the national prefix prefixed, in accordance
//    // with the override for this specific formatting rule.
//    XCTAssertEqualObjects(@"1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    // The metadata should not be permanently changed, since we copied it before
//    // modifying patterns. Here we check this.
//    [alphaNumericNumber setNationalNumber:@1800749352];
//    XCTAssertEqualObjects(@"1800 749 352", [_aUtil formatOutOfCountryCallingNumber:alphaNumericNumber regionCallingFrom:@"AU"]);
//    
//    // Testing a region with multiple international prefixes.
//    XCTAssertEqualObjects(@"+61 1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"SG"]);
//    // Testing the case of calling from a non-supported region.
//    XCTAssertEqualObjects(@"+61 1-800-SIX-FLAG", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AQ"]);
//    
//    // Testing the case with an invalid country calling code.
//    [alphaNumericNumber setCountryCode:0];
//    [alphaNumericNumber setNationalNumber:@18007493524];
//    [alphaNumericNumber setRawInput:@"1-800-SIX-flag"];
//    // Uses the raw input only.
//    XCTAssertEqualObjects(@"1-800-SIX-flag", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
//    
//    // Testing the case of an invalid alpha number.
//    [alphaNumericNumber setCountryCode:@1];
//    [alphaNumericNumber setNationalNumber:@80749];
//    [alphaNumericNumber setRawInput:@"180-SIX"];
//    // No country-code stripping can be done.
//    XCTAssertEqualObjects(@"00 1 180-SIX", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"DE"]);
//    
//    // Testing the case of calling from a non-supported region.
//    [alphaNumericNumber setCountryCode:@1];
//    [alphaNumericNumber setNationalNumber:@80749];
//    [alphaNumericNumber setRawInput:@"180-SIX"];
//    // No country-code stripping can be done since the number is invalid.
//    XCTAssertEqualObjects(@"+1 180-SIX", [_aUtil formatOutOfCountryKeepingAlphaChars:alphaNumericNumber regionCallingFrom:@"AQ"]);
//    }
    


}
