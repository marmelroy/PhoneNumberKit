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

class ViewController: UIViewController, CNContactPickerDelegate {
    let phoneNumberKit = PhoneNumberKit()

    @IBOutlet var parsedNumberLabel: UILabel!
    @IBOutlet var parsedCountryCodeLabel: UILabel!
    @IBOutlet var parsedCountryLabel: UILabel!

    let notAvailable = "NA"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectFromContacts(_ sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        self.present(
            controller,
            animated: true, completion: nil
        )
    }

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let firstPhoneNumber = contact.phoneNumbers.first else {
            self.clearResults()
            return
        }
        let phoneNumber = firstPhoneNumber.value
        self.parseNumber(phoneNumber.stringValue)
    }

    func parseNumber(_ number: String) {
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            self.parsedNumberLabel.text = self.phoneNumberKit.format(phoneNumber, toType: .international)
            self.parsedCountryCodeLabel.text = String(phoneNumber.countryCode)
            if let regionCode = phoneNumberKit.mainCountry(forCode: phoneNumber.countryCode) {
                let country = Locale.current.localizedString(forRegionCode: regionCode)
                self.parsedCountryLabel.text = country
            }
        } catch {
            self.clearResults()
            print("Something went wrong")
        }
    }

    func clearResults() {
        self.parsedNumberLabel.text = self.notAvailable
        self.parsedCountryCodeLabel.text = self.notAvailable
        self.parsedCountryLabel.text = self.notAvailable
    }
}
