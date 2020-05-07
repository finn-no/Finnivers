//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

public struct SettingsSection: Equatable, Hashable {
    public let title: String?
    public var rows: [SettingsRow]
    public let footerTitle: String?

    public init(title: String?, rows: [SettingsRow], footerTitle: String? = nil) {
        self.title = title
        self.rows = rows
        self.footerTitle = footerTitle
    }
}

public enum SettingsRow: Equatable, Hashable {
    case text(SettingsTextViewModel)
    case consent(SettingsConsentViewModel)
    case toggle(SettingsToggleViewModel)
}