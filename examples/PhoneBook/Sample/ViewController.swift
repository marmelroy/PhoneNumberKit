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

    let phoneNumberKit = PhoneNumberKit()

    @IBOutlet weak var parsedNumberLabel: UILabel!
    @IBOutlet weak var parsedCountryCodeLabel: UILabel!
    @IBOutlet weak var parsedCountryLabel: UILabel!
    
    let notAvailable = "NA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectFromContacts(sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        self.presentViewController(controller,
            animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact) {
        if contact.phoneNumbers.count > 0 {
            if let phoneNumber = contact.phoneNumbers.first.value as? CNPhoneNumber {
                parseNumber(phoneNumber.stringValue)
            }
        }
        else {
            clearResults()
            print("Something went wrong")
        }
    }

    func parseNumber(number: String) {
        do {
            let phoneNumber = try PhoneNumber(rawNumber: number)
            parsedNumberLabel.text = phoneNumber.toInternational()
            parsedCountryCodeLabel.text = String(phoneNumber.countryCode)
            if let regionCode = phoneNumberKit.mainCountryForCode(phoneNumber.countryCode) {
                let country = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: regionCode)
                parsedCountryLabel.text = country
            }
        }
        catch {
            clearResults()
            print("Something went wrong")
        }
    }
    
    func clearResults() {
        parsedNumberLabel.text = notAvailable
        parsedCountryCodeLabel.text = notAvailable
        parsedCountryLabel.text = notAvailable
    }

}
