#if os(iOS)
import UIKit

public extension CountryCodePickerViewController {
    protocol CountryCodePickerSectionHeaderViewProtocol: UITableViewHeaderFooterView {
        var options: CountryCodePickerOptions.CountryCodePickerHeaderOptions { get set }
        func configure(with title: String?)
    }
    
    class CountryCodePickerSectionHeader: UITableViewHeaderFooterView, CountryCodePickerSectionHeaderViewProtocol {
        public static let reuseIdentifier = "CountryCodePickerSectionHeader"
        public  static let defaultHeight: CGFloat = 38.0
        
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
                titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])

            // Customize appearance
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.textColor = .darkGray
            contentView.backgroundColor = .lightGray // Set background directly on contentView
        }
        
        public func configure(with title: String?) {
            titleLabel.text = title
        }
        
        private func configureOptions() {
            if let textLabelColor = options.textLabelColor {
                self.textLabel?.textColor = textLabelColor
            }
            if let textLabelFont = options.textLabelFont {
                self.textLabel?.font = textLabelFont
            }
            if let backgroundColor = options.backgroundColor {
                self.backgroundColor = backgroundColor
            }
        }
    }
}

#endif
