//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 27/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import UIKit
import Foundation
import ContactsUI
import PhoneNumberKit

class ViewController: UIViewController, CNContactPickerDelegate {
    
    @IBOutlet weak var textField: PhoneNumberTextField!
    @IBOutlet weak var withPrefixSwitch: UISwitch!
    @IBOutlet weak var withFlagSwitch: UISwitch!
    @IBOutlet weak var withExamplePlaceholderSwitch: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        withPrefixSwitch.isOn = textField.withPrefix
        withFlagSwitch.isOn = textField.withFlag
        withExamplePlaceholderSwitch.isOn = textField.withExamplePlaceholder
    }

    @IBAction func didTapView(_ sender: Any) {
        textField.resignFirstResponder()
    }

    @IBAction func withPrefixDidChange(_ sender: Any) {
        textField.withPrefix = withPrefixSwitch.isOn
    }

    @IBAction func withFlagDidChange(_ sender: Any) {
        textField.withFlag = withFlagSwitch.isOn
    }

    @IBAction func withExamplePlaceholderDidChange(_ sender: Any) {
        textField.withExamplePlaceholder = withExamplePlaceholderSwitch.isOn
        if !textField.withExamplePlaceholder {
            textField.placeholder = "Enter phone number"
        }
    }
}

