//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import Foundation

public struct BroadcastMessage: Equatable {
    public let id: Int
    public let text: String

    public init(id: Int, message: String) {
        self.id = id
        self.text = message
    }

    public static func == (lhs: BroadcastMessage, rhs: BroadcastMessage) -> Bool {
        return lhs.id == rhs.id && lhs.text == rhs.text
    }
}
