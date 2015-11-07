//
//  TextField.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 07/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit

public class PhoneNumberTextField: UITextField, UITextFieldDelegate {
    
    weak public var externalDelegate: UITextFieldDelegate?
    
    let parser = PhoneNumberParser()
    let formatter = Formatter()
    let metadata = Metadata.sharedInstance

    var rawValue = String()
    
    override public var delegate: UITextFieldDelegate? {
        get {
          return self.externalDelegate
        }
        set {
           self.externalDelegate = delegate
        }
    }
    
    override public init(frame:CGRect)
    {
        super.init(frame:frame)
        self.setup()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup(){
        self.autocorrectionType = .No
        self.keyboardType = UIKeyboardType.PhonePad
        super.delegate = self
    }
    
    public func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if ((self.externalDelegate?.respondsToSelector("textFieldShouldBeginEditing:")) != nil) {
            return self.externalDelegate!.textFieldShouldBeginEditing!(textField)
        }
        else {
            return true
        }
    }
    
    public func textFieldDidBeginEditing(textField: UITextField) {
        if ((self.externalDelegate?.respondsToSelector("textFieldDidBeginEditing:")) != nil) {
            self.externalDelegate!.textFieldDidBeginEditing!(textField)
        }
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if ((self.externalDelegate?.respondsToSelector("textFieldShouldEndEditing:")) != nil) {
            return self.externalDelegate!.textFieldShouldEndEditing!(textField)
        }
        else {
            return true
        }
    }

    public func textFieldDidEndEditing(textField: UITextField) {
        if ((self.externalDelegate?.respondsToSelector("textFieldDidEndEditing:")) != nil) {
            self.externalDelegate!.textFieldDidEndEditing!(textField)
        }
    }
    
    public func textFieldShouldClear(textField: UITextField) -> Bool {
        if ((self.externalDelegate?.respondsToSelector("textFieldShouldClear:")) != nil) {
            return self.externalDelegate!.textFieldShouldClear!(textField)
        }
        else {
            return true
        }
    }

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if ((self.externalDelegate?.respondsToSelector("textFieldShouldReturn:")) != nil) {
            return self.externalDelegate!.textFieldShouldReturn!(textField)
        }
        else {
            return true
        }
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var nsString = textField.text! as NSString
        nsString = nsString.stringByReplacingCharactersInRange(range, withString: string)
        rawValue = parser.normalizePhoneNumber(nsString as String)
        let defaultRegion = "FR"
        let formattedNationalNumber = formatter.formatNationalNumber(textField.text!, regionMetadata: metadata.metadataPerCountry[defaultRegion]!, formatType: PNNumberFormat.National)
        print(formattedNationalNumber)
        return true
    }

}