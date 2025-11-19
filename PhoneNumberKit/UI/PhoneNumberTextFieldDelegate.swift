#if os(iOS)

import UIKit

@MainActor
public protocol PhoneNumberTextFieldDelegate: AnyObject {
    func countryCodePickerViewControllerWillPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    func countryCodePickerViewControllerDidPresent(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    func countryCodePickerViewControllerWillDismiss(_ textField: PhoneNumberTextField, controller: CountryCodePickerViewController)
    func countryCodePickerViewControllerDidDismiss(_ textField: PhoneNumberTextField)
}

#endif
