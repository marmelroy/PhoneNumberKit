//
//  CustomCell.swift
//  Sample
//

import UIKit
import PhoneNumberKit

final class CustomCell: UITableViewCell, CountryCodePickerViewController.CountryCodePickerTableViewCellProtocol {
    static let reuseIdentifier = "CustomCell"
    static let defaultHeight: CGFloat = UITableView.automaticDimension
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
    
    var options: CountryCodePickerOptions.CountryCodePickerCellOptions = .default {
        didSet {
            if options != oldValue {
                configureOptions()
            }
        }
    }
    
    func configure(with country: PhoneNumberKit.CountryCodePickerViewController.Country) {
        titleLabel.text = country.prefix
        subtitleLabel.text = country.flag
        detailsLabel.text = country.name
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
