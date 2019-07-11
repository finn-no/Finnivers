//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

/// Branded alternative of SVProgressHUD. It's presented on top of the top-most view.
@objc public class LoadingView: UIView {
    private enum State {
        case hidden
        case message
        case success
    }

    public enum DisplayType {
        case fullscreen
        case boxed
    }

    /// Allows the loading view to use a plain UIActivityIndicatorView,
    /// useful for a smooth transition between the old indicator and the new one,
    /// by using this flag we can avoid having multiple styles of showing progress in our app.
    @objc public static var shouldUseOldIndicator: Bool = false

    private let animationDuration: TimeInterval = 0.3
    private let loadingIndicatorSize: CGFloat = 40
    /// Used for throttling
    private var state: State = .hidden
    private let loadingIndicatorInitialTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    private static let shared = LoadingView()

    public var displayType = DisplayType.boxed

    private lazy var newLoadingIndicator: LoadingIndicatorView = {
        let view = LoadingIndicatorView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = loadingIndicatorInitialTransform
        return view
    }()

    private lazy var oldLoadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .whiteLarge)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.transform = loadingIndicatorInitialTransform
        view.color = .primaryBlue
        return view
    }()

    private lazy var messageLabel: UILabel = {
        let label = Label(style: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private lazy var successImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(named: .checkmarkBig).withRenderingMode(.alwaysTemplate)
        view.tintColor = LoadingView.shouldUseOldIndicator ? .primaryBlue : .secondaryBlue
        view.alpha = 0
        view.transform = loadingIndicatorInitialTransform
        return view
    }()

    private var defaultWindow: UIWindow?

    init(window: UIWindow? = UIApplication.shared.keyWindow) {
        super.init(frame: .zero)
        defaultWindow = window
        alpha = 0
        translatesAutoresizingMaskIntoConstraints = false
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    /// Adds a layer on top of the top-most view and starts the animation of the loading indicator.
    ///
    /// - Parameter message: The message to be displayed (optional)
    /// - Parameter afterDelay: The delay time (in seconds) before the loading view will be shown (optional, defaults to 0.5s)
    @objc public class func show(withMessage message: String? = nil, afterDelay delay: Double = 0.5) {
        LoadingView.shared.state = .message

        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            if LoadingView.shared.state == .message {
                LoadingView.shared.startAnimating(withMessage: message)
            }
        })
    }

    /// Adds a layer on top of the top-most view and starts the animation of the loading indicator.
    ///
    /// - Parameter message: The message to be displayed (optional)
    /// - Parameter afterDelay: The delay time (in seconds) before the success view will be shown (optional, defaults to 0.5s)
    @objc public class func showSuccess(withMessage message: String? = nil, afterDelay delay: Double = 0.5) {
        LoadingView.shared.state = .success

        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            if LoadingView.shared.state == .success {
                LoadingView.shared.showSuccess(withMessage: message)
            }
        })
    }

    /// Stops the animation of the loading indicator and removes the loading view.
    /// - Note: Must be called from the main thread
    @objc public class func hide() {
        LoadingView.shared.state = .hidden
        LoadingView.shared.stopAnimating()
    }

    /// After a delay, stops the animation of the loading indicator and removes the loading view.
    /// - Note: Can be called from a background thread.
    @objc public class func hide(afterDelay delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: {
            hide()
        })
    }
}

// MARK: - Private methods

private extension LoadingView {
    private func setup() {
        backgroundColor = UIColor.black.withAlphaComponent(0.8)

        let loadingIndicator = LoadingView.shouldUseOldIndicator ? oldLoadingIndicator : newLoadingIndicator
        addSubview(loadingIndicator)
        addSubview(messageLabel)
        addSubview(successImageView)
        NSLayoutConstraint.activate([
            successImageView.widthAnchor.constraint(equalToConstant: loadingIndicatorSize),
            successImageView.heightAnchor.constraint(equalToConstant: loadingIndicatorSize),
            successImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            successImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -.mediumSpacing),

            loadingIndicator.widthAnchor.constraint(equalToConstant: loadingIndicatorSize),
            loadingIndicator.heightAnchor.constraint(equalToConstant: loadingIndicatorSize),
            loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -.mediumSpacing),

            messageLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: .mediumLargeSpacing),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .veryLargeSpacing),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.veryLargeSpacing)
        ])
    }

    private func startAnimating(withMessage message: String? = nil) {
        if superview == nil {
            guard let window = defaultWindow else { return }
            window.addSubview(self)

            switch displayType {
            case .fullscreen:
                fillInSuperview()
            case .boxed:
                NSLayoutConstraint.activate([
                    heightAnchor.constraint(equalToConstant: 120),
                    widthAnchor.constraint(equalToConstant: 120),
                    centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    centerYAnchor.constraint(equalTo: window.centerYAnchor)
                    ])
            }
        }

        var loadingIndicator: LoadingViewAnimatable = LoadingView.shouldUseOldIndicator ? oldLoadingIndicator : newLoadingIndicator
        loadingIndicator.startAnimating()
        messageLabel.text = message
        successImageView.alpha = 0
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 1
            loadingIndicator.alpha = 1
            loadingIndicator.transform = .identity
        }
    }

    private func showSuccess(withMessage message: String? = nil) {
        if superview == nil {
            guard let window = defaultWindow else { return }
            window.addSubview(self)

            switch displayType {
            case .fullscreen:
                fillInSuperview()
            case .boxed:
                NSLayoutConstraint.activate([
                    heightAnchor.constraint(equalToConstant: 120),
                    widthAnchor.constraint(equalToConstant: 120),
                    centerXAnchor.constraint(equalTo: window.centerXAnchor),
                    centerYAnchor.constraint(equalTo: window.centerYAnchor)
                    ])
            }
        }

        var loadingIndicator: LoadingViewAnimatable = LoadingView.shouldUseOldIndicator ? oldLoadingIndicator : newLoadingIndicator
        loadingIndicator.alpha = 0
        messageLabel.text = message
        UIView.animate(withDuration: animationDuration) {
            self.alpha = 1
            self.successImageView.alpha = 1
            self.successImageView.transform = .identity
        }
    }

    private func stopAnimating() {
        if defaultWindow != nil {
            var loadingIndicator: LoadingViewAnimatable = LoadingView.shouldUseOldIndicator ? oldLoadingIndicator : newLoadingIndicator
            UIView.animate(withDuration: animationDuration, animations: {
                self.alpha = 0
                loadingIndicator.transform = self.loadingIndicatorInitialTransform
                self.successImageView.transform = self.loadingIndicatorInitialTransform
            }, completion: { _ in
                self.messageLabel.text = nil
                loadingIndicator.stopAnimating()
                self.removeFromSuperview()
            })
        }
    }
}
