//
//  Copyright © 2020 FINN.no AS. All rights reserved.
//

import FinniversKit
import FinnUI

class NotificationCenterSearchDemoView: UIView {

    private lazy var searchView: NotificationCenterSearchView = {
        let searchView = NotificationCenterSearchView(withAutoLayout: true)
        searchView.dataSource = self
        searchView.delegate = self
        searchView.remoteImageViewDataSource = self
        return searchView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(searchView)
        searchView.fillInSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NotificationCenterSearchDemoView: NotificationCenterSearchViewDelegate {
    func notificationCenterSearchView(_ view: NotificationCenterSearchView, didSelectModelAt indexPath: IndexPath) {
        print("Did select model")
        view.reloadSelectedRow()
    }

    func notificationCenterSearchViewDidSelectShowEntireSearch(_ view: NotificationCenterSearchView) {
        print("Show search")
    }

    func notificationCenterSearchView(_ view: NotificationCenterSearchView, didSelectFavoriteButton: UIButton, forNotificationAt indexPath: IndexPath) {}
}

extension NotificationCenterSearchDemoView: NotificationCenterSearchViewDataSource {
    func notificationCenterSearchView(_ view: NotificationCenterSearchView, numberOfRowsInSection section: Int) -> Int {
        15
    }

    func notificationCenterSearchView(_ view: NotificationCenterSearchView, modelForCellAt indexPath: IndexPath) -> NotificationCellModel {
        NotificationCenterItem(
            isRead: true,
            content: SavedSearchAdData(
                imagePath: "https://i.pinimg.com/originals/2d/ee/a2/2deea203ebc1da505db5676821ca88fb.jpg",
                locationText: "Lyngdal",
                title: "Opel Kadett KADETT 1.2 1200",
                priceText: "45 000 kr",
                ribbonViewModel: nil
            )
        )
    }

    func notificationCenterSearchView(_ view: NotificationCenterSearchView, timestampForCellAt indexPath: IndexPath) -> String? {
        "3 min siden"
    }

    func notificationCenterSearchView(_ view: NotificationCenterSearchView, modelForHeaderInSection section: Int) -> NotificationCenterSearchViewModel {
        NotificationCenterSearchViewModel(title: "\"Drømmebilen\"", rowCountText: "15 annonser", searchButtonTitle: "Gå til søket")
    }
}

extension NotificationCenterSearchDemoView: RemoteImageViewDataSource {
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
