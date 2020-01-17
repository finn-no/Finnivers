//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import FinniversKit

private struct NotificationModel: NotificationCenterCellModel {
    let pushNotificationDetails: PushNotificationDetails?
    let imagePath: String?
    let title: String = "Sofa"
    var read: Bool
    let ribbonViewModel: RibbonViewModel?
}

private struct Section {
    let title: String
    var items: [NotificationModel]
}

class NotificationCenterDemoView: UIView {

    private var data = [
        Section(title: "I dag", items: [
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "https://jwproperty.com/files/wp-content/uploads/2015/01/Smart_House-Valley_Hua_Hin0131.jpg",
                read: false,
                ribbonViewModel: RibbonViewModel(title: "Solgt", style: .warning)),
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "http://i3.au.reastatic.net/home-ideas/raw/a96671bab306bcb39783bc703ac67f0278ffd7de0854d04b7449b2c3ae7f7659/facades.jpg",
                read: false,
                ribbonViewModel: nil),
        ]),
        Section(title: "Tidligere", items: [
            NotificationModel(
                pushNotificationDetails: .priceChange(text: "Din favoritt er satt ned med", value: "80 kr"),
                imagePath: nil,
                read: true,
                ribbonViewModel: RibbonViewModel(title: "Ny pris", style: .success)),
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "http://jonvilma.com/images/house-6.jpg",
                read: false,
                ribbonViewModel: RibbonViewModel(title: "Inaktiv", style: .disabled)),
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "https://i.pinimg.com/736x/11/f0/79/11f079c03af31321fd5029f72a4586b1--exterior-houses-house-exteriors.jpg",
                read: true,
                ribbonViewModel: nil),
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "https://i.pinimg.com/736x/bf/6d/73/bf6d73ab0234f3ba1a615b22d2dc7e74--home-exterior-design-contemporary-houses.jpg",
                read: true,
                ribbonViewModel: nil),
            NotificationModel(
                pushNotificationDetails: .savedSearch(text: "Nytt treff i", title: "Husstander"),
                imagePath: "https://www.tumbleweedhouses.com/wp-content/uploads/tumbleweed-tiny-house-cypress-black-roof-hp.jpg",
                read: true,
                ribbonViewModel: nil)
        ])
    ]

    private lazy var notificationCenterView: NotificationCenterView = {
        let view = NotificationCenterView(withAutoLayout: true)
        view.delegate = self
        view.dataSource = self
        view.imageViewDataSource = self
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(notificationCenterView)
        notificationCenterView.fillInSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationCenterDemoView: NotificationCenterViewDataSource {
    func numberOfSections(in view: NotificationCenterView) -> Int {
        data.count
    }

    func notificationCenterView(_ view: NotificationCenterView, numberOfRowsIn section: Int) -> Int {
        data[section].items.count
    }

    func notificationCenterView(_ view: NotificationCenterView, modelForRowAt indexPath: IndexPath) -> NotificationCenterCellModel {
        data[indexPath.section].items[indexPath.row]
    }
}

extension NotificationCenterDemoView: NotificationCenterViewDelegate {
    func notificationCenterView(_ view: NotificationCenterView, didSelectModelAt indexPath: IndexPath) {
        data[indexPath.section].items[indexPath.row].read = true
        notificationCenterView.reloadRows(at: [indexPath])
    }

    func notificationCenterView(_ view: NotificationCenterView, didSelectSavedSearchAt indexPath: IndexPath) {
        print("Did select saved search at: \(indexPath)")
    }

    func notificationCenterView(_ view: NotificationCenterView, titleForSection section: Int) -> String {
        data[section].title
    }

    func notificationCenterView(_ view: NotificationCenterView, timestampForModelAt indexPath: IndexPath) -> String? {
        "15 minutter siden"
    }

    func notificationCenterView(_ view: NotificationCenterView, didPullToRefreshWith refreshControl: UIRefreshControl) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            view.reloadData()
            refreshControl.endRefreshing()
        }
    }
}

extension NotificationCenterDemoView: RemoteImageViewDataSource {
    func remoteImageView(_ view: RemoteImageView, cachedImageWithPath imagePath: String, imageWidth: CGFloat) -> UIImage? {
        nil
    }

    func remoteImageView(_ view: RemoteImageView, loadImageWithPath imagePath: String, imageWidth: CGFloat, completion: @escaping ((UIImage?) -> Void)) {
        guard let url = URL(string: imagePath) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            usleep(50_000)
            DispatchQueue.main.async {
                if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    completion(nil)
                }
            }
        }

        task.resume()
    }

    func remoteImageView(_ view: RemoteImageView, cancelLoadingImageWithPath imagePath: String, imageWidth: CGFloat) {

    }
}