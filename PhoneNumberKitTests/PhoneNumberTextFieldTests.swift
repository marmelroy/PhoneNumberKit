//
//  PhoneNumberTextFieldTests.swift
//  PhoneNumberKitTests
//
//  Created by Travis Kaufman on 10/4/19.
//  Copyright © 2019 Roy Marmelstein. All rights reserved.
//

#if os(iOS)

import PhoneNumberKit
import UIKit
import XCTest

final class PhoneNumberTextFieldTests: XCTestCase {
    private var utility: PhoneNumberUtility!

    override func setUp() {
        super.setUp()
        utility = PhoneNumberUtility()
    }

    override func tearDown() {
        utility = nil
        super.tearDown()
    }

    func testWorksWithPhoneNumberKitInstance() {
        let textField = PhoneNumberTextField(utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        textField.text = "4125551212"
        XCTAssertEqual(textField.text, "(412) 555-1212")
    }

    func testWorksWithFrameAndPhoneNumberKitInstance() {
        let frame = CGRect(x: 10.0, y: 20.0, width: 400.0, height: 250.0)
        let textField = PhoneNumberTextField(frame: frame, utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        XCTAssertEqual(textField.frame, frame)
        textField.text = "4125551212"
        XCTAssertEqual(textField.text, "(412) 555-1212")
    }

    func testPhoneNumberProperty() {
        let textField = PhoneNumberTextField(utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        textField.text = "4125551212"
        XCTAssertNotNil(textField.phoneNumber)
        textField.text = ""
        XCTAssertNil(textField.phoneNumber)
    }

    func testUSPhoneNumberWithFlag() {
        let textField = PhoneNumberTextField(utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        textField.withFlag = true
        textField.text = "4125551212"
        XCTAssertNotNil(textField.flagButton)
        XCTAssertEqual(textField.flagButton.titleLabel?.text, "🇺🇸 ")
    }

    func testNonUSPhoneNumberWithFlag() {
        let textField = PhoneNumberTextField(utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        textField.withFlag = true
        textField.text = "5872170177"
        XCTAssertNotNil(textField.flagButton)
        XCTAssertEqual(textField.flagButton.titleLabel?.text, "🇨🇦 ")
    }
    
    func testOfTypePropertyUpdatesPlaceholder() {
        let textField = PhoneNumberTextField(utility: utility)
        textField.partialFormatter.defaultRegion = "US"
        textField.withExamplePlaceholder = true
        textField.withPrefix = true
        
        textField.ofType = .mobile
        textField.updatePlaceholder()
        let mobilePlaceholder = textField.attributedPlaceholder?.string
        XCTAssertNotNil(mobilePlaceholder)
        
        textField.ofType = .fixedLine
        textField.updatePlaceholder()
        let fixedLinePlaceholder = textField.attributedPlaceholder?.string
        XCTAssertNotNil(fixedLinePlaceholder)
        
        if let mobile = mobilePlaceholder, let fixedLine = fixedLinePlaceholder {
            let mobileExample = utility.getFormattedExampleNumber(forCountry: "US", ofType: .mobile, withFormat: .international, withPrefix: true)
            let fixedLineExample = utility.getFormattedExampleNumber(forCountry: "US", ofType: .fixedLine, withFormat: .international, withPrefix: true)
            
            if mobileExample != fixedLineExample {
                XCTAssertNotEqual(mobile, fixedLine, "Different phone number types should have different placeholder examples")
            }
        }
    }
    
    func testOfTypePropertyDefaultValue() {
        let textField = PhoneNumberTextField(utility: utility)
        XCTAssertEqual(textField.ofType, .mobile, "Default ofType should be .mobile")
    }
}

#endif
