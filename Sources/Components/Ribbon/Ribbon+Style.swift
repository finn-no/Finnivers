//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public extension RibbonView {
    enum Style {
        case `default`
        case success
        case warning
        case error
        case disabled
        case sponsored

        var color: UIColor {
            switch self {
            case .default: return .bgSecondary
            case .success: return .bgSuccess
            case .warning: return .bgAlert
            case .error: return .salmon
            case .disabled: return .sardine
            case .sponsored: return .toothPaste
            }
        }
    }
}
