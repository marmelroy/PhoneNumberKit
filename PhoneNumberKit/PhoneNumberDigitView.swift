//
//  PhoneNumberDigitView.swift
//  PhoneNumberKit
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit

@objc public protocol PhoneNumberDigitView {

    /// Set on load
    var defaultText: String { get set }
    
    /// Called when digit change. Nil if empty.
    func display(_ digit: String?)

}

public class PhoneNumberDigitLabel: UILabel, PhoneNumberDigitView {
    
    public var defaultText: String = "•"
    
    public func display(_ digit: String?) {
        self.text = digit ?? self.defaultText
    }
    
}
