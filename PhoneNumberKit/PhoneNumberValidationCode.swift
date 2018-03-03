//
//  PhoneNumberValidationCode.swift
//  PhoneNumberKit
//
//  Created by Hugo Fouquet on 03/03/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import UIKit

class PhoneNumberValidationCode: UIView, UIKeyInput {
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    var keyboardType: UIKeyboardType
    var hasText: Bool = false
    
    var length: UInt
    private var labels: [UILabel]
    
    private var text: String {
        didSet {
            self.updateLabelText()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.keyboardType = .numberPad
        self.length = 3
        self.labels = []
        self.text = ""
        super.init(coder: aDecoder)
    }
    
    func insertText(_ text: String) {
        self.text += text
    }
    
    func deleteBackward() {
        self.text = String(self.text.dropLast())
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.insertLabels()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print("V2 - Moved :", self.canBecomeFirstResponder)
        self.becomeFirstResponder()
    }
    
    func updateLabelText() {
        for (idx, label) in self.labels.enumerated() {
            let char = self.text[idx] as String?
            label.text = char ?? "•"
        }
    }
    
    func insertLabels() {
        for i in 0...self.length {
            self.labels.append(self.insertLabel(text: "\(i)"))
        }
        self.addWidthConstraints()
    }
    
    func addWidthConstraints() {
        var views: [String:UIView] = [:]
        var hVisual = "H:|-10-"
        for (index, lbl) in self.labels.enumerated() {
            let key = "lbl_\(index)"
            views[key] = lbl
            hVisual += "[\(key)(==lbl_0)]-10-"
        }
        hVisual += "|"
        print(hVisual)
        let widthConstraints = NSLayoutConstraint.constraints(withVisualFormat: hVisual, options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        self.addConstraints(widthConstraints)
    }
    
    func insertLabel(text: String, isLast: Bool = false) -> UILabel {
        let lbl = UILabel()
        lbl.frame = CGRect(x: 0, y: 0, width: 20, height: 40)
        lbl.text = text
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(lbl)
        
        let views = ["lbl": lbl]
        let heightConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:[lbl(30)]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views)
        let verticalConstraint = NSLayoutConstraint(item: lbl, attribute: NSLayoutAttribute.centerY, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.centerY, multiplier: 1, constant: 0)
        self.addConstraints(heightConstraints)
        self.addConstraints([verticalConstraint])
        return lbl
    }
    
}

extension String {
    
    subscript (i: Int) -> Character? {
        if self.count > i {
            return self[index(startIndex, offsetBy: i)]
        }
        return nil
    }
    
    subscript (i: Int) -> String? {
        guard let char = (self[i] as Character?) else { return nil }
        return String(char)
    }
    
    subscript (r: Range<Int>) -> String {
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[Range(start ..< end)])
    }
}

