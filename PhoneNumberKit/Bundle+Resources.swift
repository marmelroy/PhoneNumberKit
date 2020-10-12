
import Foundation

// This extension is required as part of supporting resources in SPM.
// It's included in all other buid products.
extension Bundle {
    static var module: Bundle = {
        Bundle(for: PhoneNumberKit.self)
    }()
}
