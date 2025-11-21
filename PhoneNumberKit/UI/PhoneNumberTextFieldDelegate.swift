#if os(iOS)

import UIKit

@MainActor
public protocol PhoneNumberTextFieldDelegate: AnyObject {
    /// Notifies the delegate that the country code picker view controller is about to be presented.
    /// - Parameters:
    ///   - textField: The phone number text field.
    ///   - controller: The country code picker view controller that will be presented.
    func countryCodePickerViewControllerWillPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    /// Notifies the delegate that the country code picker view controller has been presented.
    /// - Parameters:
    ///   - textField: The phone number text field.
    ///   - controller: The country code picker view controller that has been presented.
    func countryCodePickerViewControllerDidPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    /// Notifies the delegate that the country code picker view controller is about to be dismissed.
    /// - Parameters:
    ///   - textField: The phone number text field.
    ///   - controller: The country code picker view controller that will be dismissed.
    func countryCodePickerViewControllerWillDismiss(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    /// Notifies the delegate that the country code picker view controller has been dismissed.
    /// - Parameter textField: The phone number text field.
    func countryCodePickerViewControllerDidDismiss(_ textField: PhoneNumberTextField)
}

public extension PhoneNumberTextFieldDelegate {
    func countryCodePickerViewControllerWillPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {}
    func countryCodePickerViewControllerDidPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {}
    func countryCodePickerViewControllerWillDismiss(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController) {}
    func countryCodePickerViewControllerDidDismiss(_ textField: PhoneNumberTextField) {}
}

#endif
