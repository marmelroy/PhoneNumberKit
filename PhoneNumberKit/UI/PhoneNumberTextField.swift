//
//  PhoneNumberTextField.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 07/11/2015.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit

/// Custom text field that formats phone numbers
open class PhoneNumberTextField: UITextField, UITextFieldDelegate {
    public let phoneNumberKit: PhoneNumberKit

    public lazy var flagButton = UIButton()

    /// Override setText so number will be automatically formatted when setting text by code
    override open var text: String? {
        set {
            if isPartialFormatterEnabled, let newValue = newValue {
                let formattedNumber = partialFormatter.formatPartial(newValue)
                super.text = formattedNumber
            } else {
                super.text = newValue
            }
            NotificationCenter.default.post(name: UITextField.textDidChangeNotification, object: self)
            self.updateFlag()
        }
        get {
            return super.text
        }
    }

    /// allows text to be set without formatting
    open func setTextUnformatted(newValue: String?) {
        super.text = newValue
    }

    private lazy var _defaultRegion: String = PhoneNumberKit.defaultRegionCode()

    /// Override region to set a custom region. Automatically uses the default region code.
    open var defaultRegion: String {
        get {
            return self._defaultRegion
        }
        @available(
            *,
            deprecated,
            message: """
                The setter of defaultRegion is deprecated,
                please override defaultRegion in a subclass instead.
            """
        )
        set {
            self.partialFormatter.defaultRegion = newValue
        }
    }

    public var withPrefix: Bool = true {
        didSet {
            self.partialFormatter.withPrefix = self.withPrefix
            if self.withPrefix == false {
                self.keyboardType = .numberPad
            } else {
                self.keyboardType = .phonePad
            }
            if self.withExamplePlaceholder {
                self.updatePlaceholder()
            }
        }
    }

    public var withPrefixPrefill: Bool = true

    public var withFlag: Bool = false {
        didSet {
            leftView = self.withFlag ? self.flagButton : nil
            leftViewMode = self.withFlag ? .always : .never
            self.updateFlag()
        }
    }

    public var withExamplePlaceholder: Bool = false {
        didSet {
            if self.withExamplePlaceholder {
                self.updatePlaceholder()
            } else {
                attributedPlaceholder = nil
            }
        }
    }

    #if compiler(>=5.1)
    /// Available on iOS 13 and above just.
    public var countryCodePlaceholderColor: UIColor = {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return .secondaryLabel
        } else {
            return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
    }() {
        didSet {
            self.updatePlaceholder()
        }
    }

    /// Available on iOS 13 and above just.
    public var numberPlaceholderColor: UIColor = {
        if #available(iOS 13.0, tvOS 13.0, *) {
            return .tertiaryLabel
        } else {
            return UIColor(red: 0, green: 0, blue: 0.0980392, alpha: 0.22)
        }
    }() {
        didSet {
            self.updatePlaceholder()
        }
    }
    #endif

    private var _withDefaultPickerUI: Bool = false {
        didSet {
            if flagButton.actions(forTarget: self, forControlEvent: .touchUpInside) == nil {
                flagButton.addTarget(self, action: #selector(didPressFlagButton), for: .touchUpInside)
            }
        }
    }

    public var withDefaultPickerUI: Bool {
        get { _withDefaultPickerUI }
        set { _withDefaultPickerUI = newValue }
    }

    public var withDefaultPickerUIOptions: CountryCodePickerOptions = .init()

    public var modalPresentationStyle: UIModalPresentationStyle?

    public var isPartialFormatterEnabled = true

    public var maxDigits: Int? {
        didSet {
            self.partialFormatter.maxDigits = self.maxDigits
        }
    }

    public private(set) lazy var partialFormatter: PartialFormatter = .init(
        phoneNumberKit: phoneNumberKit,
        defaultRegion: defaultRegion,
        withPrefix: withPrefix,
        ignoreIntlNumbers: true
    )

    let nonNumericSet: CharacterSet = {
        var mutableSet = CharacterSet.decimalDigits.inverted
        mutableSet.remove(charactersIn: PhoneNumberConstants.plusChars)
        mutableSet.remove(charactersIn: PhoneNumberConstants.pausesAndWaitsChars)
        mutableSet.remove(charactersIn: PhoneNumberConstants.operatorChars)
        return mutableSet
    }()

    private weak var _delegate: UITextFieldDelegate?

    override open var delegate: UITextFieldDelegate? {
        get {
            return self._delegate
        }
        set {
            self._delegate = newValue
        }
    }

    // MARK: Status

    public var currentRegion: String {
        return self.partialFormatter.currentRegion
    }

    public var nationalNumber: String {
        let rawNumber = self.text ?? String()
        return self.partialFormatter.nationalNumber(from: rawNumber)
    }

    public var isValidNumber: Bool {
        let rawNumber = self.text ?? String()
        do {
            _ = try phoneNumberKit.parse(rawNumber, withRegion: currentRegion)
            return true
        } catch {
            return false
        }
    }

    /// Returns the current valid phone number.
    /// - returns: PhoneNumber?
    public var phoneNumber: PhoneNumber? {
        guard let rawNumber = self.text else { return nil }
        do {
            return try phoneNumberKit.parse(rawNumber, withRegion: currentRegion)
        } catch {
            return nil
        }
    }

    override open func layoutSubviews() {
        if self.withFlag { // update the width of the flagButton automatically, iOS <13 doesn't handle this for you
            let width = self.flagButton.systemLayoutSizeFitting(bounds.size).width
            self.flagButton.frame.size.width = width
        }
        super.layoutSubviews()
    }

    // MARK: - Insets

    private var insets: UIEdgeInsets?
    private var clearButtonPadding: CGFloat?

    // MARK: Lifecycle

    /// Init with a phone number kit instance. Because a PhoneNumberKit initialization is expensive,
    /// you can pass a pre-initialized instance to avoid incurring perf penalties.
    ///
    /// - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.
    ///
    /// - returns: UITextfield
    public convenience init(withPhoneNumberKit phoneNumberKit: PhoneNumberKit) {
        self.init(frame: .zero, phoneNumberKit: phoneNumberKit)
    }

    /// Init with frame and phone number kit instance.
    ///
    /// - parameter frame: UITextfield frame
    /// - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.
    ///
    /// - returns: UITextfield
    public init(frame: CGRect, phoneNumberKit: PhoneNumberKit) {
        self.phoneNumberKit = phoneNumberKit
        super.init(frame: frame)
        self.setup()
    }

    /// Init with frame
    ///
    /// - parameter frame: UITextfield F
    ///
    /// - returns: UITextfield
    override public init(frame: CGRect) {
        self.phoneNumberKit = PhoneNumberKit()
        super.init(frame: frame)
        self.setup()
    }

    /// Initialize an instance with specific insets and clear button padding.
    ///
    /// This initializer creates an instance of the class with custom UIEdgeInsets and padding for the clear button.
    /// Both of these parameters are used to customize the appearance of the text field and its clear button within the class.
    ///
    /// - Parameters:
    ///   - insets: The UIEdgeInsets to be applied to the text field's bounding rectangle. These insets define the padding
    ///     that is applied within the text field's bounding rectangle. A UIEdgeInsets value contains insets for
    ///     each of the four directions (top, bottom, left, right). Positive values move the content toward the center of the
    ///     text field, and negative values move the content toward the edges of the text field.
    ///   - clearButtonPadding: The padding to be applied to the clear button. This value defines the space between the clear
    ///     button and the edges of the text field. A positive value increases the distance between the clear button and the
    ///     text field's edges, and a negative value decreases this distance.
    public init(insets: UIEdgeInsets, clearButtonPadding: CGFloat) {
        self.phoneNumberKit = PhoneNumberKit()
        self.insets = insets
        self.clearButtonPadding = clearButtonPadding
        super.init(frame: .zero)
        self.setup()
    }

    /// Init with coder
    ///
    /// - parameter aDecoder: decoder
    ///
    /// - returns: UITextfield
    public required init(coder aDecoder: NSCoder) {
        self.phoneNumberKit = PhoneNumberKit()
        super.init(coder: aDecoder)!
        self.setup()
    }

    func setup() {
        self.autocorrectionType = .no
        self.keyboardType = .phonePad
        super.delegate = self
    }

    func internationalPrefix(for countryCode: String) -> String? {
        guard let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description else { return nil }
        return "+" + countryCode
    }

    open func updateFlag() {
        guard self.withFlag else { return }

        if let phoneNumber = phoneNumber,
           let regionCode = phoneNumber.regionID,
           regionCode != currentRegion,
           phoneNumber.countryCode == phoneNumberKit.countryCode(for: currentRegion) {
            _defaultRegion = regionCode
            partialFormatter.defaultRegion = regionCode
        }

        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value

        let flag = self.currentRegion
            .uppercased()
            .unicodeScalars
            .compactMap { UnicodeScalar(flagBase + $0.value)?.description }
            .joined()

        self.flagButton.setTitle(flag + " ", for: .normal)
        self.flagButton.accessibilityLabel = NSLocalizedString(
            "PhoneNumberKit.CountryCodePickerEntryButton.AccessibilityLabel",
            value: "Select your country code",
            comment: "Accessibility Label for Country Code Picker button")

        if let countryName = Locale.autoupdatingCurrent.localizedString(forRegionCode: self.currentRegion) {
            let selectedFormat = NSLocalizedString(
                "PhoneNumberKit.CountryCodePickerEntryButton.AccessibilityHint",
                value: "%@ selected",
                comment: "Accessiblity hint for currently selected country code")
            self.flagButton.accessibilityHint = String(format: selectedFormat, countryName)
        }
        let fontSize = (font ?? UIFont.preferredFont(forTextStyle: .body)).pointSize
        self.flagButton.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
    }

    open func updatePlaceholder() {
        guard self.withExamplePlaceholder else { return }
        if isEditing, !(self.text ?? "").isEmpty { return } // No need to update a placeholder while the placeholder isn't showing

        let format = self.withPrefix ? PhoneNumberFormat.international : .national
        let example = self.phoneNumberKit.getFormattedExampleNumber(forCountry: self.currentRegion, withFormat: format, withPrefix: self.withPrefix) ?? "12345678"
        let font = self.font ?? UIFont.preferredFont(forTextStyle: .body)
        let ph = NSMutableAttributedString(string: example, attributes: [.font: font])

        #if compiler(>=5.1)
        if #available(iOS 13.0, *), self.withPrefix {
            // because the textfield will automatically handle insert & removal of the international prefix we make the
            // prefix darker to indicate non default behaviour to users, this behaviour currently only happens on iOS 13
            // and above just because that is where we have access to label colors
            let firstSpaceIndex = example.firstIndex(where: { $0 == " " }) ?? example.startIndex

            ph.addAttribute(.foregroundColor, value: self.countryCodePlaceholderColor, range: NSRange(..<firstSpaceIndex, in: example))
            ph.addAttribute(.foregroundColor, value: self.numberPlaceholderColor, range: NSRange(firstSpaceIndex..., in: example))
        }
        #endif

        self.attributedPlaceholder = ph
    }

    @objc func didPressFlagButton() {
        guard withDefaultPickerUI else { return }
        let vc = CountryCodePickerViewController(phoneNumberKit: phoneNumberKit,
                                                 options: withDefaultPickerUIOptions)
        vc.delegate = self
        if let nav = containingViewController?.navigationController, !PhoneNumberKit.CountryCodePicker.forceModalPresentation {
            nav.pushViewController(vc, animated: true)
        } else {
            let nav = UINavigationController(rootViewController: vc)
            if modalPresentationStyle != nil {
                nav.modalPresentationStyle = modalPresentationStyle!
            }
            containingViewController?.present(nav, animated: true)
        }
    }

    /// containingViewController looks at the responder chain to find the view controller nearest to itself
    var containingViewController: UIViewController? {
        var responder: UIResponder? = self
        while !(responder is UIViewController), responder != nil {
            responder = responder?.next
        }
        return (responder as? UIViewController)
    }

    // MARK: Phone number formatting

    ///  To keep the cursor position, we find the character immediately after the cursor and count the number of times it repeats in the remaining string as this will remain constant in every kind of editing.

    struct CursorPosition {
        let numberAfterCursor: String
        let repetitionCountFromEnd: Int
    }

    func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard let text = text, let selectedTextRange = selectedTextRange else {
            return nil
        }
        let textAsNSString = text as NSString
        let cursorEnd = offset(from: beginningOfDocument, to: selectedTextRange.end)
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEnd..<textAsNSString.length {
            let cursorRange = NSRange(location: i, length: 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substring(with: cursorRange) as NSString
            if candidateNumberAfterCursor.rangeOfCharacter(from: self.nonNumericSet).location == NSNotFound {
                for j in cursorRange.location..<textAsNSString.length {
                    let candidateCharacter = textAsNSString.substring(with: NSRange(location: j, length: 1))
                    if candidateCharacter == candidateNumberAfterCursor as String {
                        repetitionCountFromEnd += 1
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor as String, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }

    // Finds position of previous cursor in new formatted text
    func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        let textAsNSString = formattedText as NSString
        var countFromEnd = 0
        guard let cursorPosition = extractCursorPosition() else {
            return nil
        }

        for i in stride(from: textAsNSString.length - 1, through: 0, by: -1) {
            let candidateRange = NSRange(location: i, length: 1)
            let candidateCharacter = textAsNSString.substring(with: candidateRange)
            if candidateCharacter == cursorPosition.numberAfterCursor {
                countFromEnd += 1
                if countFromEnd == cursorPosition.repetitionCountFromEnd {
                    return candidateRange
                }
            }
        }

        return nil
    }

    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = text else {
            return false
        }

        // allow delegate to intervene
        guard self._delegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true else {
            return false
        }
        guard self.isPartialFormatterEnabled else {
            return true
        }

        // This allows for the case when a user autocompletes a phone number:
        if range == NSRange(location: 0, length: 0), string.isBlank {
            return true
        }

        let textAsNSString = text as NSString
        let changedRange = textAsNSString.substring(with: range) as NSString
        let modifiedTextField = textAsNSString.replacingCharacters(in: range, with: string)

        let filteredCharacters = modifiedTextField.filter {
            String($0).rangeOfCharacter(from: (textField as! PhoneNumberTextField).nonNumericSet) == nil
        }
        let rawNumberString = String(filteredCharacters)

        let formattedNationalNumber = self.partialFormatter.formatPartial(rawNumberString as String)
        var selectedTextRange: NSRange?

        let nonNumericRange = (changedRange.rangeOfCharacter(from: self.nonNumericSet).location != NSNotFound)
        if range.length == 1, string.isEmpty, nonNumericRange {
            selectedTextRange = self.selectionRangeForNumberReplacement(textField: textField, formattedText: modifiedTextField)
            textField.text = modifiedTextField
        } else {
            selectedTextRange = self.selectionRangeForNumberReplacement(textField: textField, formattedText: formattedNationalNumber)
            textField.text = formattedNationalNumber
        }
        sendActions(for: .editingChanged)
        if let selectedTextRange = selectedTextRange, let selectionRangePosition = textField.position(from: beginningOfDocument, offset: selectedTextRange.location) {
            let selectionRange = textField.textRange(from: selectionRangePosition, to: selectionRangePosition)
            textField.selectedTextRange = selectionRange
        }

        // we change the default region to be the one most recently typed
        // but only when the withFlag is true as to not confuse the user who don't see the flag
        if withFlag == true {
            self._defaultRegion = self.currentRegion
            self.partialFormatter.defaultRegion = self.currentRegion
            self.updateFlag()
            self.updatePlaceholder()
        }

        return false
    }

    // MARK: UITextfield Delegate

    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self._delegate?.textFieldShouldBeginEditing?(textField) ?? true
    }

    open func textFieldDidBeginEditing(_ textField: UITextField) {
        if self.withExamplePlaceholder, self.withPrefixPrefill, self.withPrefix, let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description, (text ?? "").isEmpty {
            text = "+" + countryCode + " "
        }
        self._delegate?.textFieldDidBeginEditing?(textField)
    }

    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self._delegate?.textFieldShouldEndEditing?(textField) ?? true
    }

    open func textFieldDidEndEditing(_ textField: UITextField) {
        updateTextFieldDidEndEditing(textField)
        self._delegate?.textFieldDidEndEditing?(textField)
    }

    open func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        updateTextFieldDidEndEditing(textField)
        if let _delegate = _delegate {
            if _delegate.responds(to: #selector(textFieldDidEndEditing(_:reason:))) {
                _delegate.textFieldDidEndEditing?(textField, reason: reason)
            } else {
                _delegate.textFieldDidEndEditing?(textField)
            }
        }
    }

    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self._delegate?.textFieldShouldClear?(textField) ?? true
    }

    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self._delegate?.textFieldShouldReturn?(textField) ?? true
    }

    @available(iOS 13.0, tvOS 13.0, *)
    open func textFieldDidChangeSelection(_ textField: UITextField) {
        self._delegate?.textFieldDidChangeSelection?(textField)
    }

    private func updateTextFieldDidEndEditing(_ textField: UITextField) {
        if self.withExamplePlaceholder, self.withPrefix, let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description,
           let text = textField.text,
           text == internationalPrefix(for: countryCode) {
            textField.text = ""
            sendActions(for: .editingChanged)
            self.updateFlag()
            self.updatePlaceholder()
        }
    }
}

extension PhoneNumberTextField: CountryCodePickerDelegate {
    public func countryCodePickerViewControllerDidPickCountry(_ country: CountryCodePickerViewController.Country) {
        text = isEditing ? "+" + country.prefix : ""
        _defaultRegion = country.code
        partialFormatter.defaultRegion = country.code
        updateFlag()
        updatePlaceholder()

        if let nav = containingViewController?.navigationController, !PhoneNumberKit.CountryCodePicker.forceModalPresentation {
            nav.popViewController(animated: true)
        } else {
            containingViewController?.dismiss(animated: true)
        }
    }
}

// MARK: - Insets

extension PhoneNumberTextField {
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        if let insets = self.insets {
            return super.textRect(forBounds: bounds.inset(by: insets))
        } else {
            return super.textRect(forBounds: bounds)
        }
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        if let insets = self.insets {
            return super.editingRect(forBounds: bounds
                .inset(by: insets))
        } else {
            return super.editingRect(forBounds: bounds)
        }
    }

    override open func clearButtonRect(forBounds bounds: CGRect) -> CGRect {
        if let insets = self.insets,
           let clearButtonPadding = self.clearButtonPadding {
            return super.clearButtonRect(forBounds: bounds.insetBy(dx: insets.left - clearButtonPadding, dy: 0))
        } else {
            return super.clearButtonRect(forBounds: bounds)
        }
    }
}

extension String {
    var isBlank: Bool {
        return allSatisfy(\.isWhitespace)
    }
}

#endif
