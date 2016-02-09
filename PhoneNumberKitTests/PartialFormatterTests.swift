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
}

