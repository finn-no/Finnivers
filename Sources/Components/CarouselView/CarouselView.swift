//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import UIKit

public typealias CarouselViewCell = UICollectionViewCell

public protocol CarouselViewDataSource: AnyObject {
    func numberOfItems(in carouselView: CarouselView) -> Int
    func carouselView(_ carouselView: CarouselView, cellForItemAt indexPath: IndexPath) -> CarouselViewCell
}

public class CarouselView: UIView {

    public weak var dataSource: CarouselViewDataSource? {
        didSet {
            collectionView.reloadData()
        }
    }

    // MARK: - Private Properties

    private var initialLayout = true

    private lazy var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        return layout
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    // MARK: - Init

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Overrides

    public override var backgroundColor: UIColor? {
        didSet {
            collectionView.backgroundColor = backgroundColor
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard initialLayout else { return }
        initialLayout = false

        collectionView.contentOffset = CGPoint(
            x: bounds.width,
            y: collectionView.contentOffset.y
        )
    }
}

public extension CarouselView {
    func register(_ cellClass: CarouselViewCell.Type) {
        collectionView.register(cellClass)
    }

    func dequeue<T>(_ cellType: T.Type, for indexPath: IndexPath) -> T where T: CarouselViewCell {
        return collectionView.dequeue(cellType, for: indexPath)
    }
}

extension CarouselView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }

        return dataSource.numberOfItems(in: self) + 2
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            preconditionFailure("Data source is not available")
        }

        return dataSource.carouselView(self, cellForItemAt: self.indexPath(forItem: indexPath.item))
    }
}

extension CarouselView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return bounds.size
    }
}

extension CarouselView: UIScrollViewDelegate {
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)

        if scrollView.isPagingEnabled {
            let targetPage = Int(targetContentOffset.pointee.x / scrollView.bounds.width)
            let deltaOffset = CGFloat(numberOfItems - 2) * scrollView.bounds.width

            if targetPage == 0 {
                targetContentOffset.pointee = CGPoint(
                    x: deltaOffset,
                    y: targetContentOffset.pointee.y
                )

                scrollView.contentOffset = CGPoint(
                    x: scrollView.contentOffset.x + deltaOffset,
                    y: scrollView.contentOffset.y
                )

            } else if targetPage == numberOfItems - 1 {
                targetContentOffset.pointee = CGPoint(
                    x: scrollView.bounds.width,
                    y: targetContentOffset.pointee.y
                )

                scrollView.contentOffset = CGPoint(
                    x: scrollView.contentOffset.x - deltaOffset,
                    y: scrollView.contentOffset.y
                )
            }
        }
    }
}

// MARK: - Private Functions

private extension CarouselView {
    func indexPath(forItem item: Int) -> IndexPath {
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        let next: Int

        switch item {
        case 0: next = numberOfItems - 3
        case numberOfItems - 1: next = 0
        default: next = item - 1
        }

        return IndexPath(
            item: next,
            section: 0
        )
    }

    func setup() {
        addSubview(collectionView)
        collectionView.fillInSuperview()
    }
}
