//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol BroadcastContainerDelegate: class {
    func broadcastContainer(_ broadcastContainer: BroadcastContainer, didTapURL url: URL, inBroadcastAtIndex index: Int)
}

// MARK: - BroadcastContainerDelegate default implementations

public extension BroadcastContainerDelegate {
    func broadcastContainer(_ broadcastContainer: BroadcastContainer, didTapURL url: URL, inBroadcastAtIndex index: Int) {}
}

// MARK: -

public final class BroadcastContainer: UIStackView {

    // MARK: Public properties

    public weak var delegate: BroadcastContainerDelegate?

    // MARK: - Private properties

    private weak var scrollView: UIScrollView?
    private var topConstraint: NSLayoutConstraint!
    private var animationDuration = 0.3

    // MARK: - Setup

    public override init(frame: CGRect) {
        super.init(frame: frame)
        spacing = .mediumLargeSpacing

        axis = .vertical
        distribution = .fill
        alignment = .fill

        layoutMargins = UIEdgeInsets(top: .mediumLargeSpacing, leading: .mediumLargeSpacing, bottom: .mediumLargeSpacing, trailing: .mediumLargeSpacing)
        isLayoutMarginsRelativeArrangement = true
    }

    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Implementation

    public func presentMessages(_ messages: [BroadcastMessage], in view: UIView, animated: Bool = true) {
        guard superview == nil else { return }

        if let scrollView = view as? UIScrollView {
            self.scrollView = scrollView
            // Add container on top of scroll view
            scrollView.superview?.addSubview(self)
            // Moving gesture to superview enables scrolling inside the broadcast container as well
            superview?.addGestureRecognizer(scrollView.panGestureRecognizer)
        } else {
            view.addSubview(self)
        }

        superview?.clipsToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        topConstraint = topAnchor.constraint(equalTo: view.topAnchor)

        // Bottom constraint is only used for the presenting animation
        let bottomConstraint = bottomAnchor.constraint(equalTo: view.topAnchor)
        bottomConstraint.isActive = true

        for message in messages {
            let model = BroadcastModel(with: message.text)
            let broadcast = Broadcast(frame: .zero)
            broadcast.model = model
            broadcast.delegate = self
            addArrangedSubview(broadcast)
        }

        // Place container above the screen
        superview?.layoutIfNeeded()
        bottomConstraint.isActive = false
        topConstraint.isActive = true

        if animated {
            // Animate down from the top
            UIView.animate(withDuration: animationDuration) {
                self.superview?.layoutIfNeeded()
                self.scrollView?.contentInset.top = self.frame.height
                self.scrollView?.contentOffset.y = -self.frame.height
            }
        } else {
            scrollView?.contentInset.top = self.frame.height
            scrollView?.contentOffset.y = -self.frame.height
        }
    }

    // Can't override scrollView delegate so have to called this method from the outside
    public func handleScrolling() {
        guard let scrollView = scrollView else { return }

        let offset = scrollView.contentInset.top + scrollView.contentOffset.y
        
        if offset > 2 * frame.height {
            isHidden = true
            return
        }

        isHidden = false
        topConstraint.constant = -offset
    }

    func remove(_ broadcast: Broadcast) {

        UIView.animate(withDuration: animationDuration, animations: {
            if self.subviews.count == 1 {
                self.layoutMargins = UIEdgeInsets(top: 0, leading: .mediumLargeSpacing, bottom: 0, trailing: .mediumLargeSpacing)
            }

            broadcast.isHidden = true
            broadcast.alpha = 0

            self.layoutIfNeeded()
            self.scrollView?.contentInset.top = self.frame.height
            self.scrollView?.contentOffset.y = -self.frame.height

        }) { (completed) in
            broadcast.removeFromSuperview()
            if self.subviews.count == 0 {
                self.removeFromSuperview()

                guard let scrollView = self.scrollView else { return }
                scrollView.addGestureRecognizer(scrollView.panGestureRecognizer)
                self.scrollView = nil
            }
        }
    }
}

// MARK: - BroadcastDelegate

extension BroadcastContainer: BroadcastDelegate {
    public func broadcast(_ broadcast: Broadcast, didTapURL url: URL) {
        let broadcastIndex = arrangedSubviews.index(of: broadcast) ?? 0
        delegate?.broadcastContainer(self, didTapURL: url, inBroadcastAtIndex: broadcastIndex)
    }

    public func broadcastDismissButtonTapped(_ broadcast: Broadcast) {
        remove(broadcast)
    }
}
