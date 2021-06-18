//
//  ViewController.swift
//  AsYouTypeMacOS
//
//  Created by Umur Gedik on 17.06.2021.
//

import Cocoa
import PhoneNumberKit

class ViewController: NSViewController {
    @IBOutlet weak var phoneField: PhoneNumberTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        phoneField.withFlag = true
        phoneField.withExamplePlaceholder = true
        phoneField.withPrefix = true
        phoneField.font = .systemFont(ofSize: 20)
    }
}

