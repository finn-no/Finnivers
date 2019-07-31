//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FavoriteAdsListViewDelegate: AnyObject {
    func favoriteAdsListView(_ view: FavoriteAdsListView, didSelectItemAtIndex index: Int)
    func favoriteAdsListView(_ view: FavoriteAdsListView, didSelectMoreButtonForItemAtIndex index: Int)
}

public protocol FavoriteAdsListViewDataSource: AnyObject {
    func numberOfItems(inFavoriteAdsListView view: FavoriteAdsListView) -> Int
    func favoriteAdsListView(_ view: FavoriteAdsListView, viewModelAtIndex index: Int) -> FavoriteAdViewModel
    func favoriteAdsListView(
        _ view: FavoriteAdsListView,
        loadImageWithPath imagePath: String,
        imageWidth: CGFloat,
        completion: @escaping ((UIImage?) -> Void)
    )
    func favoriteAdsListView(
        _ view: FavoriteAdsListView,
        cancelLoadingImageWithPath imagePath: String,
        imageWidth: CGFloat
    )
}

public class FavoriteAdsListView: UIView {

    // MARK: - Public properties

    public weak var delegate: FavoriteAdsListViewDelegate?
    public weak var dataSource: FavoriteAdsListViewDataSource?

    // MARK: - Private properties

    private let imageCache = ImageMemoryCache()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(withAutoLayout: true)
        tableView.register(FavoriteAdTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = .leadingInset(frame.width)
        return tableView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setup() {
        addSubview(tableView)
        tableView.fillInSuperview()
    }
}

// MARK: - UITableViewDelegate

extension FavoriteAdsListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isLastCell = indexPath.row + 1 == dataSource?.numberOfItems(inFavoriteAdsListView: self)

        if isLastCell {
            cell.separatorInset = .leadingInset(frame.width)
        }

        if let cell = cell as? FavoriteAdTableViewCell {
            cell.loadImage()
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FavoriteAdsListView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.numberOfItems(inFavoriteAdsListView: self) ?? 0
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FavoriteAdTableViewCell.self, for: indexPath)
        cell.remoteImageViewDataSource = self
        cell.delegate = self
        if let viewModel = dataSource?.favoriteAdsListView(self, viewModelAtIndex: indexPath.row) {
            cell.configure(with: viewModel)
        }
        return cell
    }
}

// MARK: - FavoriteAdTableViewCellDelegate

extension FavoriteAdsListView: FavoriteAdTableViewCellDelegate {
    public func favoriteAdTableViewCellDidSelectMoreButton(_ cell: FavoriteAdTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        delegate?.favoriteAdsListView(self, didSelectMoreButtonForItemAtIndex: indexPath.row)
    }
}

// MARK: - RemoteImageViewDataSource

extension FavoriteAdsListView: RemoteImageViewDataSource {
    public func remoteImageView(_ view: RemoteImageView, cachedImageWithPath imagePath: String, imageWidth: CGFloat) -> UIImage? {
        return imageCache.image(forKey: imagePath)
    }

    public func remoteImageView(_ view: RemoteImageView, loadImageWithPath imagePath: String, imageWidth: CGFloat, completion: @escaping ((UIImage?) -> Void)) {
        dataSource?.favoriteAdsListView(self, loadImageWithPath: imagePath, imageWidth: imageWidth, completion: { [weak self] image in
            if let image = image {
                self?.imageCache.add(image, forKey: imagePath)
            }

            completion(image)
        })
    }

    public func remoteImageView(_ view: RemoteImageView, cancelLoadingImageWithPath imagePath: String, imageWidth: CGFloat) {
        dataSource?.favoriteAdsListView(self, cancelLoadingImageWithPath: imagePath, imageWidth: imageWidth)
    }
}
