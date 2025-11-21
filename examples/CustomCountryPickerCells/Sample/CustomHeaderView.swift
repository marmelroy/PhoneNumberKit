//
//  CustomHeaderView.swift
//  Sample
//
import UIKit
import PhoneNumberKit

final class CustomHeaderView: UITableViewHeaderFooterView, CountryCodePickerViewController.CountryCodePickerSectionHeaderViewProtocol {
    static let reuseIdentifier = "CustomHeaderView"
    static let defaultHeight: CGFloat = UITableView.automaticDimension
    
    @IBOutlet var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var options: CountryCodePickerOptions.CountryCodePickerHeaderOptions = .default {
        didSet {
            if options != oldValue {
                configureOptions()
            }
        }
    }
    
    public func configure(with title: String?) {
        titleLabel.text = title
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
