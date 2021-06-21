//
//  PhoneNumberTextField_macOS.swift
//  
//
//  Created by Umur Gedik on 17.06.2021.
//

#if canImport(AppKit)

import Foundation
import AppKit

/// Custom text field that formats phone numbers
open class PhoneNumberTextField: NSTextField, NSTextFieldDelegate, NSTextViewDelegate {
    public let phoneNumberKit: PhoneNumberKit

    /// Override setText so number will be automatically formatted when setting text by code
    open override var stringValue: String {
        set {
            if isPartialFormatterEnabled {
                let formattedNumber = partialFormatter.formatPartial(newValue)
                super.stringValue = formattedNumber
            } else {
                super.stringValue = newValue
            }
            NotificationCenter.default.post(name: NSTextField.textDidChangeNotification, object: self)
        }
        get {
            return super.stringValue
        }
    }
    
    /// allows text to be set without formatting
    open func setTextUnformatted(newValue: String) {
        super.stringValue = newValue
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
            if self.withExamplePlaceholder {
                self.updatePlaceholder()
            }
        }
    }
    
    private lazy var allCountries = phoneNumberKit
        .allCountries()
        .compactMap({ Country(for: $0, with: self.phoneNumberKit) })
        .sorted(by: { $0.name.caseInsensitiveCompare($1.name) == .orderedAscending })

    public var withFlag: Bool = false {
        didSet {
            (cell as? PhoneNumberTextFieldCell)?.withFlag = withFlag
            self.updateFlagButton()
            self.updateFlag()
        }
    }
    
    fileprivate lazy var flagButton: NSPopUpButton = {
        let button = NSPopUpButton()
        button.imagePosition = .imageOnly
        button.target = self
        button.action = #selector(flagButtonDidChangeCountry(_:))
        button.isBordered = false
        
        let menu = NSMenu()
        for country in allCountries {
            let menuItem = NSMenuItem()
            menuItem.title = "\(country.name)"
            menuItem.image = NSImage.fromEmoji(country.flag, font: font)
            menuItem.representedObject = country
            menu.addItem(menuItem)
        }
        
        button.menu = menu
        return button
    }()
    
    open override var font: NSFont? {
        didSet {
            guard withFlag else { return }
            
            let index = flagButton.indexOfSelectedItem
            
            let menu = NSMenu()
            for country in allCountries {
                let menuItem = NSMenuItem()
                menuItem.title = "\(country.name)"
                menuItem.image = NSImage.fromEmoji(country.flag, font: font)
                menuItem.representedObject = country
                menu.addItem(menuItem)
            }
            
            flagButton.menu = menu
            flagButton.selectItem(at: index)
            
            updatePlaceholder()
        }
    }
    
    public var withExamplePlaceholder: Bool = false {
        didSet {
            if self.withExamplePlaceholder {
                self.updatePlaceholder()
            } else {
                placeholderAttributedString = nil
            }
        }
    }

    public var countryCodePlaceholderColor: NSColor = .secondaryLabelColor {
        didSet {
            self.updatePlaceholder()
        }
    }

    public var numberPlaceholderColor: NSColor = .tertiaryLabelColor {
        didSet {
            self.updatePlaceholder()
        }
    }

    public var isPartialFormatterEnabled = true

    public var maxDigits: Int? {
        didSet {
            self.partialFormatter.maxDigits = self.maxDigits
        }
    }

    public private(set) lazy var partialFormatter: PartialFormatter = PartialFormatter(
        phoneNumberKit: phoneNumberKit,
        defaultRegion: defaultRegion,
        withPrefix: withPrefix
    )

    let nonNumericSet: NSCharacterSet = {
        var mutableSet = NSMutableCharacterSet.decimalDigit().inverted
        mutableSet.remove(charactersIn: PhoneNumberConstants.plusChars)
        mutableSet.remove(charactersIn: PhoneNumberConstants.pausesAndWaitsChars)
        mutableSet.remove(charactersIn: PhoneNumberConstants.operatorChars)
        return mutableSet as NSCharacterSet
    }()

    private weak var _delegate: NSTextFieldDelegate?

    open override var delegate: NSTextFieldDelegate? {
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
        return self.partialFormatter.nationalNumber(from: self.stringValue)
    }

    public var isValidNumber: Bool {
        do {
            _ = try phoneNumberKit.parse(self.stringValue, withRegion: currentRegion)
            return true
        } catch {
            return false
        }
    }
    
    public var isEditing: Bool = false

    /**
     Returns the current valid phone number.
     - returns: PhoneNumber?
     */
    public var phoneNumber: PhoneNumber? {
        guard !self.stringValue.isEmpty else { return nil }
        do {
            return try phoneNumberKit.parse(self.stringValue, withRegion: currentRegion)
        } catch {
            return nil
        }
    }

    open override func layout() {
        if self.withFlag {
            let size = self.flagButton.fittingSize
            var interiorFrame = frame
            if let cell = cell as? PhoneNumberTextFieldCell {
                interiorFrame = cell.drawingRect(forBounds: frame)
            }
            self.flagButton.frame = CGRect(x: 0, y: interiorFrame.height / 2 - size.height / 2, width: size.width, height: size.height)
        }
        super.layout()
    }

    // MARK: Lifecycle

    /**
     Init with a phone number kit instance. Because a PhoneNumberKit initialization is expensive,
     you can pass a pre-initialized instance to avoid incurring perf penalties.

     - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.

     - returns: NSTextfield
     */
    public convenience init(withPhoneNumberKit phoneNumberKit: PhoneNumberKit) {
        self.init(frame: .zero, phoneNumberKit: phoneNumberKit)
        self.setup()
    }

    /**
     Init with frame and phone number kit instance.

     - parameter frame: NSTextfield frame
     - parameter phoneNumberKit: A PhoneNumberKit instance to be used by the text field.

     - returns: NSTextfield
     */
    public init(frame: CGRect, phoneNumberKit: PhoneNumberKit) {
        self.phoneNumberKit = phoneNumberKit
        super.init(frame: frame)
        self.setup()
    }

    /**
     Init with frame

     - parameter frame: NSTextfield frame

     - returns: NSTextfield
     */
    public override init(frame: CGRect) {
        self.phoneNumberKit = PhoneNumberKit()
        super.init(frame: frame)
        self.setup()
    }

    /**
     Init with coder

     - parameter aDecoder: decoder

     - returns: NSTextfield
     */
    public required init(coder aDecoder: NSCoder) {
        self.phoneNumberKit = PhoneNumberKit()
        super.init(coder: aDecoder)!
        self.setup()
    }

    func setup() {
        super.delegate = self
    }
    
    open override class var cellClass: AnyClass? {
        get {
            PhoneNumberTextFieldCell.self
        }
        set {
            super.cellClass = PhoneNumberTextFieldCell.self
        }
    }
    
    open override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            self.isEditing = true
            if self.withExamplePlaceholder, self.withPrefix, let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description, stringValue.isEmpty {
                stringValue = "+" + countryCode + " "
            }
        }
        
        return result
    }
    
    public func controlTextDidEndEditing(_ obj: Notification) {
        self.isEditing = false
        updateTextFieldDidEndEditing(self)
    }
    
    func internationalPrefix(for countryCode: String) -> String? {
        guard let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description else { return nil }
        return "+" + countryCode
    }
    
    open func updateFlagButton() {
        if withFlag {
            if flagButton.superview != self {
                addSubview(flagButton)
            }
        } else if flagButton.superview != nil {
            flagButton.removeFromSuperview()
        }
    }
    
    func updateFlag() {
        guard
            withFlag,
            let countryIndex = allCountries.firstIndex(where: {$0.code == currentRegion})
        else { return }
        
        flagButton.selectItem(at: countryIndex)
    }

    open func updatePlaceholder() {
        guard self.withExamplePlaceholder else { return }
        if isEditing, !self.stringValue.isEmpty { return } // No need to update a placeholder while the placeholder isn't showing

        let format = self.withPrefix ? PhoneNumberFormat.international : .national
        let example = self.phoneNumberKit.getFormattedExampleNumber(forCountry: self.currentRegion, withFormat: format, withPrefix: self.withPrefix) ?? "12345678"
        let font = self.font ?? NSFont.systemFont(ofSize: NSFont.systemFontSize)
        let ph = NSMutableAttributedString(string: example, attributes: [.font: font])

        if self.withPrefix {
            // because the textfield will automatically handle insert & removal of the international prefix we make the
            // prefix darker to indicate non default behaviour to users, this behaviour currently only happens on iOS 13
            // and above just because that is where we have access to label colors
            let firstSpaceIndex = example.firstIndex(where: { $0 == " " }) ?? example.startIndex

            ph.addAttribute(.foregroundColor, value: self.countryCodePlaceholderColor, range: NSRange(..<firstSpaceIndex, in: example))
            ph.addAttribute(.foregroundColor, value: self.numberPlaceholderColor, range: NSRange(firstSpaceIndex..., in: example))
        }

        self.placeholderAttributedString = ph
    }
    
    @objc func flagButtonDidChangeCountry(_ sender: Any?) {
        guard allCountries.indices.contains(flagButton.indexOfSelectedItem) else {
            return
        }
        
        let country = allCountries[flagButton.indexOfSelectedItem]
        stringValue = isEditing ? "+" + country.prefix : ""
        _defaultRegion = country.code
        partialFormatter.defaultRegion = country.code
        updatePlaceholder()
    }

    // MARK: Phone number formatting

    /**
     *  To keep the cursor position, we find the character immediately after the cursor and count the number of times it repeats in the remaining string as this will remain constant in every kind of editing.
     */

    internal struct CursorPosition {
        let numberAfterCursor: String
        let repetitionCountFromEnd: Int
    }

    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the NSTextField
        let text = self.stringValue
        guard let fieldEditor = self.currentEditor() as? NSTextView else {
            return nil
        }
        
        let selectedRange = fieldEditor.selectedRange()
        if selectedRange.location == NSNotFound {
            return nil
        }
        
        let textAsNSString = text as NSString
        let cursorEndOffset = selectedRange.location
        
        print("cursorEndOffset:", cursorEndOffset)
        
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEndOffset..<textAsNSString.length {
            let cursorRange = NSRange(location: i, length: 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substring(with: cursorRange) as NSString
            if candidateNumberAfterCursor.rangeOfCharacter(from: self.nonNumericSet as CharacterSet).location == NSNotFound {
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
    internal func selectionRangeForNumberReplacement(formattedText: String) -> NSRange? {
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
    
    
    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {
        let replacementString = (replacementString ?? "").filter {
            String($0).rangeOfCharacter(from: self.nonNumericSet as CharacterSet) == nil
        }
        
        let newString = (stringValue as NSString).replacingCharacters(in: affectedCharRange, with: replacementString)
        let textBeforeSel = stringValue.substring(with: NSMakeRange(0, affectedCharRange.location)).filter { String($0).rangeOfCharacter(from: self.nonNumericSet as CharacterSet) == nil }
        
        let formattedText = self.partialFormatter.formatPartial(newString)
        let formattedTextEndingSel = self.partialFormatter.formatPartial(textBeforeSel + replacementString)
        let newSelectedRange = NSMakeRange((formattedTextEndingSel as NSString).length, 0)
        stringValue = formattedText
        textView.setSelectedRange(newSelectedRange)
        
        self._defaultRegion = self.currentRegion
        self.partialFormatter.defaultRegion = self.currentRegion
        self.updateFlag()
        self.updatePlaceholder()
        
        return false
    }
    
    // MARK: NSTextfield Delegate

    open func control(_ control: NSControl, textShouldBeginEditing fieldEditor: NSText) -> Bool {
        return self._delegate?.control?(control, textShouldBeginEditing: fieldEditor) ?? true
    }
    
    open func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        return self._delegate?.control?(control, textShouldEndEditing: fieldEditor) ?? true
    }
    
    open func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        delegate?.control?(control, textView: textView, doCommandBy: commandSelector) ?? false
    }
    
    public func controlTextDidChange(_ obj: Notification) {
        delegate?.controlTextDidChange?(obj)
    }
    
    private func updateTextFieldDidEndEditing(_ textField: NSTextField) {
        if self.withExamplePlaceholder, self.withPrefix, let countryCode = phoneNumberKit.countryCode(for: currentRegion)?.description,
           self.stringValue == internationalPrefix(for: countryCode) {
            textField.stringValue = ""
            sendAction(Selector("textDidChangeNotification"), to: target)
            self.updateFlag()
            self.updatePlaceholder()
        }
    }
}

fileprivate extension String {
  var isBlank: Bool {
    return allSatisfy({ $0.isWhitespace })
  }
}

fileprivate struct Country {
    public var code: String
    public var flag: String
    public var name: String
    public var prefix: String

    public init?(for countryCode: String, with phoneNumberKit: PhoneNumberKit) {
        let flagBase = UnicodeScalar("🇦").value - UnicodeScalar("A").value
        
        let name: String?
        if #available(macOS 10.12, *) {
            name = (Locale.current as NSLocale).localizedString(forCountryCode: countryCode)
        } else {
            name = countryCode
        }
        
        guard
            let name = name,
            let prefix = phoneNumberKit.countryCode(for: countryCode)?.description
        else {
            return nil
        }

        self.code = countryCode
        self.name = name
        self.prefix = "+" + prefix
        self.flag = ""
        countryCode.uppercased().unicodeScalars.forEach {
            if let scaler = UnicodeScalar(flagBase + $0.value) {
                flag.append(String(describing: scaler))
            }
        }
        if flag.count != 1 { // Failed to initialize a flag ... use an empty string
            return nil
        }
    }
}

open class PhoneNumberTextFieldCell: NSTextFieldCell {
    open var withFlag = false {
        didSet { controlView?.needsLayout = true }
    }
    
    func paddedRect(forBounds rect: NSRect) -> NSRect {
        guard withFlag else { return rect }
        let offset = (controlView as? PhoneNumberTextField)?.flagButton.frame.width ?? 0 + 8
        var rect = rect
        rect.origin.x += offset
        rect.size.width -= offset
        return rect
    }
    
    open override func drawingRect(forBounds rect: NSRect) -> NSRect {
        super.drawingRect(forBounds: paddedRect(forBounds: rect))
    }
    
    open override func edit(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, event: NSEvent?) {
        super.edit(withFrame: paddedRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, event: event)
    }
    
    open override func select(withFrame rect: NSRect, in controlView: NSView, editor textObj: NSText, delegate: Any?, start selStart: Int, length selLength: Int) {
        super.select(withFrame: paddedRect(forBounds: rect), in: controlView, editor: textObj, delegate: delegate, start: selStart, length: selLength)
    }
    
    open override func hitTest(for event: NSEvent, in cellFrame: NSRect, of controlView: NSView) -> NSCell.HitResult {
        super.hitTest(for: event, in: paddedRect(forBounds: cellFrame), of: controlView)
    }
    
    open override class var prefersTrackingUntilMouseUp: Bool {
        true
    }
    
    open override func trackMouse(with event: NSEvent, in cellFrame: NSRect, of controlView: NSView, untilMouseUp flag: Bool) -> Bool {
        super.trackMouse(with: event, in: paddedRect(forBounds: cellFrame), of: controlView, untilMouseUp: flag)
    }
}

fileprivate extension NSImage {
    static func fromEmoji(_ emoji: String, font: NSFont?) -> NSImage {
        let font = (font ?? .systemFont(ofSize: NSFont.systemFontSize))
        let imageSize = (emoji as NSString).size(withAttributes: [.font: font])
        return NSImage(size: imageSize, flipped: false) { rect in
            (emoji as NSString).draw(in: rect, withAttributes: [.font: font])
            return true
        }
    }
}

#endif

