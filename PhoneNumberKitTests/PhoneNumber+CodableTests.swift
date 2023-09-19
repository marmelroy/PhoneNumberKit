//
//  PhoneNumber+CodableTests.swift
//  PhoneNumberKitTests
//
//  Created by David Roman on 16/11/2021.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

import PhoneNumberKit
import XCTest

final class PhoneNumberCodableTests: XCTestCase {
    private var phoneNumberKit: PhoneNumberKit!

    override func setUp() {
        super.setUp()
        phoneNumberKit = PhoneNumberKit()
    }

    override func tearDown() {
        phoneNumberKit = nil
        super.tearDown()
    }
}

extension PhoneNumberCodableTests {
    func testDecode_defaultStrategy() throws {
        try assertDecode(
            """
            {
              "countryCode" : 44,
              "leadingZero" : false,
              "nationalNumber" : 1632960015,
              "numberExtension" : null,
              "numberString" : "+441632960015",
              "regionID" : "GB",
              "type" : "unknown"
            }
            """,
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            strategy: nil
        )
        try assertDecode(
            """
            {
              "countryCode" : 34,
              "leadingZero" : false,
              "nationalNumber" : 646990213,
              "numberExtension" : null,
              "numberString" : "+34646990213",
              "regionID" : "ES",
              "type" : "unknown"
            }
            """,
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            strategy: nil
        )
    }

    func testDecode_propertiesStrategy() throws {
        try assertDecode(
            """
            {
              "countryCode" : 44,
              "leadingZero" : false,
              "nationalNumber" : 1632960015,
              "numberExtension" : null,
              "numberString" : "+441632960015",
              "regionID" : "GB",
              "type" : "unknown"
            }
            """,
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            strategy: .properties
        )
        try assertDecode(
            """
            {
              "countryCode" : 34,
              "leadingZero" : false,
              "nationalNumber" : 646990213,
              "numberExtension" : null,
              "numberString" : "+34646990213",
              "regionID" : "ES",
              "type" : "unknown"
            }
            """,
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            strategy: .properties
        )
    }

    func testDecode_e164Strategy() throws {
        try assertDecode(
            """
            "+441632960015"
            """,
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            strategy: .e164
        )
        try assertDecode(
            """
            "+441632960015"
            """,
            phoneNumberKit.parse("01632960015", withRegion: "GB", ignoreType: true),
            strategy: .e164
        )
        try assertDecode(
            """
            "+34646990213"
            """,
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            strategy: .e164
        )
        try assertDecode(
            """
            "+34646990213"
            """,
            phoneNumberKit.parse("646990213", withRegion: "ES", ignoreType: true),
            strategy: .e164
        )
    }
}

extension PhoneNumberCodableTests {
    func testEncode_defaultStrategy() throws {
        try assertEncode(
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            """
            {
              "countryCode" : 44,
              "leadingZero" : false,
              "nationalNumber" : 1632960015,
              "numberExtension" : null,
              "numberString" : "+441632960015",
              "regionID" : "GB",
              "type" : "unknown"
            }
            """,
            strategy: nil
        )
        try assertEncode(
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            """
            {
              "countryCode" : 34,
              "leadingZero" : false,
              "nationalNumber" : 646990213,
              "numberExtension" : null,
              "numberString" : "+34646990213",
              "regionID" : "ES",
              "type" : "unknown"
            }
            """,
            strategy: nil
        )
    }

    func testEncode_propertiesStrategy() throws {
        try assertEncode(
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            """
            {
              "countryCode" : 44,
              "leadingZero" : false,
              "nationalNumber" : 1632960015,
              "numberExtension" : null,
              "numberString" : "+441632960015",
              "regionID" : "GB",
              "type" : "unknown"
            }
            """,
            strategy: .properties
        )
        try assertEncode(
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            """
            {
              "countryCode" : 34,
              "leadingZero" : false,
              "nationalNumber" : 646990213,
              "numberExtension" : null,
              "numberString" : "+34646990213",
              "regionID" : "ES",
              "type" : "unknown"
            }
            """,
            strategy: .properties
        )
    }

    func testEncode_e164Strategy() throws {
        try assertEncode(
            phoneNumberKit.parse("+441632960015", ignoreType: true),
            """
            "+441632960015"
            """,
            strategy: .e164
        )
        try assertEncode(
            phoneNumberKit.parse("01632960015", withRegion: "GB", ignoreType: true),
            """
            "+441632960015"
            """,
            strategy: .e164
        )
        try assertEncode(
            phoneNumberKit.parse("+34646990213", ignoreType: true),
            """
            "+34646990213"
            """,
            strategy: .e164
        )
        try assertEncode(
            phoneNumberKit.parse("646990213", withRegion: "ES", ignoreType: true),
            """
            "+34646990213"
            """,
            strategy: .e164
        )
    }
}

private extension PhoneNumberCodableTests {
    func assertDecode(
        _ json: String,
        _ expectedPhoneNumber: PhoneNumber,
        strategy: PhoneNumberDecodingStrategy?,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let decoder = JSONDecoder()
        if let strategy {
            decoder.phoneNumberDecodingStrategy = strategy
        }
        let data = try XCTUnwrap(json.data(using: .utf8))
        let sut = try decoder.decode(PhoneNumber.self, from: data)
        XCTAssertEqual(sut, expectedPhoneNumber, file: file, line: line)
    }

    func assertEncode(
        _ phoneNumber: PhoneNumber,
        _ expectedJSON: String,
        strategy: PhoneNumberEncodingStrategy?,
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let encoder = JSONEncoder()
        if let strategy {
            encoder.phoneNumberEncodingStrategy = strategy
        }
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(phoneNumber)
        let json = String(decoding: data, as: UTF8.self)
        XCTAssertEqual(json, expectedJSON, file: file, line: line)
    }
}
