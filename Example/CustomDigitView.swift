//
//  PhoneNumberDigitView.swift
//  PhoneNumberKit
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit
import PhoneNumberKit

public class CustomDigitView: UIView, PhoneNumberDigitView {
    
    @IBOutlet weak var digitLabel: UILabel!
    @IBOutlet weak var line: UIView!
    
    public var defaultText: String = ""

    
    public func display(_ digit: String?) {
        let newValue = self.digitLabel.text != digit && (digit != nil || self.digitLabel.text != self.defaultText)
        self.digitLabel.text = digit ?? self.defaultText
        if newValue {
            animate()
        }
    }
    
    func animate() {
        UIView.animate(withDuration: 0.45) {
            let color: UIColor = self.digitLabel.text == self.defaultText ? .red : .green
            self.line.backgroundColor = color
        }
    }
    
}

