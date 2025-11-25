//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 27/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import ContactsUI
import Foundation
import PhoneNumberKit
import UIKit

final class ViewController: UIViewController, CNContactPickerDelegate {
    @IBOutlet var textField: PhoneNumberTextField!
    @IBOutlet var withPrefixSwitch: UISwitch!
    @IBOutlet var withFlagSwitch: UISwitch!
    @IBOutlet var withExamplePlaceholderSwitch: UISwitch!
    @IBOutlet var withDefaultPickerUISwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["US", "CA", "MX", "AU", "GB", "DE"]
        PhoneNumberKit.CountryCodePicker.alwaysShowsSearchBar = true
        
        self.withPrefixSwitch.isOn = self.textField.withPrefix
        self.withFlagSwitch.isOn = self.textField.withFlag
        self.withExamplePlaceholderSwitch.isOn = self.textField.withExamplePlaceholder
        self.withDefaultPickerUISwitch.isOn = self.textField.withDefaultPickerUI
        
        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        }
        let cellNib = UINib(nibName: "CustomCell", bundle: .main)
        
        let cellOptions = CountryCodePickerOptions.CountryCodePickerCellOptions(
            textLabelColor: nil,
            textLabelFont: nil,
            detailTextLabelColor: nil,
            detailTextLabelFont: nil,
            backgroundColor: nil,
            backgroundColorSelection: nil,
            cellType: .cellNib(cellNib, identifier: CustomCell.reuseIdentifier),
            height: CustomCell.defaultHeight
        )
        
        let headerNib = UINib(nibName: "CustomHeaderView", bundle: .main)
        let headerOptions = CountryCodePickerOptions.CountryCodePickerHeaderOptions(
            textLabelColor: .blue,
            textLabelFont: .boldSystemFont(ofSize: 18),
            backgroundColor: nil,
            cellType: .cellNib(headerNib, identifier: CustomHeaderView.reuseIdentifier),
            height: CustomHeaderView.defaultHeight
        )
        
        textField.withDefaultPickerUIOptions = CountryCodePickerOptions(
            backgroundColor: .yellow,
            separatorColor: .blue,
            tintColor: .green,
            cellOptions: cellOptions,
            headerOptions: headerOptions
        )
        
        textField.stateDelegate = self
    }

    @IBAction func didTapView(_ sender: Any) {
        self.textField.resignFirstResponder()
    }

    @IBAction func withPrefixDidChange(_ sender: Any) {
        self.textField.withPrefix = self.withPrefixSwitch.isOn
    }

    @IBAction func withFlagDidChange(_ sender: Any) {
        self.textField.withFlag = self.withFlagSwitch.isOn
    }

    @IBAction func withExamplePlaceholderDidChange(_ sender: Any) {
        self.textField.withExamplePlaceholder = self.withExamplePlaceholderSwitch.isOn
        if !self.textField.withExamplePlaceholder {
            self.textField.placeholder = "Enter phone number"
        }
    }

    @IBAction func withDefaultPickerUIDidChange(_ sender: Any) {
        self.textField.withDefaultPickerUI = self.withDefaultPickerUISwitch.isOn
    }
}

extension ViewController: UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        print("ViewController - will show vc: \(viewController)")
    }

    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        print("ViewController - did show vc: \(viewController)")
    }
}


extension ViewController: PhoneNumberTextFieldDelegate {
    func countryCodePickerViewControllerWillPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {
        print("Will present country code picker")
        textField.resignFirstResponder()
    }
    func countryCodePickerViewControllerDidPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {
        print("Did present country code picker")
    }
    func countryCodePickerViewControllerWillDismiss(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {
        print("Will dismiss country code picker")
    }
    func countryCodePickerViewControllerDidDismiss(_ textField: PhoneNumberTextField) {
        print("Did dismiss country code picker")
        textField.becomeFirstResponder()
    }
}
