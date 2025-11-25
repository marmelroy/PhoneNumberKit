#if os(iOS)

import UIKit

@MainActor
public protocol CountryCodePickerDelegate: AnyObject {
    func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country)
    func countryCodePickerViewControllerWillDissmiss(_ controller: CountryCodePickerViewController)
    func countryCodePickerViewControllerDidDissmiss()
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
    
    var allCountries: [Country] = []
    var countries: [[Country]] = []
    private var sectionIndexTitles: [String] = []

    var filteredCountries: [Country] = []
    private var searchWorkItem: DispatchWorkItem?

    public weak var delegate: CountryCodePickerDelegate?
    
    private let cellIdentifier: String
    private let headerIdentifier: String

    lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAnimated))

    // MARK: - Initializers
    
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
            self.options = options ?? .default
            self.cellIdentifier = self.options.cellOptions.cellType.identifier
            self.headerIdentifier = self.options.headerOptions.cellType.identifier
            super.init(style: .grouped)
    }

    required init?(coder aDecoder: NSCoder) {
        self.utility = PhoneNumberUtility()
        self.commonCountryCodes = CountryCodePicker.commonCountryCodes
        self.options = .default
        self.cellIdentifier = self.options.cellOptions.cellType.identifier
        self.headerIdentifier = self.options.headerOptions.cellType.identifier
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
        loadCountries()
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
        delegate?.countryCodePickerViewControllerWillDissmiss(self)
        dismiss(animated: true, completion: { [delegate] in
            delegate?.countryCodePickerViewControllerDidDissmiss()
        })
    }
    
    // MARK: - Initialization Methods
    private func commonInit() {
        // Configure Header
        self.title = Self.Constants.screenTitle
        
        // Configure Cells
        switch options.cellOptions.cellType {
        case .cellClass(let cellClass, let identifier):
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        case .cellNib(let nib, let identifier):
            tableView.register(nib, forCellReuseIdentifier: identifier)
        }
        tableView.rowHeight = options.cellOptions.height
        
        // Configure Header
        switch options.headerOptions.cellType {
        case .cellClass(let cellClass, let identifier):
            tableView.register(cellClass, forHeaderFooterViewReuseIdentifier: identifier)
        case .cellNib(let nib, let identifier):
            tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
        }
        tableView.sectionHeaderHeight = options.headerOptions.height
        
        // Configure Search Controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.backgroundColor = .clear

        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = !CountryCodePicker.alwaysShowsSearchBar

        // Ensure that the search bar does not remain on the screen if the user navigates to another view controller while the UISearchController is active.
        definesPresentationContext = true
        
        if let tintColor = options.tintColor {
            view.tintColor = tintColor
            navigationController?.navigationBar.tintColor = tintColor
        }

        // Table View Appearance
        if let backgroundColor = options.backgroundColor {
            tableView.backgroundColor = backgroundColor
        }

        if let separator = options.separatorColor {
            tableView.separatorColor = separator
        }
    }
    
    func loadCountries() {
        DispatchQueue.global(qos: .userInitiated).async {
            let allCountries = self.utility
                .allCountries()
                .compactMap({ Country(for: $0, with: self.utility) })
                .sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })

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

            let popular = self.commonCountryCodes.compactMap({ Country(for: $0, with: self.utility) })

            var countrySections: [[Country]] = []
            
            var hasCurrent = self.hasCurrent
            if hasCurrent, let current = Country(for: PhoneNumberUtility.defaultRegionCode(), with: self.utility) {
                countrySections.append([current])
            } else {
                hasCurrent = false
            }
            
            let hasCommon = self.hasCommon && !popular.isEmpty
            if hasCommon {
                countrySections.append(popular)
            }
            countrySections.append(contentsOf: countries)
            
            var sectionTitles: [String] = []
            if hasCurrent {
                sectionTitles.append("•") // NOTE: SFSymbols are not supported otherwise we would use 􀋑
            }
            if hasCommon {
                sectionTitles.append("★") // This is a classic unicode star
            }
            
            sectionTitles = sectionTitles + countrySections.suffix(countrySections.count - sectionTitles.count).map { group in
                group.first?.name.first
                    .map(String.init)?
                    .folding(options: .diacriticInsensitive, locale: nil) ?? ""
            }

            DispatchQueue.main.async {
                self.allCountries = allCountries
                self.countries = countrySections
                self.hasCurrent = hasCurrent
                self.hasCommon = hasCommon
                self.sectionIndexTitles = sectionTitles
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source

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
        let cell: CountryCodePickerTableViewCellProtocol
        if let _cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CountryCodePickerTableViewCellProtocol {
            cell = _cell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: CountryCodePickerTableViewCell.reuseIdentifier, for: indexPath) as! CountryCodePickerTableViewCell
        }
        
        let country = self.country(for: indexPath)
        cell.configure(with: country)
        cell.options = options.cellOptions
        return cell
    }

    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !isFiltering else { return nil }
        
        let headerTitle: String?
        if section == 0, hasCurrent {
            headerTitle = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Current", value: "Current", comment: "Name of \"Current\" section")
        } else if section == 0, !hasCurrent, hasCommon {
            headerTitle = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        } else if section == 1, hasCurrent, hasCommon {
            headerTitle = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Common", value: "Common", comment: "Name of \"Common\" section")
        } else {
            headerTitle = countries[section].first?.name.first.map(String.init)
        }
        guard let headerTitle else { return nil }
        
        let header: CountryCodePickerSectionHeaderViewProtocol
        if let _herader = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerIdentifier) as? CountryCodePickerSectionHeaderViewProtocol {
            header = _herader
        } else {
            header = tableView.dequeueReusableHeaderFooterView(withIdentifier: CountryCodePickerSectionHeader.reuseIdentifier) as! CountryCodePickerSectionHeader
        }
        header.configure(with: headerTitle)
        header.options = options.headerOptions
        return header
    }

    override public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isFiltering else {
            return nil
        }
        return sectionIndexTitles.isEmpty ? nil : sectionIndexTitles
    }

    override public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let country = self.country(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.countryCodePickerViewControllerDidPickCountry(country)
    }
    
}

// MARK: - UISearchResultsUpdating
extension CountryCodePickerViewController: UISearchResultsUpdating {
    var isFiltering: Bool {
        searchController.isActive && !isSearchBarEmpty
    }

    var isSearchBarEmpty: Bool {
        searchController.searchBar.text?.isEmpty ?? true
    }

    public func updateSearchResults(for searchController: UISearchController) {
        // Cancel previous search task
        searchWorkItem?.cancel()
        
        let searchText = searchController.searchBar.text ?? ""
        
        // Create new work item with throttling
        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            // Perform filtering on background thread
            let filtered = self.allCountries.filter { country in
                country.name.lowercased().contains(searchText.lowercased()) ||
                    country.code.lowercased().contains(searchText.lowercased()) ||
                    country.prefix.lowercased().contains(searchText.lowercased())
            }
            
            // Update UI on main thread
            DispatchQueue.main.async {
                self.filteredCountries = filtered
                self.tableView.reloadData()
            }
        }
        
        searchWorkItem = workItem
        
        // Execute with 250ms delay (throttling)
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 0.25, execute: workItem)
    }
}

// MARK: Country
public extension CountryCodePickerViewController {
    struct Country: Sendable, Equatable, Hashable {
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
}

// MARK: Constants
public extension CountryCodePickerViewController { enum Constants {} }
public extension CountryCodePickerViewController.Constants {
    static let screenTitle: String = NSLocalizedString("PhoneNumberKit.CountryCodePicker.Title", value: "Choose your country", comment: "Title of CountryCodePicker ViewController")
}


#endif
