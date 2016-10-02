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

    @IBAction func selectFromContacts(_ sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        self.present(controller,
            animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let firstPhoneNumber = contact.phoneNumbers.first else {
            clearResults()
            return;
        }
        let phoneNumber = firstPhoneNumber.value
        parseNumber(phoneNumber.stringValue)
    }

    func parseNumber(_ number: String) {
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            parsedNumberLabel.text = phoneNumberKit.format(phoneNumber, toType: .international)
            parsedCountryCodeLabel.text = String(phoneNumber.countryCode)
            if let regionCode = phoneNumberKit.mainCountry(forCode:phoneNumber.countryCode) {
                let country = Locale.current.localizedString(forRegionCode: regionCode)
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
