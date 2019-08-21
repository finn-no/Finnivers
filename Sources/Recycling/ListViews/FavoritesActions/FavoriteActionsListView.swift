//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

public protocol FavoriteActionsListViewDelegate: AnyObject {
    func favoriteActionsListView(_ view: FavoriteActionsListView, didSelectAction action: FavoriteActionsListView.Action)
}

public final class FavoriteActionsListView: UIView {
    public enum Action: Equatable, Hashable, CaseIterable {
        case edit
        case changeName
        case share
        case copyLink
        case delete
    }

    public static let estimatedRowHeight: CGFloat = 48.0

    // MARK: - Public properties

    public weak var delegate: FavoriteActionsListViewDelegate?
    public var isShared = false {
        didSet {
            toggleSharing()
        }
    }

    // MARK: - Private properties

    private let viewModel: FavoriteActionsListViewModel

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .milk
        tableView.rowHeight = FavoriteActionsListView.estimatedRowHeight
        tableView.estimatedRowHeight = FavoriteActionsListView.estimatedRowHeight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.register(FavoriteActionViewCell.self)
        tableView.register(FavoriteShareViewCell.self)
        tableView.register(FavoriteCopyLinkViewCell.self)
        return tableView
    }()

    // MARK: - Init

    public init(viewModel: FavoriteActionsListViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Data

    private func toggleSharing() {
        tableView.reloadData()
    }

    // MARK: - Setup

    private func setup() {
        addSubview(tableView)
        tableView.fillInSuperview()
    }
}

// MARK: - UITableViewDataSource

extension FavoriteActionsListView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Action.allCases.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let action = Action.allCases[indexPath.row]

        switch action {
        case .edit:
            let cell = tableView.dequeue(FavoriteActionViewCell.self, for: indexPath)
            cell.configure(withTitle: viewModel.editText, icon: .favoritesEdit)
            return cell
        case .changeName:
            let cell = tableView.dequeue(FavoriteActionViewCell.self, for: indexPath)
            cell.configure(withTitle: viewModel.changeNameText, icon: .pencilPaper)
            return cell
        case .share:
            let cell = tableView.dequeue(FavoriteShareViewCell.self, for: indexPath)
            cell.delegate = self
            cell.configure(withTitle: viewModel.shareText, switchOn: isShared)
            return cell
        case .copyLink:
            let cell = tableView.dequeue(FavoriteCopyLinkViewCell.self, for: indexPath)
            cell.delegate = self
            cell.configure(
                withButtonTitle: viewModel.copyLinkButtonTitle,
                description: viewModel.copyLinkButtonDescription
            )
            return cell
        case .delete:
            let cell = tableView.dequeue(FavoriteActionViewCell.self, for: indexPath)
            cell.configure(withTitle: viewModel.deleteText, icon: .trashcan)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension FavoriteActionsListView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let action = Action.allCases[indexPath.row]
        delegate?.favoriteActionsListView(self, didSelectAction: action)
    }
}

// MARK: - FavoriteShareViewCellDelegate

extension FavoriteActionsListView: FavoriteShareViewCellDelegate {
    func favoriteShareViewCell(_ cell: FavoriteShareViewCell, didChangeSwitchValue value: Bool) {

    }
}

// MARK: - FavoriteCopyLinkViewCellDelegate

extension FavoriteActionsListView: FavoriteCopyLinkViewCellDelegate {
    func favoriteCopyLinkViewCellDidSelectButton(_ cell: FavoriteCopyLinkViewCell) {

    }
}
