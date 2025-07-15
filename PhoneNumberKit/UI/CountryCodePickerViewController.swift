#if os(iOS)

import UIKit

@MainActor
public protocol CountryCodePickerDelegate: AnyObject {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country)
}

public class CountryCodePickerViewController: UITableViewController {
    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = NSLocalizedString(
            "PhoneNumberKit.CountryCodePicker.SearchBarPlaceholder",
            value: "Search Country Codes",
            comment: "Placeholder for country code search field")

        return searchController
    }()

    public let utility: PhoneNumberUtility

    public let options: CountryCodePickerOptions

    let commonCountryCodes: [String]

    var shouldRestoreNavigationBarToHidden = false

    var hasCurrent = true
    var hasCommon = true

    lazy var allCountries = utility
        .allCountries()
        .compactMap({ Country(for: $0, with: self.utility) })
        .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })

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

        let popular = commonCountryCodes.compactMap({ Country(for: $0, with: utility) })

        var result: [[Country]] = []
        // Note we should maybe use the user's current carrier's country code?
        if hasCurrent, let current = Country(for: PhoneNumberUtility.defaultRegionCode(), with: utility) {
            result.append([current])
        }
        hasCommon = hasCommon && !popular.isEmpty
        if hasCommon {
            result.append(popular)
        }
        return result + countries
    }()

    var filteredCountries: [Country] = []

    public weak var delegate: CountryCodePickerDelegate?

    lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAnimated))

    /// Init with a phone number kit instance. Because a `PhoneNumberUtility` initialization is expensive you can must pass a pre-initialized instance to avoid incurring perf penalties.
    ///
    /// - parameter utility: A `PhoneNumberUtility` instance to be used by the text field.
    /// - parameter commonCountryCodes: An array of country codes to display in the section below the current region section. defaults to `PhoneNumberUtility.CountryCodePicker.commonCountryCodes`
    public init(
        utility: PhoneNumberUtility,
        options: CountryCodePickerOptions?,
        commonCountryCodes: [String] = CountryCodePicker.commonCountryCodes) {
        self.utility = utility
        self.commonCountryCodes = commonCountryCodes
        self.options = options ?? CountryCodePickerOptions()
        super.init(style: .grouped)
        self.commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        self.utility = PhoneNumberUtility()
        self.commonCountryCodes = CountryCodePicker.commonCountryCodes
        self.options = CountryCodePickerOptions()
        super.init(coder: aDecoder)
        self.commonInit()
    }

    func commonInit() {
        self.title = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Title", value: "Choose your country", comment: "Title of CountryCodePicker ViewController")

        tableView.register(Cell.self, forCellReuseIdentifier: Cell.reuseIdentifier)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = .clear

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = !CountryCodePicker.alwaysShowsSearchBar

        definesPresentationContext = true

        if let tintColor = options.tintColor {
            view.tintColor = tintColor
            navigationController?.navigationBar.tintColor = tintColor
        }

        if let backgroundColor = options.backgroundColor {
            tableView.backgroundColor = backgroundColor
        }

        if let separator = options.separatorColor {
            tableView.separatorColor = separator
        }
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController {
            shouldRestoreNavigationBarToHidden = nav.isNavigationBarHidden
            nav.setNavigationBarHidden(false, animated: true)
        }
        if let nav = navigationController, nav.isBeingPresented, nav.viewControllers.count == 1 {
            navigationItem.setRightBarButton(cancelButton, animated: true)
        }
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(shouldRestoreNavigationBarToHidden, animated: true)
    }

    @objc func dismissAnimated() {
        dismiss(animated: true)
    }

    func country(for indexPath: IndexPath) -> Country {
        isFiltering ? filteredCountries[indexPath.row] : countries[indexPath.section][indexPath.row]
    }

    override public func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? 1 : countries.count
    }

    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredCountries.count : countries[section].count
    }

    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.reuseIdentifier, for: indexPath)
        let country = self.country(for: indexPath)

        if let cellBackgroundColor = options.cellBackgroundColor {
            cell.backgroundColor = cellBackgroundColor
        }

        cell.textLabel?.text = country.prefix + " " + country.flag

        if let textLabelColor = options.textLabelColor {
            cell.textLabel?.textColor = textLabelColor
        }

        if let detailTextLabelColor = options.detailTextLabelColor {
            cell.detailTextLabel?.textColor = detailTextLabelColor
        }

        cell.detailTextLabel?.text = country.name

        if let textLabelFont = options.textLabelFont {
            cell.textLabel?.font = textLabelFont
        }

        if let detailTextLabelFont = options.detailTextLabelFont {
            cell.detailTextLabel?.font = detailTextLabelFont
        }

        if let cellBackgroundColorSelection = options.cellBackgroundColorSelection {
            let view = UIView()
            view.backgroundColor = cellBackgroundColorSelection
            cell.selectedBackgroundView = view
        }

        return cell
    }

    override public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        } else if section == 0, hasCurrent {
            return NSLocalizedString("PhoneNumberKit.CountryCodePicker.Current", value: "Current", comment: "Name of \"Current\" section")
        } else if section == 0, !hasCurrent, hasCommon {
            return NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        } else if section == 1, hasCurrent, hasCommon {
            return NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        }
        return countries[section].first?.name.first.map(String.init)
    }

    override public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isFiltering else {
            return nil
        }
        var titles: [String] = []
        if hasCurrent {
            titles.append("•") // NOTE: SFSymbols are not supported otherwise we would use 􀋑
        }
        if hasCommon {
            titles.append("★") // This is a classic unicode star
        }
        return titles + countries.suffix(countries.count - titles.count).map { group in
            group.first?.name.first
                .map(String.init)?
                .folding(options: .diacriticInsensitive, locale: nil) ?? ""
        }
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.country(for: indexPath)
        delegate?.countryCodePickerViewControllerDidPickCountry(country)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CountryCodePickerViewController: UISearchResultsUpdating {
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    public func updateSearchResults(for searchController: UISearchController) {
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

public extension CountryCodePickerViewController {
    struct Country {
        public var code: String
        public var flag: String
        public var name: String
        public var prefix: String

        public init?(for countryCode: String, with utility: PhoneNumberUtility) {
            let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
            guard
                let name = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode),
                let prefix = utility.countryCode(for: countryCode)?.description
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

        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

#endif
