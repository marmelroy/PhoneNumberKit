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
    
    @IBOutlet weak var textField: PhoneNumberTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.region = "FR"
        textField.becomeFirstResponder()
        let text = PartialFormatter().formatPartial("+336895555")
        print(text)
    }

}

