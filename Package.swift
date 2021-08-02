// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PhoneNumberKit",
    platforms: [
        .iOS(.v9), .macOS(.v10_10), .tvOS(.v9), .watchOS(.v2)
    ],
    products: [
        .library(name: "PhoneNumberKit", targets: ["UICondition"]),
        .library(name: "PhoneNumberKit-Static", type: .static, targets: ["UICondition"]),
        .library(name: "PhoneNumberKit-Dynamic", type: .dynamic, targets: ["UICondition"])
    ],
    targets: [
        .target(name:"UICondition",
                dependencies: [
                    .target(name: "PhoneNumberKit"),
                    .target(name: "UI", condition: .when(platforms: [.iOS]))
                ]
        ),

        .target(name: "UI", path: "PhoneNumberKit/UI"),
        .target(name: "PhoneNumberKit",
                path: "PhoneNumberKit",
                exclude: [ "UI",
                          "Resources/Original",
                          "Resources/README.md",
                          "Resources/update.sh",
                          "Info.plist", 
                          "Bundle+Resources.swift"],
                resources: [
                    .process("Resources/PhoneNumberMetadata.json")
                ]),

        .testTarget(name: "PhoneNumberKitTests",
                    dependencies: ["PhoneNumberKit"],
                    path: "PhoneNumberKitTests",
                    exclude: ["Info.plist"])
    ]
)
