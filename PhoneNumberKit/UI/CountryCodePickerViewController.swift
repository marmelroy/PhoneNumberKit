
import UIKit

@available(iOS 11.0, *)
protocol CountryCodePickerDelegate: class {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country)
}

@available(iOS 11.0, *)
class CountryCodePickerViewController: UITableViewController {

    lazy var searchController = UISearchController(searchResultsController: nil)

    public let phoneNumberKit: PhoneNumberKit

    var shouldRestoreNavigationBarToHidden = false

    /// Popular Country Codes are shown below the Current section
    public static var popularCountryCodes: [String] = []

    var hasCurrent = true
    var hasPopular = true

    lazy var allCountries = phoneNumberKit
        .allCountries()
        .compactMap({ Country(for: $0, with: self.phoneNumberKit) })
        .sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })

    lazy var countries: [[Country]] = {
        let countries = allCountries
            .reduce([[Country]]()) { collection, country in
                var collection = collection
                guard var lastGroup = collection.last else { return [[country]] }
                let lhs = lastGroup.first?.name.folding(options: .diacriticInsensitive, locale: nil)
                let rhs = country.name.folding(options: .diacriticInsensitive, locale: nil)
                if lhs?.first == rhs.first {
                    lastGroup.append(country)
                    collection[collection.count - 1] = lastGroup
                } else {
                    collection.append([country])
                }
                return collection
            }

        let popular = Self.popularCountryCodes.compactMap({ Country(for: $0, with: phoneNumberKit) })

        var result: [[Country]] = []
        // Note we should maybe use the user's current carrier's country code?
        if hasCurrent, let current = Country(for: PhoneNumberKit.defaultRegionCode(), with: phoneNumberKit) {
            result.append([current])
        }
        hasPopular = hasPopular && !popular.isEmpty
        if hasPopular {
            result.append(popular)
        }
        return result + countries
    }()

    var filteredCountries: [Country] = []

    weak var delegate: CountryCodePickerDelegate?

    init(phoneNumberKit: PhoneNumberKit) {
        self.phoneNumberKit = phoneNumberKit
        super.init(style: .grouped)

        self.title = "Choose your country"

        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = .clear
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController {
            shouldRestoreNavigationBarToHidden = nav.isNavigationBarHidden
            nav.setNavigationBarHidden(false, animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(shouldRestoreNavigationBarToHidden, animated: true)
    }

    func country(for indexPath: IndexPath) -> Country {
        isFiltering ? filteredCountries[indexPath.row] : countries[indexPath.section][indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? 1 : countries.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredCountries.count : countries[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath)
        let country = self.country(for: indexPath)

        cell.textLabel?.text = country.prefix + " " + country.flag
        cell.detailTextLabel?.text = country.name

        cell.textLabel?.font = .preferredFont(forTextStyle: .callout)
        cell.detailTextLabel?.font = .preferredFont(forTextStyle: .body)

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        } else if section == 0, hasCurrent {
            return "Current"
        } else if section == 0, !hasCurrent && hasPopular {
            return "Popular"
        } else if section == 1 && hasCurrent && hasPopular {
            return "Popular"
        }
        return countries[section].first?.name.first.map(String.init)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isFiltering else {
            return nil
        }
        var titles: [String] = []
        if hasCurrent {
            titles.append("•") // NOTE: SFSymbols are not supported otherwise we would use 􀋑
        }
        if hasPopular {
            titles.append("★") // This is a classic unicode star
        }
        return titles + countries.suffix(countries.count - titles.count).map { group in
            group.first?.name.first
                .map(String.init)?
                .folding(options: .diacriticInsensitive, locale: nil) ?? ""
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.country(for: indexPath)
        delegate?.countryCodePickerViewControllerDidPickCountry(country)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

@available(iOS 11.0, *)
extension CountryCodePickerViewController: UISearchResultsUpdating {

    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchText = searchController.searchBar.text ?? ""
        filteredCountries = allCountries.filter { country in
            country.name.lowercased().contains(searchText.lowercased()) ||
                country.code.lowercased().contains(searchText.lowercased()) ||
                country.prefix.lowercased().contains(searchText.lowercased())
        }
        tableView.reloadData()
    }
}


// MARK: Types

@available(iOS 11.0, *)
extension CountryCodePickerViewController {

    struct Country {
        var code: String
        var flag: String
        var name: String
        var prefix: String

        init?(for countryCode: String, with phoneNumberKit: PhoneNumberKit) {
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

    class Cell: UITableViewCell {

        static let reuseIdentifier = "Cell"

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value2, reuseIdentifier: Self.reuseIdentifier)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
