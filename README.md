![PhoneNumberKit](https://cloud.githubusercontent.com/assets/889949/10723260/5225c86c-7bb9-11e5-883c-9b42aa50ea27.png)

[![Build Status](https://travis-ci.org/marmelroy/PhoneNumberKit.svg?branch=master)](https://travis-ci.org/marmelroy/PhoneNumberKit) [![Version](http://img.shields.io/cocoapods/v/PhoneNumberKit.svg)](http://cocoapods.org/?q=PhoneNumberKit)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# PhoneNumberKit
Swift framework for parsing, formatting and validating international phone numbers.
Inspired by Google's libphonenumber.

## Features

- Quickly validate, normalize and extract the elements of any phone number string.    
- Automatically grab the default region code from the phone's SIM (or if unavailable, the device's region).
- Convert country codes to country names and vice versa.
- All whilst using simple Swift 2.0 syntax
- PhoneNumberKit uses the best-in-class metadata and general approach from Google's libphonenumber project. By not being a direct port, PhoneNumberKit can focus on a smaller feature-set that's cleaner and more readable.

## Usage

Import PhoneNumberKit at the top of the Swift file that will interact with a phone number.

```
import PhoneNumberKit
```

To parse and validate a string, initialize a PhoneNumber object and supply the string as the rawNumber. In case of an error, it will throw and you can catch and respond to in your app's UI
```
do {
    let phoneNumber = try PhoneNumber(rawNumber:"+33 6 89 017383")
}
catch {
    print("Generic parser error")
}
```

You can also query countries for a dialing code or the dailing code for a given country
```
let phoneNumberKit = PhoneNumberKit.sharedInstance
phoneNumberKit.countriesForCode(33)
phoneNumberKit.codeForCountry("FR")
```

Formatting a parsed phone number to a string is also very easy
```
phoneNumber.toE164()
```

You can access the following properties of a PhoneNumber object
```
phoneNumber.countryCode
phoneNumber.nationalNumber
phoneNumber.numberExtension
phoneNumber.rawNumber
phoneNumber.type // e.g Mobile or Fixed
```

### Setting up with Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that automates the process of adding frameworks to your Cocoa application.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate Localize-Swift into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "marmelroy/PhoneNumberKit"
```

### Setting up with [CocoaPods](http://cocoapods.org/?q=PhoneNumberKit)
```
source 'https://github.com/CocoaPods/Specs.git'
pod 'PhoneNumberKit', '~> 0.1'
```
