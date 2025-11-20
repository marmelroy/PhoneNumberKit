#if os(iOS)
import UIKit

public extension CountryCodePickerViewController {
    
    /// Protocol defining the interface for section header views in the country code picker.
    protocol CountryCodePickerSectionHeaderViewProtocol: UITableViewHeaderFooterView {
        /// Configuration options for the header appearance.
        var options: CountryCodePickerOptions.CountryCodePickerHeaderOptions { get set }
        /// Configures the header with the given title.
        /// - Parameter title: The title to display in the header.
        func configure(with title: String?)
    }
    
    class CountryCodePickerSectionHeader: UITableViewHeaderFooterView, CountryCodePickerSectionHeaderViewProtocol {
        public static let reuseIdentifier = "CountryCodePickerSectionHeader"
        public static let defaultHeight: CGFloat = 38.0
        
        /// Label to display the section title.
        public let titleLabel = UILabel()
        
        /// Configuration options for the header appearance.
        public var options: CountryCodePickerOptions.CountryCodePickerHeaderOptions = .default {
            didSet {
                if options != oldValue {
                    configureOptions()
                }
            }
        }
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            setupViews()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setupViews() {
            // Configure and add subviews to the contentView
            contentView.addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
            ])
            
            configureOptions()
        }
        
        // MARK: Configuration
        public func configure(with title: String?) {
            let displayTitle: String?
            // Ensure compatibility with iOS versions for text casing
            if #available(iOS 26.0, *) {
                displayTitle = title
            } else {
                displayTitle = title?.uppercased()
            }
            titleLabel.text = displayTitle
        }
        
        private func configureOptions() {
            if let textLabelColor = options.textLabelColor {
                self.titleLabel.textColor = textLabelColor
            }
            if let textLabelFont = options.textLabelFont {
                self.titleLabel.font = textLabelFont
            }
            if let backgroundColor = options.backgroundColor {
                self.contentView.backgroundColor = backgroundColor
            }
        }
    }
}

// MARK: Constants

public extension CountryCodePickerViewController.CountryCodePickerSectionHeader { enum Constants {} }
public extension CountryCodePickerViewController.CountryCodePickerSectionHeader.Constants {
    static let titleColor: UIColor = {
       if #available(iOS 13.0, *) {
           return UIColor.secondaryLabel
        } else {
            // I'm not able to verify colors on iOS 12. But it should be close enough.
            return UIColor.darkGray
        }
    }()
    
    static let titleFont: UIFont = {
        // Use preferred font for headline on iOS 26 and above, else footnote for simalar font to default header
        if #available(iOS 26.0, *) {
            return .preferredFont(forTextStyle: .headline)
        } else {
            return .preferredFont(forTextStyle: .footnote)
        }
    }()
}

#endif
