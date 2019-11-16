//
//  TextFieldTests.swift
//  PhoneNumberKitTests
//
//  Created by Travis Kaufman on 10/4/19.
//  Copyright © 2019 Roy Marmelstein. All rights reserved.
//

#if canImport(UIKit)

@testable import PhoneNumberKit
import UIKit
import XCTest

class TextFieldTests: XCTestCase {
    func testWorksWithPhoneNumberKitInstance() {
        let pnk = PhoneNumberKit()
        let tf = PhoneNumberTextField(withPhoneNumberKit: pnk)
        tf.text = "4125551212"
        XCTAssertEqual(tf.text, "(412) 555-1212")
    }

    func testWorksWithFrameAndPhoneNumberKitInstance() {
        let pnk = PhoneNumberKit()
        let frame = CGRect(x: 10.0, y: 20.0, width: 400.0, height: 250.0)
        let tf = PhoneNumberTextField(frame: frame, phoneNumberKit: pnk)
        XCTAssertEqual(tf.frame, frame)
        tf.text = "4125551212"
        XCTAssertEqual(tf.text, "(412) 555-1212")
    }
}

#endif