//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FavoriteFoldersListViewDelegate: AnyObject {
    func favoriteFoldersListView(_ view: FavoriteFoldersListView, didSelectItemAtIndex index: Int)
    func favoriteFoldersListViewDidSelectAddButton(_ view: FavoriteFoldersListView)
    func favoriteFoldersListView(_ view: FavoriteFoldersListView, didChangeSearchText searchText: String)
    func favoriteFoldersListViewDidCancelSearch(_ view: FavoriteFoldersListView)
}

public protocol FavoriteFoldersListViewDataSource: AnyObject {
    func numberOfItems(inFavoriteFoldersListView view: FavoriteFoldersListView) -> Int
    func favoriteFoldersListView(_ view: FavoriteFoldersListView, viewModelAtIndex index: Int) -> FavoriteFolderViewModel
    func favoriteFoldersListView(
        _ view: FavoriteFoldersListView,
        loadImageForModel model: RemoteImageTableViewCellViewModel,
        completion: @escaping ((UIImage?) -> Void)
    )
    func favoriteFoldersListView(
        _ view: FavoriteFoldersListView,
        cancelLoadingImageForModel model: RemoteImageTableViewCellViewModel
    )
}

public class FavoriteFoldersListView: UIView {
    private enum Section: Int, CaseIterable {
        case addButton
        case folders
    }

    public static let estimatedRowHeight: CGFloat = 64.0

    // MARK: - Public properties

    public weak var delegate: FavoriteFoldersListViewDelegate?
    public weak var dataSource: FavoriteFoldersListViewDataSource?

    // MARK: - Private properties

    private let viewModel: FavoriteFoldersListViewModel
    private var isSearchActive = false
    private let imageCache = ImageMemoryCache()

    private(set) lazy var searchBar: FavoriteFoldersSearchBar = {
        let view = FavoriteFoldersSearchBar(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .milk
        tableView.rowHeight = FavoriteFoldersListView.estimatedRowHeight
        tableView.estimatedRowHeight = FavoriteFoldersListView.estimatedRowHeight
        tableView.separatorInset = .leadingInset(frame.width)
        tableView.tableFooterView = UIView()
        tableView.contentInset.bottom = FavoriteFoldersListView.estimatedRowHeight
        tableView.register(AddFavoriteFolderViewCell.self)
        tableView.register(RemoteImageTableViewCell.self)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    private lazy var footerView: FavoriteFoldersFooterView = {
        let view = FavoriteFoldersFooterView(withAutoLayout: true)
        view.delegate = self
        return view
    }()

    private lazy var footerViewTop = footerView.topAnchor.constraint(equalTo: bottomAnchor)

    private lazy var footerHeight: CGFloat = {
        return 56 + windowSafeAreaInsets.bottom
    }()

    // MARK: - Init

    public required init(viewModel: FavoriteFoldersListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Reload

    public func reloadData() {
        tableView.reloadData()
    }

    // MARK: - Init

    private func setup() {
        searchBar.configure(withPlaceholder: viewModel.searchBarPlaceholder)
        footerView.configure(withTitle: viewModel.addFolderText)

        let barButtonAppearance = UIBarButtonItem.appearance(whenContainedInInstancesOf: [FavoriteFoldersSearchBar.self])
        barButtonAppearance.title = viewModel.cancelButtonTitle

        addSubview(tableView)
        addSubview(searchBar)
        addSubview(footerView)

        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: trailingAnchor),

            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor),

            footerViewTop,
            footerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerView.heightAnchor.constraint(equalToConstant: footerHeight)
        ])
    }
}

// MARK: - UITableViewDelegate

extension FavoriteFoldersListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .addButton:
            delegate?.favoriteFoldersListViewDidSelectAddButton(self)
        case .folders:
            delegate?.favoriteFoldersListView(self, didSelectItemAtIndex: indexPath.row)
        }
    }

    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? RemoteImageTableViewCell else {
            return
        }

        let isLastCell = indexPath.row == (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1)

        if isLastCell {
            cell.separatorInset = .leadingInset(frame.width)
        }

        cell.loadImage()
    }
}

// MARK: - UITableViewDataSource

extension FavoriteFoldersListView: UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return Section.allCases.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .addButton:
            return isSearchActive ? 0 : 1
        case .folders:
            return dataSource?.numberOfItems(inFavoriteFoldersListView: self) ?? 0
        }
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UITableViewCell() }

        switch section {
        case .addButton:
            let cell = tableView.dequeue(AddFavoriteFolderViewCell.self, for: indexPath)
            cell.configure(withTitle: viewModel.addFolderText)
            return cell
        case .folders:
            let cell = tableView.dequeue(RemoteImageTableViewCell.self, for: indexPath)

            // Show a pretty color while we load the image
            let colors: [UIColor] = [.toothPaste, .mint, .banana, .salmon]
            let color = colors[indexPath.row % 4]

            cell.loadingColor = color
            cell.dataSource = self

            if let viewModel = dataSource?.favoriteFoldersListView(self, viewModelAtIndex: indexPath.row) {
                cell.configure(with: viewModel)
            }

            return cell
        }
    }
}

// MARK: - FavoriteFoldersFooterViewDelegate

extension FavoriteFoldersListView: FavoriteFoldersFooterViewDelegate {
    func favoriteFoldersFooterViewDidSelectButton(_ view: FavoriteFoldersFooterView) {
        delegate?.favoriteFoldersListViewDidSelectAddButton(self)
    }
}

// MARK: - RemoteImageTableViewCellDataSource

extension FavoriteFoldersListView: RemoteImageTableViewCellDataSource {
    public func remoteImageTableViewCell(_ cell: RemoteImageTableViewCell,
                                         cachedImageForModel model: RemoteImageTableViewCellViewModel) -> UIImage? {
        guard let imagePath = model.imagePath else {
            return nil
        }

        return imageCache.image(forKey: imagePath)
    }

    public func remoteImageTableViewCell(_ cell: RemoteImageTableViewCell,
                                         loadImageForModel model: RemoteImageTableViewCellViewModel,
                                         completion: @escaping ((UIImage?) -> Void)) {
        dataSource?.favoriteFoldersListView(self, loadImageForModel: model, completion: { [weak self] image in
            if let image = image, let imagePath = model.imagePath {
                self?.imageCache.add(image, forKey: imagePath)
            }

            completion(image)
        })
    }

    public func remoteImageTableViewCell(_ cell: RemoteImageTableViewCell, cancelLoadingImageForModel model: RemoteImageTableViewCellViewModel) {
        dataSource?.favoriteFoldersListView(self, cancelLoadingImageForModel: model)
    }
}

// MARK: - UIScrollViewDelegate

extension FavoriteFoldersListView: UIScrollViewDelegate {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.updateShadow(using: scrollView)

        guard !isSearchActive else {
            footerViewTop.constant = 0
            return
        }

        let offset = scrollView.contentOffset.y
        let minOffset = FavoriteFoldersListView.estimatedRowHeight
        let maxOffset = minOffset + footerHeight

        if offset >= minOffset && offset <= maxOffset {
            footerViewTop.constant = -offset + minOffset
        } else if offset <= footerHeight {
            footerViewTop.constant = 0
        } else if offset > maxOffset {
            footerViewTop.constant = -footerHeight
        }
    }
}

// MARK: - UISearchBarDelegate

extension FavoriteFoldersListView: UISearchBarDelegate {
    public func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        isSearchActive = true
        footerView.isHidden = true
        searchBar.setShowsCancelButton(true, animated: true)
    }

    public func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        isSearchActive = false
        footerView.isHidden = false
        searchBar.setShowsCancelButton(false, animated: true)
        delegate?.favoriteFoldersListViewDidCancelSearch(self)
    }

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.endEditing(false)
    }

    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.favoriteFoldersListView(self, didChangeSearchText: searchText)
    }
}
