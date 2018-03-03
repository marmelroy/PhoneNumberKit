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
    func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> UILabel
    
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
    /// Default text for label who's input not yet enter
    public var defaultText: Character = "•"
    /// Validation code length.
    @IBInspectable public var length: UInt = 6
    /// Space between each labels
    @IBInspectable public var labelSpacing: CGFloat = 10.0
    /// Open keyboard automatically when view appear
    @IBInspectable public var autoResponder: Bool = true
    
    // MARK: Private properties
    
    /// Labels to display current input
    private var labels: [UILabel] = []
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
    
    private func createLabels() {
        for i in 0...(self.length - 1) {
            let label = self.insertLabel(atIndex: i)
            self.labels.append(label)
        }
        self.addWidthConstraints()
    }
    
    private func addWidthConstraints() {
        var views: [String:UIView] = [:]
        var hVisual = "H:|-"
        for (index, lbl) in self.labels.enumerated() {
            let key = "lbl_\(index)"
            views[key] = lbl
            if index != 0 {
                hVisual += "\(self.labelSpacing)-"
            }
            hVisual += "[\(key)(==lbl_0)]-"
        }
        hVisual += "|"
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: hVisual, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.addConstraints(widthConstraints)
    }
    
    private func insertLabel(atIndex index: UInt) -> UILabel {
        let label = self.dataSource.validationCode(self, labelAtIndex: index)
        label.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(label)
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[lbl]-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["lbl": label]))
        self.addConstraints([NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        return label
    }
    
    // MARK: Layout
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        
        if self.autoResponder {
            self.becomeFirstResponder()
        }
        self.createLabels()
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
        for (idx, label) in self.labels.enumerated() {
            let char = value[idx] ?? self.defaultText
            label.text = String(char)
        }
    }
    
}

// MARK: - Default implementation

extension PhoneNumberValidationCode: PhoneNumberValidationCodeDataSource {
    
    public func validationCode(_ validationCode: PhoneNumberValidationCode, labelAtIndex index: UInt) -> UILabel {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 40))
        label.textAlignment = .center
        return label
    }
    
}

extension String {
    
    subscript (i: Int) -> Character? {
        if self.count > i {
            return self[index(startIndex, offsetBy: i)]
        }
        return nil
    }
    
}

