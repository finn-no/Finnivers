//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

// MARK: - TextFieldDelegate

public protocol TextFieldDelegate: NSObjectProtocol {
    func textFieldDidBeginEditing(_ textField: TextField)
    func textFieldDidEndEditing(_ textField: TextField)
    func textFieldShouldReturn(_ textField: TextField) -> Bool
    func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textFieldDidChange(_ textField: TextField)
    func textFieldDidTapMultilineAction(_ textField: TextField)
}

public extension TextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldDidEndEditing(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldShouldReturn(_ textField: TextField) -> Bool {
        return true
    }

    func textField(_ textField: TextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }

    func textFieldDidChange(_ textField: TextField) {
        // Default empty implementation
    }

    func textFieldDidTapMultilineAction(_ textField: TextField) {
        // Default empty implementation
    }
}

public class TextField: UIView {
    // MARK: - Internal properties

    private let eyeImage = UIImage(named: .view).withRenderingMode(.alwaysTemplate)
    private let clearTextIcon = UIImage(named: .remove).withRenderingMode(.alwaysTemplate)
    private let multilineDisclosureIcon = UIImage(named: .remove).withRenderingMode(.alwaysTemplate)
    private let errorImage = UIImage(named: .error)
    private let rightViewSize = CGSize(width: 40, height: 40)
    private let animationDuration: Double = 0.3
    private let errorIconWidth: CGFloat = 18

    private var helpTextLabelLeadingConstraint: NSLayoutConstraint?

    private var state: State {
        didSet {
            transition(to: state)
        }
    }

    private lazy var typeLabel: Label = {
        let label = Label(style: .title5)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var clearButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: clearTextIcon.size.width, height: clearTextIcon.size.height))
        button.setImage(clearTextIcon, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        return button
    }()

    private lazy var showPasswordButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: eyeImage.size.width, height: eyeImage.size.width))
        button.setImage(eyeImage, for: .normal)
        button.imageView?.tintColor = .stone
        button.addTarget(self, action: #selector(showHidePassword), for: .touchUpInside)
        return button
    }()

    private lazy var textFieldBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = state.backgroundColor
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.layer.borderColor = state.borderColor.cgColor
        view.layer.borderWidth = state.borderWidth
        return view
    }()

    private lazy var helpTextLabel: Label = {
        let label = Label(style: .detail)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var errorIconImageView: UIImageView = {
        let imageView = UIImageView(image: errorImage)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - External properties

    public lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.body
        textField.textColor = .licorice
        textField.tintColor = .secondaryBlue
        textField.delegate = self
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.enablesReturnKeyAutomatically = true
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()

    public let inputType: InputType

    public var placeholderText: String = "" {
        didSet {
            typeLabel.text = placeholderText
            accessibilityLabel = placeholderText

            let placeholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedStringKey.foregroundColor: UIColor.sardine])
            textField.attributedPlaceholder = placeholder
        }
    }

    public var text: String? {
        get {
            return textField.text
        }

        set {
            textField.text = newValue
        }
    }

    public var helpText: String? {
        didSet {
            helpTextLabel.text = helpText
        }
    }

    public weak var delegate: TextFieldDelegate?

    public var isValid: Bool {
        guard let text = textField.text else {
            return false
        }

        switch inputType {
        case .password:
            return isValidPassword(text)
        case .email:
            return isValidEmail(text)
        case .normal:
            return true
        }
    }

    public var isEnabled: Bool = true {
        didSet {
            let previousState = state

            if isEnabled != oldValue {
                transition(to: isEnabled ? previousState : .disabled)
            }
        }
    }

    // MARK: - Setup

    public init(state: State = .normal, inputType: InputType) {
        self.state = state
        self.inputType = inputType
        super.init(frame: .zero)
        setup()
    }

    public required convenience init?(coder aDecoder: NSCoder) {
        self.init(inputType: .normal)
    }

    private func setup() {
        isAccessibilityElement = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        textField.isSecureTextEntry = inputType.isSecureTextEntry
        textField.keyboardType = inputType.keyboardType
        textField.autocapitalizationType = inputType.autocapitalizationType
        textField.autocorrectionType = inputType.autocorrectionType
        textField.returnKeyType = inputType.returnKeyType

        switch inputType {
        case .password:
            textField.rightViewMode = .always
            textField.rightView = showPasswordButton

        default:
            textField.rightViewMode = .whileEditing
            textField.rightView = clearButton
        }

        if case .email = inputType {
            // Help text shows on error only.
            helpTextLabel.alpha = 0.0
        }

        // Error image should not show until we are in an error state
        errorIconImageView.alpha = 0.0

        addSubview(typeLabel)
        addSubview(textFieldBackgroundView)
        addSubview(textField)
        addSubview(helpTextLabel)
        addSubview(errorIconImageView)

        NSLayoutConstraint.activate([
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            typeLabel.topAnchor.constraint(equalTo: topAnchor),

            textFieldBackgroundView.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: .smallSpacing),
            textFieldBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textFieldBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),

            textField.topAnchor.constraint(equalTo: textFieldBackgroundView.topAnchor, constant: .mediumSpacing + .smallSpacing),
            textField.leadingAnchor.constraint(equalTo: textFieldBackgroundView.leadingAnchor, constant: .mediumSpacing),
            textField.trailingAnchor.constraint(equalTo: textFieldBackgroundView.trailingAnchor, constant: -.mediumSpacing),
            textField.bottomAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor, constant: -.mediumSpacing + -.smallSpacing),

            errorIconImageView.topAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor, constant: .smallSpacing),
            errorIconImageView.leadingAnchor.constraint(equalTo: leadingAnchor),

            helpTextLabel.topAnchor.constraint(equalTo: textFieldBackgroundView.bottomAnchor, constant: .smallSpacing),
            helpTextLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            helpTextLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        helpTextLabelLeadingConstraint = helpTextLabel.leadingAnchor.constraint(equalTo: leadingAnchor)
        helpTextLabelLeadingConstraint?.isActive = true
    }

    // MARK: - Actions

    @objc private func showHidePassword(sender: UIButton) {
        sender.isSelected = !sender.isSelected

        if sender.isSelected {
            sender.imageView?.tintColor = .secondaryBlue
            textField.isSecureTextEntry = false
        } else {
            sender.imageView?.tintColor = .stone
            textField.isSecureTextEntry = true
        }

        textField.becomeFirstResponder()
    }

    @objc private func clearTapped() {
        textField.text = ""
        textFieldDidChange()
    }

    @objc private func multilineDisclusureTapped(sender: UIButton) {
        delegate?.textFieldDidTapMultilineAction(self)
    }

    @objc private func textFieldDidChange() {
        delegate?.textFieldDidChange(self)
    }

    @objc private func handleTap() {
        textField.becomeFirstResponder()
    }

    // MARK: - Functionality

    fileprivate func evaluate(_ regEx: String, with string: String) -> Bool {
        let regExTest = NSPredicate(format: "SELF MATCHES %@", regEx)
        return regExTest.evaluate(with: string)
    }

    fileprivate func isValidEmail(_ emailAdress: String) -> Bool {
        return evaluate("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", with: emailAdress)
    }

    fileprivate func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty
    }

    fileprivate func shouldDisplayErrorHelpText() -> Bool {
        guard state == .error else {
            return false
        }

        guard let helpText = helpText, helpText.count > 0 else {
            return false
        }

        return true
    }

    private func transition(to state: State) {
        layoutIfNeeded()

        if shouldDisplayErrorHelpText() {
            helpTextLabelLeadingConstraint?.constant = errorIconImageView.frame.size.width + .smallSpacing
        } else {
            helpTextLabelLeadingConstraint?.constant = 0.0
        }

        UIView.animate(withDuration: animationDuration) {
            self.layoutIfNeeded()
            self.textFieldBackgroundView.layer.borderColor = state.borderColor.cgColor
            self.textFieldBackgroundView.layer.borderWidth = state.borderWidth
            self.textFieldBackgroundView.backgroundColor = state.backgroundColor
            self.typeLabel.textColor = state.accessoryLabelTextColor
            self.helpTextLabel.textColor = state.accessoryLabelTextColor

            if self.inputType == .email {
                if self.shouldDisplayErrorHelpText() {
                    self.helpTextLabel.alpha = 1.0
                    self.errorIconImageView.alpha = 1.0
                } else {
                    self.helpTextLabel.alpha = 0.0
                    self.errorIconImageView.alpha = 0.0
                }
            }
        }
    }
}

// MARK: - UITextFieldDelegate

extension TextField: UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }

    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
        state = .focus
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(self)

        if let text = textField.text, !isValidEmail(text), !text.isEmpty, inputType == .email {
            state = .error
        } else {
            state = .normal
        }
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return delegate?.textFieldShouldReturn(self) ?? true
    }

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return delegate?.textField(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
}
