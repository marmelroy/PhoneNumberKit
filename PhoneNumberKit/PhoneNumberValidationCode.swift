//
//  PhoneNumberValidationCode.swift
//  PhoneNumberKit
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit

public protocol PhoneNumberValidationCodeDataSource {
    
    /// Called when labels are loaded.
    func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> PhoneNumberDigitView
    
}

@objc public protocol PhoneNumberValidationCodeDelegate {
    
    /// Called when input is full.
    @objc optional func validationCode(_ validationCode: PhoneNumberValidationCode, didFinish text: String)
    
    /// Called when an input is going to be added. False to reject.
    @objc optional func validationCode(_ validationCode: PhoneNumberValidationCode, willEnter text: String) -> Bool
    /// Called when an input has been added.
    @objc optional func validationCode(_ validationCode: PhoneNumberValidationCode, didEnter text: String)
    
}

/// Custom view to enter validation code
public class PhoneNumberValidationCode: UIView, UIKeyInput {
    
    // MARK: - Properties
    
    override public var canBecomeFirstResponder: Bool {
        return true
    }
    
    public var hasText: Bool = false
    public var keyboardType: UIKeyboardType = .numberPad
    /// Data Source to retreive labels
    public var dataSource: PhoneNumberValidationCodeDataSource!
    /// Delegate to interact with validation code
    public var delegate: PhoneNumberValidationCodeDelegate?
    /// Validation code length.
    @IBInspectable public var length: UInt = 6
    /// Space between each labels
    @IBInspectable public var labelSpacing: CGFloat = 10.0
    /// Open keyboard automatically when view appear
    @IBInspectable public var autoResponder: Bool = true
    
    // MARK: Private properties
    
    /// Labels to display current input
    private var digitViews: [PhoneNumberDigitView] = []
    /// Current input
    public private(set) var text: String = "" {
        didSet {
            self.updateText(with: self.text)
        }
    }
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.dataSource = self
    }
    
    private func createDigitViews() {
        for i in 0...(self.length - 1) {
            let digitView = self.insertDigitView(atIndex: i)
            self.digitViews.append(digitView)
        }
        self.addWidthConstraints()
    }
    
    private func addWidthConstraints() {
        var views: [String:UIView] = [:]
        var hVisual = "H:|-"
        for (index, digitView) in self.digitViews.enumerated() {
            let key = "v_\(index)"
            views[key] = (digitView as! UIView)
            if index != 0 {
                hVisual += "\(self.labelSpacing)-"
            }
            hVisual += "[\(key)(==v_0)]-"
        }
        hVisual += "|"
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: hVisual, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.addConstraints(widthConstraints)
    }
    
    private func insertDigitView(atIndex index: UInt) -> PhoneNumberDigitView {
        let view = self.dataSource.validationCode(self, labelAtIndex: index)
        (view as! UIView).translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(view as! UIView)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[v]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["v": view]))
        self.addConstraints([NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        return view
    }
    
    // MARK: Layout
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.autoResponder {
            self.becomeFirstResponder()
        }
        self.createDigitViews()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        self.updateText(with: self.text)
    }
    
    // MARK: Methods
    
    /// Reset text
    public func reset() {
        self.text = ""
    }
    
    /// Default text for label who's input not yet enter
    public func set(defaultText text: String) {
        for digitView in self.digitViews {
            digitView.defaultText = text
        }
    }
    
    // MARK: Key input
    
    public func insertText(_ text: String) {
        if self.text.count + text.count <= self.length {
            guard let valid = self.delegate?.validationCode?(self, willEnter: text), valid else {
                return
            }
            self.text += text
            self.delegate?.validationCode?(self, didEnter: text)
            if self.text.count == self.length {
                self.delegate?.validationCode?(self, didFinish: self.text)
            }
        }
    }
    
    public func deleteBackward() {
        self.text = String(self.text.dropLast())
    }
    
    fileprivate func updateText(with value: String) {
        for (idx, digitView) in self.digitViews.enumerated() {
            digitView.display(value[idx])
        }
    }
    
}

// MARK: - Default implementation

extension PhoneNumberValidationCode: PhoneNumberValidationCodeDataSource {
    
    public func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> PhoneNumberDigitView {
        let label = PhoneNumberDigitLabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        label.textAlignment = .center
        label.display("t")
        return label
    }
    
}

extension String {
    
    subscript (i: Int) -> String? {
        if self.count > i {
            return String(self[index(startIndex, offsetBy: i)])
        }
        return nil
    }
    
}

