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
    let partialFormatter = PartialFormatter()

    
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
    
    func extractNumberFollowingCursor(textField: UITextField, inout numberEndOccurance: Int) -> String? {
        let originalTextField = textField.text! as NSString
        let cursorDocumentBeginning =  textField.beginningOfDocument
        let nonNumericSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        if let selectedTextRange = textField.selectedTextRange {
            let cursorEnd = textField.offsetFromPosition(cursorDocumentBeginning, toPosition: selectedTextRange.end)
            for var i = cursorEnd; i < originalTextField.length; i--  {
                let cursorRange = NSMakeRange(i, 1)
                let cursorEndNumber: NSString = originalTextField.substringWithRange(cursorRange)
                if (cursorEndNumber.rangeOfCharacterFromSet(nonNumericSet).location == NSNotFound) {
                    for var j = cursorRange.location; j < originalTextField.length; j++  {
                        let candidateCharacter = originalTextField.substringWithRange(NSMakeRange(j, 1))
                        if candidateCharacter == cursorEndNumber {
                            numberEndOccurance++
                        }
                    }
                    return cursorEndNumber as String
                }
            }
        }
        return nil
    }
    
    func selectionRangeForNumberReplacement(textField: UITextField, formattedString: String) -> NSRange? {
        var numberOccurance = 0
        let formattedTextField = formattedString as NSString
        var formattedOccurance = 0
        if let cursorEndCharacter = extractNumberFollowingCursor(textField, numberEndOccurance: &numberOccurance) {
            for var i = (formattedTextField.length - 1); i > 0; i--  {
                let candidateRange = NSMakeRange(i, 1)
                let candidateCharacter = formattedTextField.substringWithRange(candidateRange)
                if candidateCharacter == cursorEndCharacter {
                    formattedOccurance++
                    if formattedOccurance  == numberOccurance {
                        return candidateRange
                    }
                }
            }
        }
        return nil
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let cursorDocumentBeginning =  textField.beginningOfDocument
        let originalTextField = textField.text! as NSString
        let nonNumericSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet
        let changedRange = originalTextField.substringWithRange(range) as NSString
        var nonNumericRange = true
        if (changedRange.rangeOfCharacterFromSet(nonNumericSet).location == NSNotFound) {
            nonNumericRange = false
        }
        // Find character after the end of cursor
        let modifiedTextField = originalTextField.stringByReplacingCharactersInRange(range, withString: string)
        let defaultRegion = PhoneNumberKit().defaultRegionCode()
        do {
            let formattedNationalNumber = try partialFormatter.formatPartial(modifiedTextField as String, region: defaultRegion)
            let selectedTextRange = selectionRangeForNumberReplacement(textField, formattedString: formattedNationalNumber)
            textField.text = formattedNationalNumber
            if (range.length == 1 && string.isEmpty && nonNumericRange)
            {
                if let textRange = textField.selectedTextRange, let selectionRangePosition = textField.positionFromPosition(textRange.start, offset: -1) {
                    let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
                    textField.selectedTextRange = selectionRange
                }
            }
            else {
                if let selectedTextRange = selectedTextRange, let selectionRangePosition = textField.positionFromPosition(cursorDocumentBeginning, offset: selectedTextRange.location) {
                    let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
                    textField.selectedTextRange = selectionRange
                }
            }
            
        }
        catch {
            textField.text = modifiedTextField
        }

        return false
    }

}