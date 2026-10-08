// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "TUILiveKit",
    platforms: [.iOS(.v14)],
    products: [
        .library(name: "TUILiveKit", targets: ["TUILiveKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/Hanpto/AtomicX_SwiftPM.git", from: "4.2.2"),
        .package(url: "https://github.com/Tencent-RTC/AtomicXCore_SwiftPM.git", from: "4.3.0"),
        .package(url: "https://github.com/Tencent-RTC/RTCRoomEngine_SwiftPM.git", from: "4.3.0"),
        .package(url: "https://github.com/Hanpto/TUICore_SwiftPM.git", from: "9.0.7652"),
        .package(url: "https://github.com/Tencent-RTC/Chat_SDK_SwiftPM.git", from: "9.0.7652"),
        .package(url: "https://github.com/SnapKit/SnapKit.git", from: "5.7.1"),
        .package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.12.0"),
        .package(url: "https://github.com/CoderMJLee/MJRefresh.git", from: "3.7.9")
    ],
    targets: [
        .target(
            name: "TUILiveKit",
            dependencies: [
                .product(name: "AtomicX", package: "AtomicX_SwiftPM"),
                .product(name: "AtomicXCore", package: "AtomicXCore_SwiftPM"),
                .product(name: "RoomEngine", package: "RTCRoomEngine_SwiftPM"),
                .product(name: "TUICore_SwiftPM", package: "TUICore_SwiftPM"),
                .product(name: "Chat_SDK_SwiftPM", package: "Chat_SDK_SwiftPM"),
                .product(name: "SnapKit", package: "SnapKit"),
                .product(name: "Kingfisher", package: "Kingfisher"),
                .product(name: "MJRefresh", package: "MJRefresh")
            ],
            path: "Sources",
            resources: [.process("Resources")]
        )
    ],
    swiftLanguageModes: [.v5]
)
