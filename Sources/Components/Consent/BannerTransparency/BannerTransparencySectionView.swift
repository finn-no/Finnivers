//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol BannerTransparencySectionViewDelegate: AnyObject {
    func bannerTransparencySectionViewDidSelectExternalLinkButton(_ view: BannerTransparencySectionView)
}

final class BannerTransparencySectionView: UIView {
    weak var delegate: BannerTransparencySectionViewDelegate?

    private lazy var titleLabel: Label = {
        let label = Label(style: .title4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()

    private lazy var textLabel: Label = {
        let label = Label(style: .title4)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .caption
        label.textColor = .licorice
        label.numberOfLines = 0
        return label
    }()

    private lazy var externalLinkButton: Button = {
        let button = Button(style: .flat)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)
        return button
    }()

    private lazy var externalLinkImageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.image = UIImage(named: .webview)
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: externalLinkButton.frame.maxY)
    }

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    func set(title: String, text: String, buttonTitle: String) {
        titleLabel.text = title
        textLabel.text = text
        externalLinkButton.setTitle(buttonTitle, for: .normal)
    }

    private func setup() {
        addSubview(titleLabel)
        addSubview(textLabel)
        addSubview(externalLinkButton)
        addSubview(externalLinkImageView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            textLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor),

            externalLinkButton.topAnchor.constraint(equalTo: textLabel.bottomAnchor),
            externalLinkButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            externalLinkButton.trailingAnchor.constraint(equalTo: externalLinkImageView.leadingAnchor, constant: -.mediumLargeSpacing),

            externalLinkImageView.centerYAnchor.constraint(equalTo: externalLinkButton.centerYAnchor),
            externalLinkImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            externalLinkImageView.widthAnchor.constraint(equalToConstant: 18),
            externalLinkImageView.heightAnchor.constraint(equalTo: externalLinkImageView.widthAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func handleButtonTap() {
        delegate?.bannerTransparencySectionViewDidSelectExternalLinkButton(self)
    }
}
