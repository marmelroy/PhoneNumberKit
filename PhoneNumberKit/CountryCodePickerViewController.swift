#if os(iOS)

import UIKit

public protocol CountryCodePickerDelegate: AnyObject {
    func countryCodePickerViewControllerDidPickCountry(_ country: Country)
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

		public let dataStore: CountryCodeDataStore

    public let options: CountryCodePickerOptions

    var shouldRestoreNavigationBarToHidden = false

		var hasCurrent: Bool {
			get { dataStore.hasCurrent }
			set { dataStore.hasCurrent = newValue }
		}

		var hasCommon: Bool {
			get { dataStore.hasCommon }
			set { dataStore.hasCommon = newValue }
		}

		lazy var allCountries = dataStore.allCountries

		lazy var countries = dataStore.countries

    var filteredCountries: [Country] = []

    public weak var delegate: CountryCodePickerDelegate?

    lazy var cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissAnimated))

	/**
	 Init with a phone number kit instance. Because a PhoneNumberKit initialization is expensive you can must pass a pre-initialized instance to avoid incurring perf penalties.
	 
	 - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.
	 - parameter options: An object that describes the color theme for the country code list.
	 - parameter commonCountryCodes: An array of country codes to display in the section below the current region section. defaults to `PhoneNumberKit.CountryCodePicker.commonCountryCodes`
	 */
    public init(
        phoneNumberKit: PhoneNumberKit,
        options: CountryCodePickerOptions? = nil,
        commonCountryCodes: [String] = PhoneNumberKit.CountryCodePicker.commonCountryCodes)
    {
				self.dataStore = CountryCodeDataStore(phoneNumberKit: phoneNumberKit, commonCountryCodes: commonCountryCodes)
        self.options = options ?? CountryCodePickerOptions()
				super.init(style: .grouped)
				self.commonInit()
    }

	/**
	 Init with a phone number kit instance. Because a PhoneNumberKit initialization is expensive you can must pass a pre-initialized instance to avoid incurring perf penalties.
	 
	 - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.
	 - parameter options: An object that describes the color theme for the country code list.
	 - parameter dataStore: A data source that provides data for the view.
	 */
		public init(
				dataStore: CountryCodeDataStore,
				options: CountryCodePickerOptions? = nil
		) {
				self.dataStore = dataStore
				self.options = options ?? CountryCodePickerOptions()
				super.init(style: .grouped)
				self.commonInit()
		}

    required init?(coder aDecoder: NSCoder) {
				self.dataStore = CountryCodeDataStore(phoneNumberKit: PhoneNumberKit())
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
        navigationItem.hidesSearchBarWhenScrolling = !PhoneNumberKit.CountryCodePicker.alwaysShowsSearchBar

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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let nav = navigationController {
            shouldRestoreNavigationBarToHidden = nav.isNavigationBarHidden
            nav.setNavigationBarHidden(false, animated: true)
        }
        if let nav = navigationController, nav.isBeingPresented && nav.viewControllers.count == 1 {
            navigationItem.setRightBarButton(cancelButton, animated: true)
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(shouldRestoreNavigationBarToHidden, animated: true)
    }

    @objc func dismissAnimated() {
        dismiss(animated: true)
    }

    func country(for indexPath: IndexPath) -> Country {
				isFiltering ? filteredCountries[indexPath.row] : countries[indexPath.section].countries[indexPath.row]
    }

    public override func numberOfSections(in tableView: UITableView) -> Int {
        isFiltering ? 1 : countries.count
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
				isFiltering ? filteredCountries.count : countries[section].countries.count
    }

    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isFiltering {
            return nil
        }
				return countries[section].title
    }

    public override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard !isFiltering else {
            return nil
        }
				return dataStore.countries.map { $0.indexTitle }
    }

    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
				filteredCountries = dataStore.search(for: searchText)
        tableView.reloadData()
    }
}

public extension CountryCodePickerViewController {

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

#endif

import SwiftUI

/// https://github.com/theoriginalbit/PreviewView
public struct ViewControllerPreview: UIViewControllerRepresentable {
		/// The view controller being previewed.
		public let viewController: UIViewController

		/// Creates a view controller preview.
		///
		/// - Returns: The initialized preview object.
		public init(_ viewController: UIViewController) {
				self.viewController = viewController
		}

		public func makeUIViewController(context: Context) -> some UIViewController { viewController }
		public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}

struct ViewController_Previews: PreviewProvider {
		static var previews: some View {
			let viewController = CountryCodePickerViewController(
				dataStore: CountryCodeDataStore(
					phoneNumberKit: PhoneNumberKit()
				)
			)

			return ViewControllerPreview(UINavigationController(rootViewController: viewController))
		}
}
