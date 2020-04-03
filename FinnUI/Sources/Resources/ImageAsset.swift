//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

// Generated by generate_image_assets_symbols as a "Run Script" Build Phase
// WARNING: This file is autogenerated, do not modify by hand

import UIKit

private class BundleHelper {
}

extension UIImage {
    convenience init(named imageAsset: ImageAsset) {
        self.init(named: imageAsset.rawValue, in: Bundle(for: BundleHelper.self), compatibleWith: nil)!
    }

    @objc class func assetNamed(_ assetName: String) -> UIImage {
        return UIImage(named: assetName, in: Bundle(for: BundleHelper.self), compatibleWith: nil)!
    }
}

//swiftlint:disable superfluous_disable_command
//swiftlint:disable type_body_length
enum ImageAsset: String {
    case splashLetters1
    case splashLetters2
    case splashLetters3
    case splashLetters4
    case splashLogo
    case videoChat

    static var imageNames: [ImageAsset] {
        return [
            .splashLetters1,
            .splashLetters2,
            .splashLetters3,
            .splashLetters4,
            .splashLogo,
            .videoChat,
    ]
  }
}
