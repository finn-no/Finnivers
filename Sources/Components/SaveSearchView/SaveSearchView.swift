//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import UIKit

public protocol SaveSearchViewDelegate: AnyObject {
    func saveSearchViewTextFieldWillReturn(_ saveSearchView: SaveSearchView)
    func saveSearchView(_ saveSearchView: SaveSearchView, didUpdateIsPushOn: Bool)
    func saveSearchView(_ saveSearchView: SaveSearchView, didUpdateIsEmailOn: Bool)
}

public class SaveSearchView: UIView {
    // MARK: - Public properties

    public weak var delegate: SaveSearchViewDelegate?

    public var isPushOn: Bool {
        get {
            return pushSwitchView.isOn
        }
        set {
            pushSwitchView.isOn = newValue
            delegate?.saveSearchView(self, didUpdateIsPushOn: newValue)
        }
    }

    public var isEmailOn: Bool {
        get {
            return emailSwitchView.isOn
        }
        set {
            emailSwitchView.isOn = newValue
            delegate?.saveSearchView(self, didUpdateIsEmailOn: newValue)
        }
    }

    public var searchNameText: String? {
        get {
            return searchNameTextField.text
        }
        set {
            searchNameTextField.textField.text = newValue
        }
    }

    // MARK: - Private properties

    private lazy var searchNameContainer: UIView = UIView(withAutoLayout: true)

    private lazy var searchNameTextField: TextField = {
        let textField = TextField(inputType: .normal)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textField.returnKeyType = .go
        textField.delegate = self
        return textField
    }()

    private lazy var pushSwitchView: SwitchView = {
        let view = SwitchView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var emailSwitchView: SwitchView = {
        let view = SwitchView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var hairline: UIView = {
        let line = UIView(frame: .zero)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.backgroundColor = .sardine
        return line
    }()

    // MARK: - Initializers

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    // MARK: - Public methods

    public func configure(with viewModel: SaveSearchViewModel) {
        searchNameTextField.placeholderText = viewModel.searchPlaceholderText
        pushSwitchView.configure(with: viewModel.pushSwitchViewModel)
        emailSwitchView.configure(with: viewModel.emailSwitchViewModel)
    }

    @discardableResult public override func becomeFirstResponder() -> Bool {
        return searchNameTextField.textField.becomeFirstResponder()
    }

    @discardableResult public override func resignFirstResponder() -> Bool {
        return searchNameTextField.textField.resignFirstResponder()
    }

    // MARK: - Private methods

    private func setup() {
        backgroundColor = .milk

        addSubview(searchNameContainer)
        searchNameContainer.addSubview(searchNameTextField)

        addSubview(pushSwitchView)
        addSubview(hairline)
        addSubview(emailSwitchView)

        NSLayoutConstraint.activate([
            searchNameContainer.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            searchNameContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: .mediumLargeSpacing),
            searchNameContainer.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            searchNameContainer.heightAnchor.constraint(equalToConstant: 65.0),

            searchNameTextField.leadingAnchor.constraint(equalTo: searchNameContainer.leadingAnchor, constant: .mediumLargeSpacing),
            searchNameTextField.trailingAnchor.constraint(equalTo: searchNameContainer.trailingAnchor, constant: -.mediumLargeSpacing),
            searchNameTextField.centerYAnchor.constraint(equalTo: searchNameContainer.centerYAnchor),

            pushSwitchView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            pushSwitchView.topAnchor.constraint(equalTo: searchNameContainer.bottomAnchor, constant: .mediumLargeSpacing),
            pushSwitchView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),

            hairline.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: .mediumLargeSpacing),
            hairline.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            hairline.topAnchor.constraint(equalTo: pushSwitchView.bottomAnchor),
            hairline.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            emailSwitchView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            emailSwitchView.topAnchor.constraint(equalTo: hairline.bottomAnchor),
            emailSwitchView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
        ])
    }
}

extension SaveSearchView: TextFieldDelegate {
    public func textFieldShouldReturn(_ textField: TextField) -> Bool {
        delegate?.saveSearchViewTextFieldWillReturn(self)
        return true
    }
}

extension SaveSearchView: SwitchViewDelegate {
    public func switchView(_ switchView: SwitchView, didChangeValueFor switch: UISwitch) {
        if switchView == pushSwitchView {
            delegate?.saveSearchView(self, didUpdateIsPushOn: isPushOn)
        }

        if switchView == emailSwitchView {
            delegate?.saveSearchView(self, didUpdateIsEmailOn: isEmailOn)
        }
    }
}
