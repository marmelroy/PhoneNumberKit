//
//  CountryCodePickerOptions.swift
//  PhoneNumberKit
//
//  Created by Joao Vitor Molinari on 19/09/23.
//  Copyright © 2021 Roy Marmelstein. All rights reserved.
//

#if os(iOS)
import UIKit

/// Configuration options for customizing the appearance of the country code picker.
public struct CountryCodePickerOptions: Sendable {
    
    /// Creates a new `CountryCodePickerOptions` instance with all properties set to `nil`.
    public init() { }

    /// Creates a new `CountryCodePickerOptions` instance with the specified appearance options.
    ///
    /// - Parameters:
    ///   - backgroundColor: The background color of the view.
    ///   - separatorColor: The color of the separator line between cells.
    ///   - textLabelColor: The color of the main text label (country code).
    ///   - textLabelFont: The font of the main text label (country code).
    ///   - detailTextLabelColor: The color of the detail text label (country name).
    ///   - detailTextLabelFont: The font of the detail text label (country name).
    ///   - tintColor: The tint color applied to interactive elements in the view.
    ///   - cellBackgroundColor: The background color of each table cell.
    ///   - cellBackgroundColorSelection: The background color of a selected table cell.
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
    

    /// The background color of the entire picker view.
    public var backgroundColor: UIColor?
    /// The color of the separator lines between cells.
    public var separatorColor: UIColor?
    /// The color of the main text label showing the country code.
    public var textLabelColor: UIColor?
    /// The font used for the main text label (country code).
    public var textLabelFont: UIFont?
    /// The color of the detail text label showing the country name.
    public var detailTextLabelColor: UIColor?
    /// The font used for the detail text label (country name).
    public var detailTextLabelFont: UIFont?
    /// The tint color used throughout the view (e.g., for selection indicators).
    public var tintColor: UIColor?
    /// The background color of individual table cells.
    public var cellBackgroundColor: UIColor?
    /// The background color of a selected table cell.
    public var cellBackgroundColorSelection: UIColor?
}
#endif
