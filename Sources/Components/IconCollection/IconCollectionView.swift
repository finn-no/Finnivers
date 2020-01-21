//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import UIKit

public final class IconCollectionView: UIView {
    public enum Alignment {
        case horizontal
        case vertical
    }

    // MARK: - Private properties

    private var alignment: Alignment
    private var viewModels = [IconCollectionViewModel]()

    private lazy var collectionView: UICollectionView = {
        let collectionView = CollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(IconCollectionViewCell.self)
        collectionView.backgroundColor = .bgPrimary
        collectionView.allowsSelection = false
        collectionView.isScrollEnabled = false
        collectionView.bounces = false
        collectionView.delegate = self
        collectionView.dataSource = self
        return collectionView
    }()

    private lazy var collectionViewLayout: UICollectionViewLayout = {
        let layout = IconCollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = .mediumSpacing
        layout.minimumInteritemSpacing = 0
        return layout
    }()

    // MARK: - Init

    public init(alignment: Alignment = .vertical) {
        self.alignment = alignment
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) { fatalError() }

    // MARK: - Setup

    public func configure(with viewModels: [IconCollectionViewModel]) {
        self.viewModels = viewModels
        collectionView.reloadData()
    }

    private func setup() {
        backgroundColor = .bgPrimary
        addSubview(collectionView)
        collectionView.fillInSuperview()
    }

    // MARK: - Overrides

    // This override exists because of how we calculate view sizes in our objectPage.
    // The objectPage needs to know the size of this view before it's added to the view hierarchy, aka. before
    // the collectionView itself knows it's own contentSize, so we need to calculate the total height of the view manually.
    //
    // All we're given to answer this question is the width attribute in `targetSize`.
    //
    // This implementation may not work for any place other than the objectPage, because:
    //   - it assumes `targetSize` contains an accurate targetWidth for this view.
    //   - it ignores any potential targetHeight.
    //   - it ignores both horizontal and vertical fitting priority.
    public override func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
        let targetWidth = targetSize.width
        let cellWidths = viewModels.map { cellWidth(forWidth: targetWidth, viewModel: $0) }

        let cellSizes = zip(viewModels, cellWidths).map { (viewModel, width) -> CGSize in
            let height = IconCollectionViewCell.height(for: viewModel, withWidth: width)
            return CGSize(width: width, height: height)
        }

        guard let firstItem = cellSizes.first else { return targetSize }
        let numberOfCellsInRow = Int(floor(targetWidth / firstItem.width))
        let cellRows = cellSizes.chunked(into: numberOfCellsInRow)
        let totalHeight = cellRows.compactMap { $0.max(by: { $0.height < $1.height }) }.reduce(0, { $0 + $1.height })

        let extraSpacing: CGFloat = .mediumSpacing * CGFloat(cellRows.count)
        return CGSize(width: targetWidth, height: totalHeight + extraSpacing)
    }
}

// MARK: - UICollectionViewDataSource

extension IconCollectionView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(IconCollectionViewCell.self, for: indexPath)
        cell.configure(with: viewModels[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension IconCollectionView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let viewModel = viewModels[indexPath.item]
        let width = cellWidth(forWidth: collectionView.frame.width, viewModel: viewModel)
        let height = IconCollectionViewCell.height(for: viewModel, withWidth: width)

        return CGSize(width: width, height: height)
    }

    private func cellWidth(forWidth width: CGFloat, viewModel: IconCollectionViewModel) -> CGFloat {
        let width = UIDevice.isIPad()
            ? max(width / CGFloat(viewModels.count), viewModel.image.size.width * 2)
            : width / 2
        return width
    }
}

// MARK: - Private types

private final class CollectionView: UICollectionView {
    override var intrinsicContentSize: CGSize {
        return contentSize
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
