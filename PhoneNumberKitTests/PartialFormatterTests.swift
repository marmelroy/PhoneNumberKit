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
    
    // +33689555555
    func testFrenchNumberFromFrenchRegion()  {
        let partialFormatter = PartialFormatter(region: "FR")
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
        let partialFormatter = PartialFormatter(region: "FR")
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

    
    func testFrenchNumberFromAmericanRegion()  {
        let partialFormatter = PartialFormatter(region: "US")
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
        let partialFormatter = PartialFormatter(region: "US")
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
        let partialFormatter = PartialFormatter(region: "US")
        let testNumber = "ae4c08c6-be33-40ef-a417-e5166e307b5e"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber),  "ae4c08c6-be33-40ef-a417-e5166e307b5e")
    }
    
    // +390549555555
    func testItalianLeadingZeroFromUS()  {
        let partialFormatter = PartialFormatter(region: "US")
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
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 05 4")
        testNumber = "+390549"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 05 49")
        testNumber = "+3905495"
        XCTAssertEqual(partialFormatter.formatPartial(testNumber), "+39 05 495")
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
        let partialFormatter = PartialFormatter(region: "FR")
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
        let partialFormatter = PartialFormatter(region: "US")
        var testNumber = "8"
        print(partialFormatter.formatPartial("800253000"), "(800) 253-000")
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

}

