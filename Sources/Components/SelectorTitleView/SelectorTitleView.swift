//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol SelectorTitleViewDelegate: AnyObject {
    func selectorTitleViewDidSelectButton(_ view: SelectorTitleView)
}

public class SelectorTitleView: UIView {
    public enum ArrowDirection {
        case up
        case down
    }

    public weak var delegate: SelectorTitleViewDelegate?

    public var arrowDirection: ArrowDirection = .down {
        didSet {
            let asset: FinniversImageAsset = arrowDirection == .up ? .arrowUpSmall : .arrowDownSmall
            button.setImage(UIImage(named: asset), for: .normal)
        }
    }

    private var isEnabled: Bool = true {
        didSet {
            button.isEnabled = isEnabled
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel(withAutoLayout: true)
        label.font = UIFont.captionStrong.withSize(12).scaledFont(forTextStyle: .footnote)
        label.adjustsFontForContentSizeCategory = true
        label.textAlignment = .center
        label.text = heading
        label.textColor = .textSecondary
        return label
    }()

    private lazy var button: UIButton = {
        let button = UIButton(withAutoLayout: true)
        button.titleLabel?.font = UIFont.bodyStrong.withSize(17).scaledFont(forTextStyle: .footnote)
        button.titleLabel?.adjustsFontForContentSizeCategory = true

        let spacing = .smallSpacing / 2

        button.semanticContentAttribute = .forceRightToLeft
        button.imageEdgeInsets = UIEdgeInsets(top: spacing, leading: spacing, bottom: 0, trailing: -spacing)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, leading: -spacing, bottom: 0, trailing: spacing)
        button.addTarget(self, action: #selector(handleButtonTap), for: .touchUpInside)

        let buttonColor: UIColor = .btnPrimary
        let interfaceBackgroundColor: UIColor = .bgPrimary
        button.setTitleColor(buttonColor, for: .normal)
        button.setTitleColor(buttonColor.withAlphaComponent(0.5), for: .highlighted)
        button.setTitleColor(buttonColor.withAlphaComponent(0.5), for: .selected)
        button.setTitleColor(.btnDisabled, for: .disabled)
        button.tintColor = buttonColor

        if heading != nil {
            button.contentEdgeInsets = UIEdgeInsets(
                top: titleLabel.font.pointSize,
                leading: .mediumLargeSpacing + spacing,
                bottom: 0,
                trailing: .mediumLargeSpacing + spacing
            )
        }

        return button
    }()

    private var heading: String?

    // MARK: - Init

    public init(heading: String) {
        self.heading = heading
        super.init(frame: .zero)
        setup()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    public var title: String? {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    private func setup() {
        arrowDirection = .down
        isEnabled = true
        backgroundColor = .bgPrimary
        addSubview(button)

        button.fillInSuperview()

        if heading != nil {
            addSubview(titleLabel)
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

                button.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            ])
        }
    }

    // MARK: - Actions

    @objc private func handleButtonTap() {
        delegate?.selectorTitleViewDidSelectButton(self)
    }
}