//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import FinniversKit

final class TransactionDemoView: UIView {
    private lazy var transactionView: TransactionView = TransactionView(title: "Salgsprosess", numberOfSteps: 8, withAutoLayout: true)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        addSubview(transactionView)
        transactionView.fillInSuperview()
    }
}
