// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Miio",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Miio",
            targets: ["Miio"]),
    ],
    dependencies: [
//        .package(url: "https://github.com/makleso6/UDPBroadcastConnection.git", from: "5.0.4"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.13.0"),
        .package(url: "https://github.com/IBM-Swift/BlueCryptor.git", from: "1.0.21"),
        .package( url: "https://github.com/Flight-School/AnyCodable.git", from: "0.2.3")
        

        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Miio",
            dependencies: ["NIO", "Logging", "Cryptor", "AnyCodable"]),
        .testTarget(
            name: "MiioTests",
            dependencies: ["Miio"]),
    ]
)
