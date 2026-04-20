#if os(iOS)
import UIKit

public extension CountryCodePickerViewController {
    
    protocol CountryCodePickerTableViewCellProtocol: UITableViewCell {
        var options: CountryCodePickerOptions.CountryCodePickerCellOptions { get set }
        func configure(with country: Country)
    }
    
    class CountryCodePickerTableViewCell: UITableViewCell, CountryCodePickerTableViewCellProtocol {
        public static let reuseIdentifier = "CountryCodePickerTableViewCell"
        public static let defaultHeight: CGFloat = 44.0
        
        /// Configuration options for the cell appearance.
        public var options: CountryCodePickerOptions.CountryCodePickerCellOptions = .default {
            didSet {
                if options != oldValue {
                    configureOptions()
                }
            }
        }
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            super.init(style: .value2, reuseIdentifier: Self.reuseIdentifier)
            configureOptions()
        }
        
        @available(*, unavailable)
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: Configuration
        
        public func configure(with country: Country) {
            self.textLabel?.text = country.cellDefaultText
            self.detailTextLabel?.text = country.cellDefaultDetails
        }
        
        private func configureOptions() {
            if let textLabelColor = options.textLabelColor {
                self.textLabel?.textColor = textLabelColor
            }
            if let textLabelFont = options.textLabelFont {
                self.textLabel?.font = textLabelFont
            }
            if let detailTextLabelColor = options.detailTextLabelColor {
                self.detailTextLabel?.textColor = detailTextLabelColor
            }
            if let detailTextLabelFont = options.detailTextLabelFont {
                self.detailTextLabel?.font = detailTextLabelFont
            }
            if let backgroundColor = options.backgroundColor {
                self.backgroundColor = backgroundColor
            }
            
            if let backgroundColorSelection = options.backgroundColorSelection,
               self.selectedBackgroundView?.backgroundColor != backgroundColorSelection {
                let selectedBackgroundView = UIView()
                selectedBackgroundView.backgroundColor = backgroundColorSelection
                self.selectedBackgroundView = selectedBackgroundView
            }
        }
    }
    
}

public extension CountryCodePickerViewController.Country {
    var cellDefaultText: String {
        return prefix + " " + flag
    }
    var cellDefaultDetails: String {
        return name
    }
}

#endif
