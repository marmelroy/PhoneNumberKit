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
    
    public var region = PhoneNumberKit().defaultRegionCode() {
        didSet {
            partialFormatter = PartialFormatter(region: region)
        }
    }

    let parser = PhoneNumberParser()
    var partialFormatter = PartialFormatter()

    let nonNumericSet = NSCharacterSet.decimalDigitCharacterSet().invertedSet

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
    
    // MARK: Phone number formatting
    
    internal struct CursorPosition {
        let numberAfterCursor: String
        let repetitionCountFromEnd: Int
    }
    
    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard let text = text, let selectedTextRange = selectedTextRange else {
            return nil
        }
        let textAsNSString = text as NSString
        let cursorEnd = offsetFromPosition(beginningOfDocument, toPosition: selectedTextRange.end)
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for var i = cursorEnd; i < textAsNSString.length; i++  {
            let cursorRange = NSMakeRange(i, 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substringWithRange(cursorRange)
            if (candidateNumberAfterCursor.rangeOfCharacterFromSet(nonNumericSet).location == NSNotFound) {
                for var j = cursorRange.location; j < textAsNSString.length; j++  {
                    let candidateCharacter = textAsNSString.substringWithRange(NSMakeRange(j, 1))
                    if candidateCharacter == candidateNumberAfterCursor {
                        repetitionCountFromEnd++
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor as String, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }
    
    internal func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        let textAsNSString = formattedText as NSString
        var countFromEnd = 0
        guard let cursorPosition = extractCursorPosition() else {
            return nil
        }
        for var i = (textAsNSString.length - 1); i >= 0; i--  {
            let candidateRange = NSMakeRange(i, 1)
            let candidateCharacter = textAsNSString.substringWithRange(candidateRange)
            if candidateCharacter == cursorPosition.numberAfterCursor {
                countFromEnd++
                if countFromEnd == cursorPosition.repetitionCountFromEnd {
                    return candidateRange
                }
            }
        }
        return nil
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard let text = text else {
            return false
        }
        let textAsNSString = text as NSString
        let changedRange = textAsNSString.substringWithRange(range) as NSString
        let modifiedTextField = textAsNSString.stringByReplacingCharactersInRange(range, withString: string)
        let formattedNationalNumber = partialFormatter.formatPartial(modifiedTextField as String)
        let selectedTextRange = selectionRangeForNumberReplacement(textField, formattedText: formattedNationalNumber)
        textField.text = formattedNationalNumber
        let nonNumericRange = (changedRange.rangeOfCharacterFromSet(nonNumericSet).location != NSNotFound)
        if (range.length == 1 && string.isEmpty && nonNumericRange && selectedTextRange != nil)
        {
            if let textRange = textField.selectedTextRange, let selectionRangePosition = textField.positionFromPosition(textRange.start, offset: -1) {
                let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
                textField.selectedTextRange = selectionRange
            }
        }
        else {
            if let selectedTextRange = selectedTextRange, let selectionRangePosition = textField.positionFromPosition(beginningOfDocument, offset: selectedTextRange.location) {
                let selectionRange = textField.textRangeFromPosition(selectionRangePosition, toPosition: selectionRangePosition)
                textField.selectedTextRange = selectionRange
            }
        }
        return false
    }

}