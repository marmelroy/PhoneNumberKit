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

        PhoneNumberKit.CountryCodePicker.commonCountryCodes = ["US", "CA", "MX", "AU", "GB", "DE"]
        PhoneNumberKit.CountryCodePicker.alwaysShowsSearchBar = true

        self.textField.becomeFirstResponder()
        self.withPrefixSwitch.isOn = self.textField.withPrefix
        self.withFlagSwitch.isOn = self.textField.withFlag
        self.withExamplePlaceholderSwitch.isOn = self.textField.withExamplePlaceholder
        self.withDefaultPickerUISwitch.isOn = self.textField.withDefaultPickerUI

        if #available(iOS 13.0, *) {
            self.view.backgroundColor = .systemBackground
        }
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
