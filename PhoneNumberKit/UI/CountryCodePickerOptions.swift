//
//  CountryCodePickerOptions.swift
//  ForkDoBruno
//
//  Created by Joao Vitor Molinari on 19/09/23.
//

import UIKit

/**
 CountryCodePickerOptions object
 - Parameter backgroundColor: UIColor used for background
 - Parameter separatorColor: UIColor used for the separator line between cells
 - Parameter textLabelColor: UIColor for the TextLabel (Country code)
 - Parameter textLabelFont: UIFont for the TextLabel (Country code)
 - Parameter detailTextLabelColor: UIColor for the DetailTextLabel (Country name)
 - Parameter detailTextLabelFont: UIFont for the DetailTextLabel (Country name)
 - Parameter tintColor: Default TintColor used on the view
 - Parameter cellBackgroundColor: UIColor for the cell background
 - Parameter cellBackgroundColorSelection: UIColor for the cell selectedBackgroundView
 */
public struct CountryCodePickerOptions {

    public var backgroundColor: UIColor = UIColor.systemBackground
    public var separatorColor: UIColor = UIColor.systemBackground
    public var textLabelColor: UIColor = UIColor.label
    public var textLabelFont: UIFont = .preferredFont(forTextStyle: .callout)
    public var detailTextLabelColor: UIColor = UIColor.secondaryLabel
    public var detailTextLabelFont: UIFont = .preferredFont(forTextStyle: .body)
    public var tintColor: UIColor = UIView().tintColor!
    public var cellBackgroundColor: UIColor = UIColor.systemGroupedBackground
    public var cellBackgroundColorSelection: UIColor = UIColor.systemGray
}
