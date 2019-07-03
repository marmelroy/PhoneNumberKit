// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "PhoneNumberKit",
    products: [
        .library(name: "PhoneNumberKit", targets: ["PhoneNumberKit"])
    ],
    targets: [
        .target(name: "PhoneNumberKit", path: "PhoneNumberKit", exclude: ["UI"]),
        .testTarget(name: "PhoneNumberKitTests", dependencies: ["PhoneNumberKit"], path: "PhoneNumberKitTests")
    ]
)
