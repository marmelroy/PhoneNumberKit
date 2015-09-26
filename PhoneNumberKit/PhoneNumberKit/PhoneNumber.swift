//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

public enum PNCountryCodeSource {
    case NumberWithPlusSign
    case NumberWithIDD
    case NumberWithoutPlusSign
    case DefaultCountry
}

public struct PhoneNumber {
    var countryCode: UInt
    var nationalNumber: UInt
    var numberExtension: String
    var italianLeadingZero: Bool
    var leadingZerosNumber: Int
    var rawNumber: String
    var countryCodeSource: PNCountryCodeSource
    var preferredDomesticCarrierCode: String
}

//extension PhoneNumber {
//    init(rawNumber: String, defaultRegion: String) {
//        self.rawNumber = rawNumber
//    }
//}
