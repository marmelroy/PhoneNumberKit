// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PhoneNumberKit",
    defaultLocalization: "en",
    products: [
        .library(name: "PhoneNumberKit", targets: ["PhoneNumberKit"])
    ],
    targets: [
        .target(name: "PhoneNumberKit", path: "PhoneNumberKit", exclude: [], resources: [.process("Resources/PhoneNumberMetadata.json")]),
        .testTarget(name: "PhoneNumberKitTests", dependencies: ["PhoneNumberKit"], path: "PhoneNumberKitTests")
    ]
)
