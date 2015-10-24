//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 27/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import UIKit
import Foundation
import PhoneNumberKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let phoneNumberKit: PhoneNumberKit = PhoneNumberKit()
        print(phoneNumberKit.countriesForCode(01))
        print(phoneNumberKit.codeForCountry("FR"))
        let phoneNumber = phoneNumberKit.parsePhoneNumber("+82 084 777777 ext. 80", defaultRegion: "KR");
        print(phoneNumber)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

