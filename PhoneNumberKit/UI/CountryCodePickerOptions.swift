//
//  CountryCodePickerOptions.swift
//  PhoneNumberKit
//
//  Created by Joao Vitor Molinari on 19/09/23.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

#if os(iOS)
import UIKit

/// CountryCodePickerOptions object
/// - Parameter backgroundColor: UIColor used for background
/// - Parameter separatorColor: UIColor used for the separator line between cells
/// - Parameter textLabelColor: UIColor for the TextLabel (Country code)
/// - Parameter textLabelFont: UIFont for the TextLabel (Country code)
/// - Parameter detailTextLabelColor: UIColor for the DetailTextLabel (Country name)
/// - Parameter detailTextLabelFont: UIFont for the DetailTextLabel (Country name)
/// - Parameter tintColor: Default TintColor used on the view
/// - Parameter cellBackgroundColor: UIColor for the cell background
/// - Parameter cellBackgroundColorSelection: UIColor for the cell selectedBackgroundView
public struct CountryCodePickerOptions {
    public init() { }

    public init(backgroundColor: UIColor? = nil,
                separatorColor: UIColor? = nil,
                textLabelColor: UIColor? = nil,
                textLabelFont: UIFont? = nil,
                detailTextLabelColor: UIColor? = nil,
                detailTextLabelFont: UIFont? = nil,
                tintColor: UIColor? = nil,
                cellBackgroundColor: UIColor? = nil,
                cellBackgroundColorSelection: UIColor? = nil) {
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.textLabelColor = textLabelColor
        self.textLabelFont = textLabelFont
        self.detailTextLabelColor = detailTextLabelColor
        self.detailTextLabelFont = detailTextLabelFont
        self.tintColor = tintColor
        self.cellBackgroundColor = cellBackgroundColor
        self.cellBackgroundColorSelection = cellBackgroundColorSelection
    }

    public var backgroundColor: UIColor?
    public var separatorColor: UIColor?
    public var textLabelColor: UIColor?
    public var textLabelFont: UIFont?
    public var detailTextLabelColor: UIColor?
    public var detailTextLabelFont: UIFont?
    public var tintColor: UIColor?
    public var cellBackgroundColor: UIColor?
    public var cellBackgroundColorSelection: UIColor?
}
#endif
