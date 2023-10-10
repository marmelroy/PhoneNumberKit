//
//  Country.swift
//  PhoneNumberKit
//
//  Created by Olaf on 10/10/2023.
//  Copyright © 2023 Roy Marmelstein. All rights reserved.
//

#if os(iOS)

import Foundation

public struct Country: Hashable {
		public var code: String
		public var flag: String
		public var name: String
		public var prefix: String

		public init?(for countryCode: String, with phoneNumberKit: PhoneNumberKit) {
				let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
				guard
						let name = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode),
						let prefix = phoneNumberKit.countryCode(for: countryCode)?.description
				else {
						return nil
				}

				self.code = countryCode
				self.name = name
				self.prefix = "+" + prefix
				self.flag = ""
				countryCode.uppercased().unicodeScalars.forEach {
						if let scaler = UnicodeScalar(flagBase + $0.value) {
								flag.append(String(describing: scaler))
						}
				}
				if flag.count != 1 { // Failed to initialize a flag ... use an empty string
						return nil
				}
		}
}

#endif
