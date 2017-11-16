//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit
import Troika

public class PreviewCellPlaygroundView: UIView, Injectable {
    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    public func setup() {
        backgroundColor = .white

        let previewCell = PreviewCell(frame: .zero)
        previewCell.translatesAutoresizingMaskIntoConstraints = false
        let model = PreviewDataModelFactory.create(numberOfModels: 1).first!
        let dataSource = APreviewCellDataSource()

        let multiplier = model.imageSize.height / model.imageSize.width
        let width: CGFloat = 200.0

        previewCell.loadingColor = .blue
        previewCell.dataSource = dataSource
        previewCell.model = model
        addSubview(previewCell)

        NSLayoutConstraint.activate([
            previewCell.topAnchor.constraint(equalTo: topAnchor),
            previewCell.leadingAnchor.constraint(equalTo: leadingAnchor),
            previewCell.widthAnchor.constraint(equalToConstant: width),
            previewCell.heightAnchor.constraint(equalToConstant: (width * multiplier) + PreviewCell.nonImageHeight),
        ])
    }
}
