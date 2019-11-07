![PhoneNumberKit](https://cloud.githubusercontent.com/assets/889949/20864386/a1307950-b9ef-11e6-8a58-e9c5103738e7.png)
[![Platform](https://img.shields.io/cocoapods/p/PhoneNumberKit.svg?maxAge=2592000)](http://cocoapods.org/?q=PhoneNumberKit)
[![Build Status](https://travis-ci.org/marmelroy/PhoneNumberKit.svg?branch=master)](https://travis-ci.org/marmelroy/PhoneNumberKit) [![Version](http://img.shields.io/cocoapods/v/PhoneNumberKit.svg)](http://cocoapods.org/?q=PhoneNumberKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PhoneNumberKit
Swift 5.0 framework for parsing, formatting and validating international phone numbers.
Inspired by Google's libphonenumber.

[Migrating from PhoneNumberKit 0.x? See the migration guide.](https://github.com/marmelroy/PhoneNumberKit/blob/master/Documentation/OXMIGRATIONGUIDE.md)  
## Features

| |Features |
--------------------------|------------------------------------------------------------
:phone: | Validate, normalize and extract the elements of any phone number string.
:100: | Simple Swift syntax and a lightweight readable codebase.
:checkered_flag: | Fast. 1000 parses -> ~0.4 seconds.
:books: | Best-in-class metadata from Google's libPhoneNumber project.
:trophy: | Fully tested to match the accuracy of Google's JavaScript implementation of libPhoneNumber.
:iphone: | Built for iOS. Automatically grabs the default region code from the phone.
📝 | Editable (!) AsYouType formatter for UITextField.
:us: | Convert country codes to country names and vice versa

## Usage

Import PhoneNumberKit at the top of the Swift file that will interact with a phone number.

```swift
import PhoneNumberKit
```

All of your interactions with PhoneNumberKit happen through a PhoneNumberKit object. The first step you should take is to allocate one.

A PhoneNumberKit instance is relatively expensive to allocate (it parses the metadata and keeps it in memory for the object's lifecycle), you should try and make sure PhoneNumberKit is allocated once and deallocated when no longer needed.

```swift
let phoneNumberKit = PhoneNumberKit()
```

To parse a string, use the parse function. The region code is automatically computed but can be overridden if needed. PhoneNumberKit automatically does a hard type validation to ensure that the object created is valid, this can be quite costly performance-wise and can be turned off if needed.
```swift
do {
    let phoneNumber = try phoneNumberKit.parse("+33 6 89 017383")
    let phoneNumberCustomDefaultRegion = try phoneNumberKit.parse("+44 20 7031 3000", withRegion: "GB", ignoreType: true)
}
catch {
    print("Generic parser error")
}
```

If you need to parse and validate a large amount of numbers at once, PhoneNumberKit has a special, lightning fast array parsing function. The default region code is automatically computed but can be overridden if needed. Here you can also ignore hard type validation if it is not necessary. Invalid numbers are ignored in the resulting array.
```swift
let rawNumberArray = ["0291 12345678", "+49 291 12345678", "04134 1234", "09123 12345"]
let phoneNumbers = phoneNumberKit.parse(rawNumberArray)
let phoneNumbersCustomDefaultRegion = phoneNumberKit.parse(rawNumberArray, withRegion: "DE",  ignoreType: true)
```

PhoneNumber objects are immutable Swift structs with the following properties:
```swift
phoneNumber.numberString
phoneNumber.countryCode
phoneNumber.nationalNumber
phoneNumber.numberExtension
phoneNumber.type // e.g Mobile or Fixed
```

Formatting a PhoneNumber object into a string is also very easy
```swift
phoneNumberKit.format(phoneNumber, toType: .e164) // +61236618300
phoneNumberKit.format(phoneNumber, toType: .international) // +61 2 3661 8300
phoneNumberKit.format(phoneNumber, toType: .national) // (02) 3661 8300
```

## PhoneNumberTextField

![AsYouTypeFormatter](https://user-images.githubusercontent.com/7651280/67554038-e6512500-f751-11e9-93c9-9111e899a2ef.gif)

To use the AsYouTypeFormatter, just replace your UITextField with a PhoneNumberTextField (if you are using Interface Builder make sure the module field is set to PhoneNumberKit).

You can customize your TextField UI in the following ways
- `withFlag` will display the country code for the `currentRegion`. The `flagButton` is displayed in the `leftView` of the text field with it's size set based off your text size.
- `withExamplePlaceholder` uses `attributedPlaceholder` to show an example number for the `currentRegion`. In addition when `withPrefix` is set, the country code's prefix will automatically be inserted and removed when editing changes.

PhoneNumberTextField automatically formats phone numbers and gives the user full editing capabilities. If you want to customize you can use the PartialFormatter directly. The default region code is automatically computed but can be overridden if needed (see the example given below).
```swift
class MyGBTextField: PhoneNumberTextField {
    override var defaultRegion: String {
        get {
            return "GB"
        }
        set {} // exists for backward compatibility
    }
}
```

```swift
let textField = PhoneNumberTextField()

PartialFormatter().formatPartial("+336895555") // +33 6 89 55 55
```

You can also query countries for a dialing code or the dialing code for a given country
```swift
phoneNumberKit.countries(withCode: 33)
phoneNumberKit.countryCode(for: "FR")
```

## Need more customization?

You can access the metadata powering PhoneNumberKit yourself, this enables you to program any behaviours as they may be implemented in PhoneNumberKit itself. It does mean you are exposed to the less polished interface of the underlying file format. If you program something you find useful please push it upstream!
```swift
phoneNumberKit.metadata(for: "AU")?.mobile?.exampleNumber // 412345678
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate PhoneNumberKit into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/PhoneNumberKit"
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=PhoneNumberKit)
```ruby
source 'https://github.com/CocoaPods/Specs.git'
pod 'PhoneNumberKit', '~> 3.0'
```
