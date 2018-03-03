//
//  ViewController.swift
//  Example
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit
import PhoneNumberKit

class ViewController: UIViewController, PhoneNumberValidationCodeDataSource, PhoneNumberValidationCodeDelegate {
    
    @IBOutlet weak var validationCodeView: PhoneNumberValidationCode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validationCodeView.defaultText = "-"
        validationCodeView.delegate = self
        validationCodeView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: PhoneNumber Validation Code DataSource
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        label.textAlignment = .center
        label.backgroundColor = .white
        label.textColor = .red
        return label
    }
    
    // MARK: PhoneNumber Validation Code Delegate
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, didEnter text: String) {
        print("Enter:", text)
    }
    
    func validationCode(_ validationCode: PhoneNumberValidationCode, didFinish text: String) {
        print("Finish:", text)
    }

}

