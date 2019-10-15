//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public extension Button {
    enum Size {
        case normal
        case small
    }

    enum Style {
        case `default`
        case callToAction
        case destructive
        case flat
        case link

        var bodyColor: UIColor {
            switch self {
            case .default: return .bgPrimary
            case .link, .flat: return .clear
            case .callToAction: return .btnPrimary
            case .destructive: return .btnCritical
            }
        }

        var borderWidth: CGFloat {
            switch self {
            case .default: return 2.0
            default: return 0.0
            }
        }

        var borderColor: UIColor? {
            switch self {
            case .default: return .accentSecondaryBlue
            default: return nil
            }
        }

        var textColor: UIColor {
            switch self {
            case .default, .link, .flat: return .textAction
            default: return .milk
            }
        }

        var highlightedBodyColor: UIColor? {
            switch self {
            case .callToAction: return .callToActionButtonHighlightedBodyColor
            case .destructive: return .destructiveButtonHighlightedBodyColor
            case .default: return .defaultButtonHighlightedBodyColor
            default: return nil
            }
        }

        var highlightedBorderColor: UIColor? {
            switch self {
            case .default: return .btnPrimary //DARK
            default: return nil
            }
        }

        var highlightedTextColor: UIColor? {
            switch self {
            case .link: return .linkButtonHighlightedTextColor
            case .flat: return .flatButtonHighlightedTextColor
            default: return nil
            }
        }

        var disabledBodyColor: UIColor? {
            switch self {
            case .default, .link, .flat: return nil
            default: return .btnDisabled
            }
        }

        var disabledBorderColor: UIColor? {
            switch self {
            case .default: return .btnDisabled
            default: return nil
            }
        }

        var disabledTextColor: UIColor? {
            switch self {
            case .callToAction, .destructive: return nil
            default: return .textDisabled
            }
        }

        var margins: UIEdgeInsets {
            switch self {
            case .link: return UIEdgeInsets(top: .smallSpacing, left: 0, bottom: .smallSpacing, right: 0)
            default: return UIEdgeInsets(top: .mediumSpacing, left: .mediumLargeSpacing, bottom: .mediumSpacing, right: .mediumLargeSpacing)
            }
        }

        func font(forSize size: Size) -> UIFont {
            switch (self, size) {
            case (.link, .normal):
                return .caption
            case (.link, .small):
                return .detail
            case (_, .normal):
                return .bodyStrong
            case (_, .small):
                return .detailStrong
            }
        }

        func paddings(forSize size: Size) -> UIEdgeInsets {
            switch size {
            case .normal:
                return UIEdgeInsets(top: .smallSpacing, left: 0, bottom: .smallSpacing, right: 0)
            case .small:
                return .zero
            }
        }

        func backgroundColor(forState state: State) -> UIColor? {
            switch state {
            case .highlighted:
                return highlightedBodyColor
            case .disabled:
                return disabledBodyColor
            default:
                return bodyColor
            }
        }

        func borderColor(forState state: State) -> CGColor? {
            switch state {
            case .highlighted:
                return highlightedBorderColor?.cgColor
            case .disabled:
                return disabledBorderColor?.cgColor
            default:
                return borderColor?.cgColor
            }
        }
    }
}
