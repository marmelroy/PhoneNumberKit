![PhoneNumberKit](https://cloud.githubusercontent.com/assets/889949/10723260/5225c86c-7bb9-11e5-883c-9b42aa50ea27.png)

[![Build Status](https://travis-ci.org/marmelroy/PhoneNumberKit.svg?branch=master)](https://travis-ci.org/marmelroy/PhoneNumberKit) [![Version](http://img.shields.io/cocoapods/v/PhoneNumberKit.svg)](http://cocoapods.org/?q=PhoneNumberKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PhoneNumberKit
Swift framework for parsing, formatting and validating international phone numbers.
Inspired by Google's libphonenumber.

### :construction: PhoneNumberKit is currently alpha software :construction:

 | Objective
--- | --- 
:white_check_mark: | Match Google's libphonenumber accuracy by passing tests against all example numbers
:white_check_mark: | Faster performance. 1000 parses -> ~0.3 seconds.
:x: | Better formatter and an AsYouType formatter for UITextField

## Features

- Quickly validate, normalize and extract the elements of any phone number string.    
- Special function to quickly parse a large array of raw phone numbers. 
- Automatically grab the default region code from the phone's SIM (or if unavailable, the device's region). You can override this if you need to.
- Convert country codes to country names and vice versa.
- Simple Swift 2.0 syntax and readable codebase.
- PhoneNumberKit uses the best-in-class metadata and basic approach from Google's libphonenumber project. By not being a direct port, PhoneNumberKit can focus on a smaller feature-set that's cleaner, faster and more readable.

## Usage

Import PhoneNumberKit at the top of the Swift file that will interact with a phone number.

```swift
import PhoneNumberKit
```

To parse and validate a string, initialize a PhoneNumber object and supply the string as the rawNumber. The region code is automatically computed but can be overridden if needed. In case of an error, it will throw and you can catch and respond to in your app's UI
```swift
do {
    let phoneNumber = try PhoneNumber(rawNumber:"+33 6 89 017383")
    let phoneNumberForCustomDefaultRegion = try PhoneNumber(rawNumber: "+44 20 7031 3000", region: "GB")
}
catch {
    print("Generic parser error")
}
```

If you need to parse and validate a large amount of numbers at once, there is a special function for that and it's lightning fast. The default region code is automatically computed but can be overridden if needed.
```swift
let rawNumberArray = ["0291 12345678", "+49 291 12345678", "04134 1234", "09123 12345"]
let phoneNumbers = PhoneNumberKit().parseMultiple(rawNumberArray)
let phoneNumbersForCustomDefaultRegion = PhoneNumberKit().parseMultiple(rawNumberArray, region: "DE")
```

You can also query countries for a dialing code or the dailing code for a given country
```swift
let phoneNumberKit = PhoneNumberKit()
phoneNumberKit.countriesForCode(33)
phoneNumberKit.codeForCountry("FR")
```

Formatting a parsed phone number to a string is also very easy
```swift
phoneNumber.toE164()
```

You can access the following properties of a PhoneNumber object
```swift
phoneNumber.countryCode
phoneNumber.nationalNumber
phoneNumber.numberExtension
phoneNumber.rawNumber
phoneNumber.type // e.g Mobile or Fixed, computed on request
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
pod 'PhoneNumberKit', '~> 0.1'
```
