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
public struct CountryCodePickerOptions: Sendable, Equatable, Hashable {
    
    /// The background color of the entire picker view.
    public var backgroundColor: UIColor?
    /// The color of the separator lines between cells.
    public var separatorColor: UIColor?
    /// The tint color used throughout the view (e.g., for selection indicators).
    public var tintColor: UIColor?
    /// Options for customizing the appearance of individual table cells.
    public var cellOptions: CountryCodePickerCellOptions
    /// Options for customizing the appearance of the header view.
    public var headerOptions: CountryCodePickerHeaderOptions
    
    /// Creates a new `CountryCodePickerOptions` instance with all properties set to `nil`.
    public init() {
        self.cellOptions = .default
        self.headerOptions = .default
    }

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
                tintColor: UIColor? = nil,
                cellOptions: CountryCodePickerCellOptions = .default,
                headerOptions: CountryCodePickerHeaderOptions = .default) {
        self.backgroundColor = backgroundColor
        self.separatorColor = separatorColor
        self.tintColor = tintColor
        self.cellOptions = cellOptions
        self.headerOptions = headerOptions
    }
    
    /// The default `CountryCodePickerOptions` instance.
    public static let `default` = CountryCodePickerOptions()
}

public extension CountryCodePickerOptions {
    
    struct CountryCodePickerCellOptions: Sendable, Equatable, Hashable {
        /// The color of the main text label showing the country code.
        public var textLabelColor: UIColor?
        /// The font used for the main text label (country code).
        public var textLabelFont: UIFont?
        /// The color of the detail text label showing the country name.
        public var detailTextLabelColor: UIColor?
        /// The font used for the detail text label (country name).
        public var detailTextLabelFont: UIFont?
        /// The background color of individual table cells.
        public var backgroundColor: UIColor?
        /// The background color of a selected table cell.
        public var backgroundColorSelection: UIColor?
        /// The reusable cell type for the table cells.
        public var cellType: ReusableCellType = .defaultCell
        /// The height of each table cell.
        public var height: CGFloat
        
        /// Creates a new `CountryCodePickerCellOptions` instance with all properties set to `nil`.
        public init() {
            self.height = CountryCodePickerViewController.CountryCodePickerTableViewCell.defaultHeight
            self.cellType = .defaultCell
        }
        
        /// Creates a new `CountryCodePickerCellOptions` instance with the specified appearance options.
        ///
        /// - Parameters:
        ///  - textLabelColor: The color of the main text label (country code).
        ///  - textLabelFont: The font of the main text label (country code).
        ///  - detailTextLabelColor: The color of the detail text label (country name
        ///  - detailTextLabelFont: The font of the detail text label (country name).
        ///  - backgroundColor: The background color of each table cell.
        ///  - backgroundColorSelection: The background color of a selected table cell.
        public init(textLabelColor: UIColor? = nil,
                    textLabelFont: UIFont? = nil,
                    detailTextLabelColor: UIColor? = nil,
                    detailTextLabelFont: UIFont? = nil,
                    backgroundColor: UIColor? = nil,
                    backgroundColorSelection: UIColor? = nil,
                    cellType: ReusableCellType = .defaultCell,
                    height: CGFloat = CountryCodePickerViewController.CountryCodePickerTableViewCell.defaultHeight) {
            self.textLabelColor = textLabelColor
            self.textLabelFont = textLabelFont
            self.detailTextLabelColor = detailTextLabelColor
            self.detailTextLabelFont = detailTextLabelFont
            self.backgroundColor = backgroundColor
            self.backgroundColorSelection = backgroundColorSelection
            self.cellType = cellType
            self.height = height
        }
        
        public static let `default` = CountryCodePickerCellOptions()
    }
    
    struct CountryCodePickerHeaderOptions: Sendable, Equatable, Hashable {
        /// The color of the header text label.
        public var textLabelColor: UIColor?
        /// The font used for the header text label.
        public var textLabelFont: UIFont?
        /// The background color of the header view.
        public var backgroundColor: UIColor?
        /// The reusable cell type for the header view.
        public var cellType: CountryCodePickerCellOptions.ReusableCellType
        /// The height of the header view.
        public var height: CGFloat
        
        /// Creates a new `CountryCodePickerHeaderOptions` instance with all properties set to `nil`.
        public init() {
            self.textLabelColor = CountryCodePickerViewController.CountryCodePickerSectionHeader.Constants.titleColor
            self.textLabelFont = CountryCodePickerViewController.CountryCodePickerSectionHeader.Constants.titleFont
            self.height = CountryCodePickerViewController.CountryCodePickerSectionHeader.defaultHeight
            self.cellType = .defaultHeader
        }
        
        /// Creates a new `CountryCodePickerHeaderOptions` instance with the specified appearance options.
        ///
        /// - Parameters:
        ///  - textLabelColor: The color of the header text label.
        ///  - textLabelFont: The font used for the header text label.
        ///  - backgroundColor: The background color of the header view.
        public init(textLabelColor: UIColor? = CountryCodePickerViewController.CountryCodePickerSectionHeader.Constants.titleColor,
                    textLabelFont: UIFont? = CountryCodePickerViewController.CountryCodePickerSectionHeader.Constants.titleFont,
                    backgroundColor: UIColor? = nil,
                    cellType: CountryCodePickerCellOptions.ReusableCellType = .defaultHeader,
                    height: CGFloat = CountryCodePickerViewController.CountryCodePickerSectionHeader.defaultHeight) {
            self.textLabelColor = textLabelColor
            self.textLabelFont = textLabelFont
            self.backgroundColor = backgroundColor
            self.cellType = cellType
            self.height = height
        }
        
        /// The default `CountryCodePickerHeaderOptions` instance.
        public static let `default` = CountryCodePickerHeaderOptions()
    }
    
}

public extension CountryCodePickerOptions.CountryCodePickerCellOptions {
    /// Defines the type of reusable cell used in the country code picker.
    enum ReusableCellType: Sendable, Equatable, Hashable {
        case cellNib(_ nib: UINib?, identifier: String)
        case cellClass(_ cellClass: AnyClass?, identifier: String)
        
        var identifier: String {
            switch self {
            case .cellNib(_, let identifier):
                return identifier
            case .cellClass(_, let identifier):
                return identifier
            }
        }
        
        // Equatable conformance
        public static func == (lhs: CountryCodePickerOptions.CountryCodePickerCellOptions.ReusableCellType, rhs: CountryCodePickerOptions.CountryCodePickerCellOptions.ReusableCellType) -> Bool {
            switch (lhs, rhs) {
            case let (.cellNib(_, id1), .cellNib(_, id2)):
                return id1 == id2
            case let (.cellClass(_, id1), .cellClass(_, id2)):
                return id1 == id2
            default:
                return false
            }
        }
        
        // Hashable conformance
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .cellNib(_, let identifier):
                hasher.combine("cellNib")
                hasher.combine(identifier)
            case .cellClass(_, let identifier):
                hasher.combine("cellClass")
                hasher.combine(identifier)
            }
        }
        
        public static let `defaultCell` = ReusableCellType.cellClass(CountryCodePickerViewController.CountryCodePickerTableViewCell.self, identifier: CountryCodePickerViewController.CountryCodePickerTableViewCell.reuseIdentifier)
        public static let `defaultHeader` = ReusableCellType.cellClass(CountryCodePickerViewController.CountryCodePickerSectionHeader.self, identifier: CountryCodePickerViewController.CountryCodePickerSectionHeader.reuseIdentifier)
    }
}

#endif
