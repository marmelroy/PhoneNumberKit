//
//  PartialFormatterTests.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 09/02/2016.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import XCTest
@testable import PhoneNumberKit

import PhoneNumberKit

/// Testing partial formatter. Goal is to replicate formatting behaviour of Apple's dialer.
class PartialFormatterTests: XCTestCase {
    
    let phoneNumberKit = PhoneNumberKit()

    
    // +33689555555
    func testFrenchNumberFromFrenchRegion()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "FR")
        var testNumber = "+"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+")
        testNumber = "+3"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+3")
        testNumber = "+33"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33")
        testNumber = "+336"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6")
        testNumber = "+3368"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 8")
        testNumber = "+33689"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89")
        testNumber = "+336895"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 5")
        testNumber = "+3368955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55")
        testNumber = "+33689555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 5")
        testNumber = "+336895555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55")
        testNumber = "+3368955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55 5")
        testNumber = "+33689555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55 55")
    }
    
    func testFrenchNumberIDDFromFrenchRegion()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "FR")
        var testNumber = "0"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "0")
        testNumber = "00"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00")
        testNumber = "003"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 3")
        testNumber = "0033"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33")
        testNumber = "00336"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6")
        testNumber = "003368"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 8")
        testNumber = "0033689"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89")
        testNumber = "00336895"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 5")
        testNumber = "003368955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 55")
        testNumber = "0033689555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 55 5")
        testNumber = "00336895555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 55 55")
        testNumber = "003368955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 55 55 5")
        testNumber = "0033689555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "00 33 6 89 55 55 55")
    }

    // 268 464 1234
    // Test for number that is not the country code's main country
    func testAntiguaNumber() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "AG")
        var number = "2"
        XCTAssertEqual(partialFormatter.formatPartial(number), "2")
        number = "26"
        XCTAssertEqual(partialFormatter.formatPartial(number), "26")
        number = "268"
        XCTAssertEqual(partialFormatter.formatPartial(number), "268")
        number = "2684"
        XCTAssertEqual(partialFormatter.formatPartial(number), "268-4")
        number = "26846"
        XCTAssertEqual(partialFormatter.formatPartial(number), "268-46")
        number = "268464"
        XCTAssertEqual(partialFormatter.formatPartial(number), "268-464")
        number = "2684641"
        XCTAssertEqual(partialFormatter.formatPartial(number), "268-4641")
        number = "26846412"
        XCTAssertEqual(partialFormatter.formatPartial(number), "(268) 464-12")
        number = "268464123"
        XCTAssertEqual(partialFormatter.formatPartial(number), "(268) 464-123")
        number = "2684641234"
        XCTAssertEqual(partialFormatter.formatPartial(number), "(268) 464-1234")
    }

    func testFrenchNumberFromAmericanRegion()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        var testNumber = "+"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+")
        testNumber = "+3"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+3")
        testNumber = "+33"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33")
        testNumber = "+336"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6")
        testNumber = "+3368"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 8")
        testNumber = "+33689"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89")
        testNumber = "+336895"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 5")
        testNumber = "+3368955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55")
        testNumber = "+33689555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 5")
        testNumber = "+336895555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55")
        testNumber = "+3368955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55 5")
        testNumber = "+33689555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+33 6 89 55 55 55")
    }
    
    func testFrenchNumberIDDFromAmericanRegion()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        var testNumber = "0"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "0")
        testNumber = "01"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "01")
        testNumber = "011"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011")
        testNumber = "0113"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 3")
        testNumber = "01133"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33")
        testNumber = "011336"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6")
        testNumber = "0113368"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 8")
        testNumber = "01133689"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89")
        testNumber = "011336895"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 5")
        testNumber = "0113368955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 55")
        testNumber = "01133689555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 55 5")
        testNumber = "011336895555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 55 55")
        testNumber = "0113368955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 55 55 5")
        testNumber = "01133689555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "011 33 6 89 55 55 55")
    }

    
    func testInvalidNumberNotANumber() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        let testNumber = "ae4c08c6-be33-40ef-a417-e5166e307b5e"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber),  "ae4c08c6-be33-40ef-a417-e5166e307b5e")
    }
    
    // +390549555555
    func testItalianLeadingZeroFromUS()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        var testNumber = "+"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+")
        testNumber = "+3"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+3")
        testNumber = "+39"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39")
        testNumber = "+390"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0")
        testNumber = "+3905"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 05")
        testNumber = "+39054"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 054")
        testNumber = "+390549"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549")
        testNumber = "+3905495"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 5")
        testNumber = "+39054955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 55")
        testNumber = "+390549555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 555")
        testNumber = "+3905495555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 5555")
        testNumber = "+39054955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 55555")
        testNumber = "+390549555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 0549 555555")

    }
    
    func testFrenchNumberLocal()  {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "FR")
        var testNumber = "0"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "0")
        testNumber = "06"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06")
        testNumber = "068"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 8")
        testNumber = "0689"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89")
        testNumber = "06895"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 5")
        testNumber = "068955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 55")
        testNumber = "0689555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 55 5")
        testNumber = "06895555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 55 55")
        testNumber = "068955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 55 55 5")
        testNumber = "0689555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "06 89 55 55 55")
    }

    func testUSTollFreeNumber() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        var testNumber = "8"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "8")
        testNumber = "80"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "80")
        testNumber = "800"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "800")
        testNumber = "8002"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "800-2")
        testNumber = "80025"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "800-25")
        testNumber = "800253"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "800-253")
        testNumber = "8002530"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "800-2530")
        testNumber = "80025300"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "(800) 253-00")
        testNumber = "800253000"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "(800) 253-000")
        testNumber = "8002530000"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "(800) 253-0000")
    }
    
    // 07739555555
    func testUKMobileNumber() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "GB")
        var testNumber = "0"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "0")
        testNumber = "07"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07")
        testNumber = "077"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "077")
        testNumber = "0773"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "0773")
        testNumber = "07739"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739")
        testNumber = "077395"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 5")
        testNumber = "0773955"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 55")
        testNumber = "07739555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 555")
        testNumber = "077395555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 5555")
        testNumber = "0773955555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 55555")
        testNumber = "07739555555"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "07739 555555")
    }
    
    // MARK: region prediction
    func testMinimalFrenchNumber() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US")
        _ = partialFormatter.formatPartial("+33")
        XCTAssertEqual(partialFormatter.currentRegion, "FR")
    }
    
    func testMinimalUSNumberFromFrance() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "FR")
        _ = partialFormatter.formatPartial("+1")
        XCTAssertEqual(partialFormatter.currentRegion, "US")
    }
    
    func testRegionResetsWithEachCallToFormatPartial() {
        let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "DE")
        _ = partialFormatter.formatPartial("+1 212 555 1212")
        XCTAssertEqual(partialFormatter.currentRegion, "US")
        _ = partialFormatter.formatPartial("invalid raw number")
        XCTAssertEqual(partialFormatter.currentRegion, "DE")
    }

    // MARK: max digits
    func testMaxDigits() {
        func test(_ maxDigits: Int?, _ formatted: String) {
            let partialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: "US", maxDigits: maxDigits)
            XCTAssertEqual(partialFormatter.formatPartial("555 555 5555"), formatted)
        }
        
        test(nil, "(555) 555-5555")
        test(0, "")
        test(1, "5")
        test(2, "55")
        test(3, "555")
        test(4, "555-5")
        test(5, "555-55")
        test(6, "555-555")
        test(7, "555-5555")
        test(8, "(555) 555-55")
        test(9, "(555) 555-555")
        test(10, "(555) 555-5555")
        test(11, "(555) 555-5555")
    }
    
    // MARK: convenience initializer
    func testConvenienceInitializerAllowsFormatting() {
        let partialFormatter = PartialFormatter(defaultRegion: "US")

        let testNumber = "8675309"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "867-5309")
    }
}

