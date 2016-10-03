# PhoneNumberKit 0.x -> 1.0 Migration Guide

The 1.0 release of PhoneNumberKit took advantage of "The Grand Renaming" of Swift APIs in Swift 3.0 to resolve some issues with the original design that led to confusion, inefficient memory management and possible concurrency issues.

Unfortunately, this means a few breaking changes.

## The PhoneNumberKit object

To create a simple API, the main object in PhoneNumberKit 0.x was the PhoneNumber object. Number strings were parsed using its initializer, formatting was done via functions declared in an extension.

The main object of PhoneNumberKit 1.0 is a PhoneNumberKit object. This allows for more granular management of PhoneNumberKit's lifecycle and for immutable PhoneNumber value types.

### Before (0.x)
```swift
do {
  let phoneNumber = try PhoneNumber(rawNumber: "+44 20 7031 3000", region: "GB")
  let formattedNumber: String =  phoneNumber.toInternational()
}
catch {
    print("Generic parser error")
}
```

### After (1.0)
```swift
let phoneNumberKit = PhoneNumberKit()
do {
    let phoneNumber = try phoneNumberKit.parse("+44 20 7031 3000", withRegion: "GB")
    let formattedNumber: String = phoneNumberKit.format(phoneNumber, toType: .international)
}
catch {
    print("Generic parser error")
}
```
Allocating a PhoneNumberKit object is relatively expensive so reuse is encouraged.  

## Types and validation

In PhoneNumberKit 0.x, a PhoneNumber object's ```type``` property was a computed variable. The thinking was that type validation was expensive to perform and not always necessary.

This choice led to a certain amount of confusion - it meant that PhoneNumber objects were 'lightly' validated. To get a 'strong' validation, an isValid function that checked whether or not the number was of a known type had to be used.

In PhoneNumberKit 1.0, type validation is part of the parsing process and all PhoneNumber objects are strongly validated. 
