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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
    }

}

