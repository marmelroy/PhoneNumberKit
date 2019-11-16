//
//  NSRegularExpression+Swift.swift
//  PhoneNumberKit
//
//  Created by David Beck on 8/15/16.
//  Copyright © 2016 Roy Marmelstein. All rights reserved.
//

import Foundation

extension String {
    func nsRange(from range: Range<String.Index>) -> NSRange {
        let utf16view = self.utf16
        let from = range.lowerBound.samePosition(in: utf16view) ?? self.startIndex
        let to = range.upperBound.samePosition(in: utf16view) ?? self.endIndex
        return NSRange(location: utf16view.distance(from: utf16view.startIndex, to: from), length: utf16view.distance(from: from, to: to))
    }

    func range(from nsRange: NSRange) -> Range<String.Index>? {
        guard
            let from16 = utf16.index(utf16.startIndex, offsetBy: nsRange.location, limitedBy: utf16.endIndex),
            let to16 = utf16.index(from16, offsetBy: nsRange.length, limitedBy: utf16.endIndex),
            let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self)
        else { return nil }
        return from..<to
    }
}

extension NSRegularExpression {
    func enumerateMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, using block: (NSTextCheckingResult?, NSRegularExpression.MatchingFlags, UnsafeMutablePointer<ObjCBool>) -> Swift.Void) {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        self.enumerateMatches(in: string, options: options, range: nsRange, using: block)
    }

    func matches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> [NSTextCheckingResult] {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        return self.matches(in: string, options: options, range: nsRange)
    }

    func numberOfMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> Int {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        return self.numberOfMatches(in: string, options: options, range: nsRange)
    }

    func firstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> NSTextCheckingResult? {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        return self.firstMatch(in: string, options: options, range: nsRange)
    }

    func rangeOfFirstMatch(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil) -> Range<String.Index>? {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        let match = self.rangeOfFirstMatch(in: string, options: options, range: nsRange)

        return string.range(from: match)
    }

    func stringByReplacingMatches(in string: String, options: NSRegularExpression.MatchingOptions = [], range: Range<String.Index>? = nil, withTemplate templ: String) -> String {
        let range = range ?? string.startIndex..<string.endIndex
        let nsRange = string.nsRange(from: range)

        return self.stringByReplacingMatches(in: string, options: options, range: nsRange, withTemplate: templ)
    }
}
