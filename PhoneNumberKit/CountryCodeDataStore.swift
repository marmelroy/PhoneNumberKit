//
//  CountryCodeDataStore.swift
//  PhoneNumberKit
//
//  Created by Olaf on 10/10/2023.
//  Copyright © 2023 Roy Marmelstein. All rights reserved.
//

import Foundation

open class CountryCodeDataStore {

	public let phoneNumberKit: PhoneNumberKit

	let defaultRegionCode: String
	let commonCountryCodes: [String]

	var hasCurrent = true
	var hasCommon = true

	public init(
		phoneNumberKit: PhoneNumberKit,
		defaultRegionCode: String = PhoneNumberKit.defaultRegionCode(),
		commonCountryCodes: [String] = PhoneNumberKit.CountryCodePicker.commonCountryCodes
	) {
		self.phoneNumberKit = phoneNumberKit
		self.defaultRegionCode = defaultRegionCode
		self.commonCountryCodes = commonCountryCodes
	}

	lazy var allCountries = phoneNumberKit
		.allCountries()
		.compactMap({ Country(for: $0, with: self.phoneNumberKit) })
		.sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })

	lazy var countries: [CountryCodeSection] = {
		let countries = allCountries
			.reduce([CountryCodeSection]()) { (collection: [CountryCodeSection], country: Country) in
				var collection = collection

				let foldedCountryName = country.name
					.folding(options: .diacriticInsensitive, locale: nil)
					.first!.description

				guard var lastSection = collection.last else { return [CountryCodeSection(title: foldedCountryName, countries: [country])] }
				if lastSection.title == foldedCountryName {
					lastSection.countries.append(country)
					collection[collection.count - 1] = lastSection
				} else {
					collection.append(CountryCodeSection(title: foldedCountryName, countries: [country]))
				}
				return collection
			}

		let commonCountries = commonCountryCodes.compactMap({ Country(for: $0, with: phoneNumberKit) })

		var result: [CountryCodeSection] = []
		// Note we should maybe use the user's current carrier's country code?
		if hasCurrent, let currentCountry = Country(for: defaultRegionCode, with: phoneNumberKit) {
			let currentCountrySection = CountryCodeSection(
				title: NSLocalizedString("PhoneNumberKit.CountryCodePicker.Current", value: "Current", comment: "Name of \"Current\" section"),
				indexTitle: "•", // NOTE: SFSymbols are not supported otherwise we would use 􀋑
				countries: [currentCountry]
			)
			result.append(currentCountrySection)
		}
		hasCommon = hasCommon && !commonCountries.isEmpty
		if hasCommon {
			let commonCountrySection = CountryCodeSection(
				title: NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section"),
				indexTitle: "★", // This is a classic unicode star
				countries: commonCountries
			)
			result.append(commonCountrySection)
		}
		return result + countries
	}()

	func search(for query: String) -> [Country] {
		guard !query.isEmpty else {
			return []
		}

		return self.countries.reduce([], { result, section in
			let filtered = section.countries.filter { country in
				country.name.localizedCaseInsensitiveContains(query) ||
				country.code.localizedCaseInsensitiveContains(query) ||
				country.prefix.localizedCaseInsensitiveContains(query)
			}

			guard !filtered.isEmpty else {
				return result
			}

			return result + filtered
		})
	}
}

extension CountryCodeDataStore {
	struct CountryCodeSection: Identifiable {
		let id = UUID()

		init(title: String, indexTitle: String? = nil, countries: [Country]) {
			self.title = title
			self.indexTitle = indexTitle ?? title
			self.countries = countries
		}

		let title: String
		let indexTitle: String
		var countries: [Country]
	}
}
