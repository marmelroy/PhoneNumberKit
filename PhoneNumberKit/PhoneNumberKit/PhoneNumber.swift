//
//  PhoneNumber.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 26/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

struct PhoneNumber {
    var countryCode: UInt
    var nationalNumber: UInt
    var numberExtension: String
    var italianLeadingZero: Bool
    var leadingZerosNumber: Int
    var rawNumber: String
    var countryCodeSource: Int
    var preferredDomesticCarrierCode: String
}
