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

    public init() {}

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
