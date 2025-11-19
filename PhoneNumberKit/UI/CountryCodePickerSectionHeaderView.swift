#if os(iOS)
import UIKit

public extension CountryCodePickerViewController {
    protocol CountryCodePickerSectionHeaderViewProtocol: UITableViewHeaderFooterView {
        var options: CountryCodePickerOptions.CountryCodePickerHeaderOptions { get set }
        func configure(with title: String?)
    }
    
    class CountryCodePickerSectionHeader: UITableViewHeaderFooterView, CountryCodePickerSectionHeaderViewProtocol {
        public static let reuseIdentifier = "CountryCodePickerSectionHeader"
        public static let defaultHeight: CGFloat = 38.0
        
        let titleLabel = UILabel()
        
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
        
        public func configure(with title: String?) {
            titleLabel.text = title?.uppercased()
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
            return UIColor.darkGray
        }
    }()
    
    static let titleFont: UIFont = .systemFont(ofSize: 13)
}

#endif
