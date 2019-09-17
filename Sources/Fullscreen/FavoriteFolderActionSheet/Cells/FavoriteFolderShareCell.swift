//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol FavoriteFolderShareViewDelegate: AnyObject {
    func favoriteFolderShareView(_ view: FavoriteFolderShareView, didChangeValueFor switchControl: UISwitch)
}

final class FavoriteFolderShareView: UIView {
    weak var delegate: FavoriteFolderShareViewDelegate?

    private lazy var titleLabel = FavoriteActionCell.makeTitleLabel()

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(withAutoLayout: true)
        imageView.image = UIImage(named: .favoritesShare).withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .licorice
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var switchControl: UISwitch = {
        let control = UISwitch(withAutoLayout: true)
        control.onTintColor = .primaryBlue
        control.addTarget(self, action: #selector(handleSwitchValueChange), for: .valueChanged)
        return control
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Setup

    func configure(withTitle title: String, switchOn: Bool) {
        titleLabel.text = title
        switchControl.isOn = switchOn
    }

    private func setup() {
        isAccessibilityElement = true
        backgroundColor = .milk

        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(switchControl)

        NSLayoutConstraint.activate([
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .mediumLargeSpacing),
            iconImageView.widthAnchor.constraint(equalToConstant: FavoriteActionCell.iconSize),
            iconImageView.heightAnchor.constraint(equalTo: iconImageView.widthAnchor),

            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: .mediumLargeSpacing),
            titleLabel.trailingAnchor.constraint(equalTo: switchControl.leadingAnchor, constant: -.mediumLargeSpacing),

            switchControl.centerYAnchor.constraint(equalTo: centerYAnchor),
            switchControl.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.mediumLargeSpacing)
        ])
    }

    // MARK: - Action

    @objc private func handleSwitchValueChange() {
        delegate?.favoriteFolderShareView(self, didChangeValueFor: switchControl)
    }
}
