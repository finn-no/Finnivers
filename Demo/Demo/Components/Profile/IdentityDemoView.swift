//
// Copyright (c) 2019 FINN AS. All rights reserved.
//

import FinniversKit

class IdentityDemoView: UIView, Tweakable {

    // MARK: - UI properties

    private var identityViews: [(IdentityView, ViewModel)] = []

    // MARK: - Private properties

    lazy var tweakingOptions: [TweakingOption] = {
        let options = [
            TweakingOption(title: "Nil out view models", action: {
                self.identityViews.forEach { $0.0.viewModel = nil  }
            }),
            TweakingOption(title: "Assign view models", action: {
                self.identityViews.forEach { $0.0.viewModel = $0.1 }
            }),
            TweakingOption(title: "Toggle descriptions", action: {
                self.identityViews.forEach { $0.0.hideDescription.toggle() }
            }),
            TweakingOption(title: "Use profile image from memory", action: {
                self.identityViews.forEach {
                    $0.1.profileImage = UIImage(named: .ratingCat)
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "Use profile image from URL", action: {
                self.identityViews.forEach {
                    $0.1.profileImage = nil
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "DisplayMode.interactible", action: {
                self.identityViews.forEach {
                    $0.1.displayMode = .interactible
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "DisplayMode.nonInteractible", action: {
                self.identityViews.forEach {
                    $0.1.displayMode = .nonInteractible
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "DisplayMode.anonymous", action: {
                self.identityViews.forEach {
                    $0.1.displayMode = .anonymous
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "DisplayMode.offline", action: {
                self.identityViews.forEach {
                    $0.1.displayMode = .offline
                    $0.0.viewModel = $0.1
                }
            }),
            TweakingOption(title: "DisplayMode.online", action: {
                self.identityViews.forEach {
                    $0.1.displayMode = .interactible
                    $0.0.viewModel = $0.1
                }
            })
        ]
        return options
    }()

    // MARK: - Setup

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        let viewModels = [
            ViewModel(description: "Er bare på FINN når jeg ikke finner det jeg vil ha på Letgo. Så jeg er her mye.\n\n#🔥", isTappable: true, isVerified: true),
            ViewModel(description: nil, isTappable: true, isVerified: false),
            ViewModel(description: nil, isTappable: false, isVerified: true),
            ViewModel(description: "Hei sveis!", isTappable: false, isVerified: false),
            ViewModel(description: nil, isTappable: false, isVerified: true, displayMode: .offline),
        ]

        identityViews = viewModels.map { model in
            let view = IdentityView(viewModel: model)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.delegate = self
            return (view, model)
        }

        var nextAnchor: NSLayoutYAxisAnchor = topAnchor
        identityViews.forEach { (view, _) in
            addSubview(view)
            NSLayoutConstraint.activate([
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingS),
                view.topAnchor.constraint(equalTo: nextAnchor, constant: .spacingS),
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingS),
            ])

            nextAnchor = view.bottomAnchor
        }
    }
}

extension IdentityDemoView: IdentityViewDelegate {
    func identityViewWasTapped(_ identityView: IdentityView) {
        print("Identity view of '\(identityView.viewModel?.displayName ?? "<nil>")' was tapped")
    }

    public func identityView(_ identityView: IdentityView, loadImageWithUrl url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.5, execute: {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else {
                    completionHandler(nil)
                    return
                }

                let image = UIImage(data: data)
                completionHandler(image)
            }

            task.resume()
        })
    }

    public func identityViewDidTapOfflineButton() {}
}

// MARK: - View model

private class ViewModel: IdentityViewModel {
    var profileImage: UIImage?
    let profileImageUrl: URL? = URL(string: "https://images.finncdn.no/dynamic/220x220c/2019/7/profilbilde/05/8/214/710/286/8_352525950.jpg")

    let displayName: String = "Finn Nordmann"
    let subtitle: String = "Har vært på FINN siden 1952"

    let description: String?
    let isVerified: Bool
    var displayMode: IdentityView.DisplayMode

    let offlineDescription: String? = "Du må være logget inn for å se profilen"
    let offlineButtonTitle: String? = "Logg inn"

    init(description: String?, isTappable: Bool, isVerified: Bool, displayMode: IdentityView.DisplayMode = .interactible) {
        self.description = description
        self.isVerified = isVerified
        self.displayMode = displayMode
    }
}
