// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "SCSwift",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SCSwift",
            targets: ["SCSwift"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(name: "PureLayout", url: "https://github.com/PureLayout/PureLayout.git", from: "3.1.9")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SCSwift",
            dependencies: [
                "PureLayout",
            ],
            path: "SCSwift"
        )
    ]
)
