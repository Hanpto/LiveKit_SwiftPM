//
//  LiveBundle.swift
//  TUILiveKit
//
//  Created by CY zhao on 2026/1/12.
//

import Foundation
import AtomicX
import UIKit
import TUICore

public extension UIImage {
    static func liveBundleImage(_ named: String, rtlFlipped: Bool = false ) -> UIImage? {
        let image = UIImage(named: named, in: Bundle.liveBundle, with: nil) ?? UIImage(named: named)
        if rtlFlipped {
            return image?.rtlFlipped()
        } else {
            return image
        }
    }

    static var placeholderImage: UIImage {
        UIColor.lightPurpleColor.trans2Image()
    }

    static var avatarPlaceholderImage: UIImage? {
        UIImage(named: "live_seat_placeholder_avatar", in: Bundle.liveBundle, compatibleWith: nil)
    }

    func rtlFlipped() -> UIImage {
        return imageFlippedForRightToLeftLayoutDirection()
    }
}

public extension String {
    var liveLocalized: String {
        return BundleLoader.moduleLocalized(key: self, in: Bundle.liveBundle, tableName: "TUILiveKitLocalized")
    }
    
    static func liveLocalizedReplace(_ key: String, replaces: CVarArg...) -> String {
        return BundleLoader.moduleLocalized(key: key, in: Bundle.liveBundle, tableName: "TUILiveKitLocalized", arguments: replaces)
    }
    
    //TODO: 要废弃 chengyu
    static func localizedReplace(_ origin: String, replace: String) -> String {
        return origin.replacingOccurrences(of: "xxx", with: replace)
    }
}

private class LiveBundleToken {}

public extension Bundle {
    static var liveBundle: Bundle {
        // SPM 下不能走 BundleLoader：moduleBundle 的 SWIFT_PACKAGE 分支返回的是
        // 它所在 target（AtomicX）的 Bundle.module——LiveKit 作为第二个 SPM 包
        // 调它时，拿到的资源包是错的，图片和多语言全部 miss（表现为文案回退成
        // key）。这里必须用 LiveKit 自己的 Bundle.module。
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        return BundleLoader.moduleBundle(named: "TUILiveKitBundle",
                                         moduleName: "TUILiveKit",
                                         for: LiveBundleToken.self) ?? .main
        #endif
    }
}
