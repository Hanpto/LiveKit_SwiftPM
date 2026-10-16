// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TUILiveKit",
    defaultLocalization: "en",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "TUILiveKit", targets: ["TUILiveKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Tencent-RTC/AtomicXCore_SwiftPM.git", from: "5.2.0"),
        .package(url: "https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git", from: "9.0.7652"),
        .package(url: "https://github.com/Tencent-RTC/Professional_SwiftPM.git", from: "13.3.20845"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/Tencent-RTC/GfitAR_SwiftPM.git", from: "3.4.244")
    ],
    targets: [
        .target(
            name: "TUILiveKit",
            dependencies: [
                .product(name: "AtomicXCore", package: "AtomicXCore_SwiftPM"),
                .product(name: "Chat_SDK_SwiftPM", package: "Chat_SDK_SwiftPM"),
                .product(name: "Professional_SwiftPM", package: "Professional_SwiftPM"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "GfitAR_SwiftPM", package: "GfitAR_SwiftPM")
            ],
            path: "Sources",
            exclude: ["TUILiveKit.podspec", "README.md"],
            resources: [.process("Resources/Assets.xcassets"), .process("Resources/en.lproj"), .process("Resources/zh-Hans.lproj"), .process("Resources/livekit_coguest_wave.gif")]
        )
    ],
    swiftLanguageModes: [.v5]
)
