// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "PhoneNumberKit",
    products: [
        .library(name: "PhoneNumberKit", targets: ["PhoneNumberKit"])
    ],
    targets: [
        .target(name: "PhoneNumberKit",
                path: "PhoneNumberKit",
                exclude: ["Resources/Original",
                         "Resources/README.md",
                         "Resources/update.sh",
                         "Info.plist"],
                sources: nil,
                resources: [
                    .process("Resources/PhoneNumberMetadata.json")
                ]),
        .testTarget(name: "PhoneNumberKitTests",
                    dependencies: ["PhoneNumberKit"],
                    path: "PhoneNumberKitTests",
                    exclude: ["Info.plist"])
    ]
)
