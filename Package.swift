// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "PhoneNumberKit",
    products: [
        .library(name: "PhoneNumberKit", targets: ["PhoneNumberKit"])
    ],
    targets: [
        .target(name: "PhoneNumberKit", path: "PhoneNumberKit", exclude: []),
        .testTarget(name: "PhoneNumberKitTests", dependencies: ["PhoneNumberKit"], path: "PhoneNumberKitTests")
    ]
)
