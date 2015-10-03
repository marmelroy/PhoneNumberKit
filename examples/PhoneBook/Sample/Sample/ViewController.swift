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
        PhoneNumberKit.printMetaDataJSON()
//        let testNumberString : NSString = "0689017383\n\nsdsdsds"
//        let numberParser = PhoneNumberParser()
//        let normailzedNumber : NSString = numberParser.normalizeNonBreakingSpace(testNumberString as String)
//        let extractedNumber = numberParser.extractPossibleNumber(normailzedNumber as String)
//        print(testNumberString, normailzedNumber, extractedNumber);
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

