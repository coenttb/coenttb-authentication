// swift-tools-version:6.0

import Foundation
import PackageDescription

extension String {
    static let coenttbAuthentication: Self = "Coenttb Authentication"
}

extension Target.Dependency {
    static var coenttbAuthentication: Self { .target(name: .coenttbAuthentication) }
}

extension Target.Dependency {
    static var urlRouting: Self { .product(name: "URLRouting", package: "swift-url-routing") }
    static var coenttbWeb: Self { .product(name: "Coenttb Web", package: "coenttb-web") }
    static var dependencies: Self { .product(name: "Dependencies", package: "swift-dependencies") }
    static var swiftAuthentication: Self { .product(name: "Authentication", package: "swift-authentication") }
}

let package = Package(
    name: "coenttb-authentication",
    platforms: [
        .macOS(.v14),
        .iOS(.v17)
    ],
    products: [
        .library(name: .coenttbAuthentication, targets: [.coenttbAuthentication]),
    ],
    dependencies: [
        .package(url: "https://github.com/coenttb/coenttb-web", branch: "main"),
        .package(url: "https://github.com/coenttb/swift-authentication", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-url-routing", from: "0.6.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies", from: "1.6.0"),
    ],
    targets: [
        .target(
            name: .coenttbAuthentication,
            dependencies: [
                .urlRouting,
                .coenttbWeb,
                .swiftAuthentication,
                .dependencies,
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
