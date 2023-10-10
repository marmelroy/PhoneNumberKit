//
//  CountryCodePickerView.swift
//  PhoneNumberKit
//
//  Created by Olaf on 10/10/2023.
//  Copyright © 2023 Roy Marmelstein. All rights reserved.
//

import SwiftUI

@available(iOS 16.0, *)
public struct CountryCodePickerView: View {

	@Environment(\.dismiss) var dismiss

	@Binding var selectedCountry: Country

	@State private var searchText: String = ""

	private let options: CountryCodePickerOptions?

	var countryCodeSections: [CountryCodeDataStore.CountryCodeSection] {
		if searchText.isEmpty {
			return dataStore.countries
		}

		return self.dataStore.countries.reduce([], { result, section in
			let filtered = section.countries.filter { country in
				country.name.localizedCaseInsensitiveContains(searchText) ||
				country.code.localizedCaseInsensitiveContains(searchText) ||
				country.prefix.localizedCaseInsensitiveContains(searchText)
			}

			guard !filtered.isEmpty else {
				return result
			}

			var filteredSection = section
			filteredSection.countries = filtered

			var result = result
			result.append(filteredSection)
			return result
		})
	}

	private let dataStore: CountryCodeDataStore

	public init(
		selectedCountry: Binding<Country>,
		dataStore: CountryCodeDataStore,
		options: CountryCodePickerOptions? = nil
	) {
		self._selectedCountry = selectedCountry
		self.dataStore = dataStore
		self.options = options
	}

	public var body: some View {
		ZStack {
			List {
				ForEach(self.countryCodeSections) { section in
					Section(section.title) {
						ForEach(section.countries, id: \.code) { country in
							Button(action: {
								self.selectedCountry = country
								self.dismiss()
							}, label: {
								HStack {
									Text(country.prefix)
										.font(options?.textLabelFont?.swiftUIFont)
										.foregroundColor(options?.textLabelColor?.swiftUIColor)
										.frame(width: 50, alignment: .trailing)
									Text(country.flag)
									Text(country.name)
										.font(options?.detailTextLabelFont?.swiftUIFont)
										.foregroundColor(options?.detailTextLabelColor?.swiftUIColor ?? .primary)
								}
							})
							.listRowBackground(country == selectedCountry ? options?.cellBackgroundColorSelection?.swiftUIColor : options?.cellBackgroundColor?.swiftUIColor)
							.listRowSeparatorTint(options?.separatorColor?.swiftUIColor)
						}
					}
				}
			}
			.listRowSeparator(options?.separatorColor == nil ? .hidden : .automatic)
			.scrollContentBackground(options?.backgroundColor == nil ? .automatic : .hidden)
		}
		.tint(options?.tintColor?.swiftUIColor)
		.background(options?.backgroundColor?.swiftUIColor)
		.searchable(text: $searchText)
		.animation(.default, value: searchText)
	}
}

@available(iOS 16.0, *)
struct CountryCodePickerView_Previews: PreviewProvider {
		static var previews: some View {
			let phoneNumberKit = PhoneNumberKit()
			let useOptions: Bool = false
			return NavigationView {
				CountryCodePickerView(
					selectedCountry: .constant(.init(for: "NO", with: phoneNumberKit)!),
					dataStore: CountryCodeDataStore(phoneNumberKit: phoneNumberKit),
					options: useOptions ? CountryCodePickerOptions(
						backgroundColor: UIColor.systemBackground,
						separatorColor: UIColor.separator,
						textLabelColor: UIColor.label,
						textLabelFont: .systemFont(ofSize: 20),
						detailTextLabelColor: UIColor.secondaryLabel,
						detailTextLabelFont: .systemFont(ofSize: 18),
						tintColor: UIColor.systemBlue,
						cellBackgroundColor: UIColor.systemGroupedBackground,
						cellBackgroundColorSelection: UIColor.secondarySystemBackground
					) : nil
				)
				.listStyle(.grouped)
			}
		}
}
