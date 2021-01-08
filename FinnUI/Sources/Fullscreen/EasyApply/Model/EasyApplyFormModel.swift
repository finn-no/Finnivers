//
//  Copyright © 2021 FINN.no AS. All rights reserved.
//

import SwiftUI
import FinniversKit

@available(iOS 13.0, *)
class EasyApplyFormModel: ObservableObject {
    let name: String
    let position: String
    @Published var textfields: [EasyApplyTextField]
    @Published var questions: [EasyApplyQuestion]

    init(name: String, position: String, textfields: [EasyApplyTextField], selects: [EasyApplyQuestion]) {
        self.name = name
        self.position = position
        self.textfields = textfields
        self.questions = selects
    }
}
