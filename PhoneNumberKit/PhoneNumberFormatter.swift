//
//  PhoneNumberFormatter.swift
//  PhoneNumberKit
//
//  Created by Jean-Daniel.
//  Copyright © 2019 Xenonium. All rights reserved.
//

#if canImport(ObjectiveC)
import Foundation

open class PhoneNumberFormatter: Foundation.Formatter {
    public let phoneNumberKit: PhoneNumberKit

    private let partialFormatter: PartialFormatter

    // We declare all properties as @objc, so we can configure them though IB (using custom property)
    @objc public dynamic
    var generatesPhoneNumber = false

    /// Override region to set a custom region. Automatically uses the default region code.
    @objc public dynamic
    var defaultRegion = PhoneNumberKit.defaultRegionCode() {
        didSet {
            self.partialFormatter.defaultRegion = self.defaultRegion
        }
    }

    @objc public dynamic
    var withPrefix: Bool = true {
        didSet {
            self.partialFormatter.withPrefix = self.withPrefix
        }
    }

    @objc public dynamic
    var currentRegion: String {
        return self.partialFormatter.currentRegion
    }

    // MARK: Lifecycle

    public init(phoneNumberKit pnk: PhoneNumberKit = PhoneNumberKit(), defaultRegion: String = PhoneNumberKit.defaultRegionCode(), withPrefix: Bool = true) {
        self.phoneNumberKit = pnk
        self.partialFormatter = PartialFormatter(phoneNumberKit: self.phoneNumberKit, defaultRegion: defaultRegion, withPrefix: withPrefix)
        super.init()
    }

    public required init?(coder aDecoder: NSCoder) {
        self.phoneNumberKit = PhoneNumberKit()
        self.partialFormatter = PartialFormatter(phoneNumberKit: self.phoneNumberKit, defaultRegion: self.defaultRegion, withPrefix: self.withPrefix)
        super.init(coder: aDecoder)
    }
}

// MARK: -

// MARK: NSFormatter implementation

extension PhoneNumberFormatter {
    override open func string(for obj: Any?) -> String? {
        if let pn = obj as? PhoneNumber {
            return self.phoneNumberKit.format(pn, toType: self.withPrefix ? .international : .national)
        }
        if let str = obj as? String {
            return self.partialFormatter.formatPartial(str)
        }
        return nil
    }

    override open func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        if self.generatesPhoneNumber {
            do {
                obj?.pointee = try self.phoneNumberKit.parse(string) as AnyObject?
                return true
            } catch let e {
                error?.pointee = e.localizedDescription as NSString
                return false
            }
        } else {
            obj?.pointee = string as NSString
            return true
        }
    }

    // MARK: Phone number formatting

    ///  To keep the cursor position, we find the character immediately after the cursor and count the number of times it repeats in the remaining string as this will remain constant in every kind of editing.
    private struct CursorPosition {
        let numberAfterCursor: unichar
        let repetitionCountFromEnd: Int
    }

    private func extractCursorPosition(from text: NSString, selection selectedTextRange: NSRange) -> CursorPosition? {
        var repetitionCountFromEnd = 0

        // The selection range is based on NSString representation
        var cursorEnd = selectedTextRange.location + selectedTextRange.length

        guard cursorEnd < text.length else {
            // Cursor at end of string
            return nil
        }

        // Get the character after the cursor
        var char: unichar
        repeat {
            char = text.character(at: cursorEnd) // should work even if char is start of compound sequence
            cursorEnd += 1
            // We consider only digit as other characters may be inserted by the formatter (especially spaces)
        } while !char.isDigit() && cursorEnd < text.length

        guard cursorEnd < text.length else {
            // Cursor at end of string
            return nil
        }

        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEnd..<text.length {
            if text.character(at: i) == char {
                repetitionCountFromEnd += 1
            }
        }
        return CursorPosition(numberAfterCursor: char, repetitionCountFromEnd: repetitionCountFromEnd)
    }

    private enum Action {
        case insert
        case replace
        case delete
    }

    private func action(for origString: NSString, range: NSRange, proposedString: NSString, proposedRange: NSRange) -> Action {
        // If origin range length > 0, this is a delete or replace action
        if range.length == 0 {
            return .insert
        }

        // If proposed length = orig length - orig range length -> this is delete action
        if origString.length - range.length == proposedString.length {
            return .delete
        }
        // If proposed length > orig length - orig range length -> this is replace action
        return .replace
    }

    override open func isPartialStringValid(
        _ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>,
        proposedSelectedRange proposedSelRangePtr: NSRangePointer?,
        originalString origString: String,
        originalSelectedRange origSelRange: NSRange,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        guard let proposedSelRangePtr = proposedSelRangePtr else {
            // I guess this is an annotation issue. I can't see a valid case where the pointer can be null
            return true
        }

        // We want to allow space deletion or insertion
        let orig = origString as NSString
        let action = self.action(for: orig, range: origSelRange, proposedString: partialStringPtr.pointee, proposedRange: proposedSelRangePtr.pointee)
        if action == .delete && orig.isWhiteSpace(in: origSelRange) {
            // Deleting white space
            return true
        }

        // Also allow to add white space ?
        if action == .insert || action == .replace {
            // Determine the inserted text range. This is the range starting at orig selection index and with length = ∆length
            let length = partialStringPtr.pointee.length - orig.length + origSelRange.length
            if partialStringPtr.pointee.isWhiteSpace(in: NSRange(location: origSelRange.location, length: length)) {
                return true
            }
        }

        let text = partialStringPtr.pointee as String
        let formattedNationalNumber = self.partialFormatter.formatPartial(text)
        guard formattedNationalNumber != text else {
            // No change, no need to update the text
            return true
        }

        // Fix selection

        // The selection range is based on NSString representation
        let formattedTextNSString = formattedNationalNumber as NSString
        if let cursor = extractCursorPosition(from: partialStringPtr.pointee, selection: proposedSelRangePtr.pointee) {
            var remaining = cursor.repetitionCountFromEnd
            for i in stride(from: formattedTextNSString.length - 1, through: 0, by: -1) {
                if formattedTextNSString.character(at: i) == cursor.numberAfterCursor {
                    if remaining > 0 {
                        remaining -= 1
                    } else {
                        // We are done
                        proposedSelRangePtr.pointee = NSRange(location: i, length: 0)
                        break
                    }
                }
            }
        } else {
            // assume the pointer is at end of string
            proposedSelRangePtr.pointee = NSRange(location: formattedTextNSString.length, length: 0)
        }

        partialStringPtr.pointee = formattedNationalNumber as NSString
        return false
    }
}

private extension NSString {
    func isWhiteSpace(in range: NSRange) -> Bool {
        return rangeOfCharacter(from: CharacterSet.whitespacesAndNewlines.inverted, options: [.literal], range: range).location == NSNotFound
    }
}

private extension unichar {
    func isDigit() -> Bool {
        return self >= 0x30 && self <= 0x39 // '0' < '9'
    }
}
#endif
