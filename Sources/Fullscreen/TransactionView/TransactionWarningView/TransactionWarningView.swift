//
//  Copyright © 2020 FINN AS. All rights reserved.
//

import UIKit

public class TransactionWarningView: UIView {
    weak var dataSource: RemoteImageViewDataSource? {
        didSet {
            imageView.dataSource = dataSource
        }
    }

    private lazy var titleLabel: Label = {
        let label = Label(style: .bodyStrong, withAutoLayout: true)
        label.textColor = .textToast
        label.numberOfLines = 0
        return label
    }()

    private lazy var messageView: UITextView = {
        let view = UITextView(withAutoLayout: true)
        let style = Label.Style.caption
        view.font = style.font
        view.textColor = .textToast
        view.backgroundColor = .clear
        view.contentInset = .leadingInset(0)
        view.isScrollEnabled = false
        view.isEditable = false
        view.isUserInteractionEnabled = false
        view.adjustsFontForContentSizeCategory = true
        view.textContainer.widthTracksTextView = true
        view.textContainer.heightTracksTextView = true
        return view
    }()

    private lazy var imageView: RemoteImageView = {
        let imageView = RemoteImageView(withAutoLayout: true)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = .spacingM
        return imageView
    }()

    private static var defaultImageSize: CGFloat = 128
    private var loadingColor: UIColor = .accentToothpaste
    private var fallbackImage = UIImage(named: .noImage)

    private var model: TransactionWarningViewModel

    public init(withAutoLayout autoLayout: Bool = false, model: TransactionWarningViewModel) {
        self.model = model

        super.init(frame: .zero)

        translatesAutoresizingMaskIntoConstraints = !autoLayout

        setup()
    }

    public func loadImage() {
        guard let imagePath = model.imageUrl else {
            imageView.image = fallbackImage
            return
        }

        imageView.loadImage(
            for: imagePath,
            imageWidth: TransactionWarningView.defaultImageSize,
            loadingColor: loadingColor,
            fallbackImage: fallbackImage
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .bgAlert
        layer.cornerRadius = .spacingS

        titleLabel.text = model.title
        messageView.text = model.message

        addSubview(titleLabel)
        addSubview(messageView)
        addSubview(imageView)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .spacingM),
            titleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: .spacingM),

            messageView.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageView.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            messageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: .spacingS),

            imageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor, constant: .spacingS),
            imageView.widthAnchor.constraint(equalToConstant: TransactionWarningView.defaultImageSize),
            imageView.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: messageView.bottomAnchor),

            bottomAnchor.constraint(equalTo: messageView.bottomAnchor, constant: .spacingM),
        ])

        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        messageView.setContentHuggingPriority(.required, for: .vertical)
    }
}