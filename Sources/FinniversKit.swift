//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

/// Class for referencing the framework bundle
@objc public class FinniversKit: NSObject {
    static var bundle: Bundle {
        return Bundle(for: FinniversKit.self)
    }

    @objc public static var isDynamicTypeEnabled: Bool = true
}

@objc public extension Bundle {
    @objc static var finniversKit: Bundle {
        return FinniversKit.bundle
    }
}

@objc public extension UIImage {
    @objc public class func named(_ imageName: String) -> UIImage {
        return UIImage(named: imageName, in: FinniversKit.bundle, compatibleWith: nil)!
    }
}
