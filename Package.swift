// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Pigeon",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Pigeon",
            targets: ["Pigeon"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/p-x9/SCFNotification.git", .upToNextMajor(from: "0.0.6")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "Pigeon",
            dependencies: [
                .product(name: "SCFNotification", package: "SCFNotification"),
            ],
            path: "Sources",
            resources: [.copy("Resources/PrivacyInfo.xcprivacy")]),
    ])
