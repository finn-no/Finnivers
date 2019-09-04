//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

import UIKit

protocol AdsGridViewLayoutDelegate: AnyObject {
    func adsGridViewLayout(_ adsGridViewLayout: AdsGridViewLayout, itemIsVipAtIndexPath indexPath: IndexPath, inCollectionView collectionView: UICollectionView) -> Bool
    func adsGridViewLayout(_ adsGridViewLayout: AdsGridViewLayout, imageHeightRatioForItemAtIndexPath indexPath: IndexPath, inCollectionView collectionView: UICollectionView) -> CGFloat
    func adsGridViewLayout(_ adsGridViewLayout: AdsGridViewLayout, itemNonImageHeightForItemAtIndexPath indexPath: IndexPath, inCollectionView collectionView: UICollectionView) -> CGFloat
    func adsGridViewLayout(_ adsGridViewLayout: AdsGridViewLayout, heightForHeaderViewInCollectionView collectionView: UICollectionView) -> CGFloat?
}

class AdsGridViewLayout: UICollectionViewLayout {
    private let delegate: AdsGridViewLayoutDelegate
    private var itemAttributes = [UICollectionViewLayoutAttributes]()

    private var configuration: AdsGridViewLayoutConfiguration {
        guard let collectionView = collectionView else {
            fatalError("Layout unusable without collection view!")
        }

        return AdsGridViewLayoutConfiguration(width: collectionView.frame.size.width)
    }

    init(delegate: AdsGridViewLayoutDelegate) {
        self.delegate = delegate
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var itemWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 50.0
        }

        let columnPadding = configuration.columnSpacing * CGFloat(configuration.numberOfColumns - 1)
        let sidePadding = configuration.sidePadding * 2

        let totalPadding = columnPadding + sidePadding
        let columnsWidth = collectionView.frame.size.width - totalPadding

        let columnWidth = columnsWidth / CGFloat(configuration.numberOfColumns)

        return columnWidth
    }

    private var numberOfItems: Int {
        return collectionView?.numberOfItems(inSection: 0) ?? 0
    }

    private func maxY(forItemAttributes attributes: [UICollectionViewLayoutAttributes]) -> CGFloat {
        var maxY: CGFloat = 0.0

        attributes.forEach { attribute in
            let attributeMaxY = attribute.frame.origin.y + attribute.frame.size.height

            if attributeMaxY > maxY {
                maxY = attributeMaxY
            }
        }

        return maxY
    }

    private func indexOfLowestValue(in columns: [Int]) -> Int {
        let shortestColumnIndex = columns.firstIndex(of: columns.min() ?? 0) ?? 0
        return shortestColumnIndex
    }

    private func xOffsetForItemInColumn(itemWidth: CGFloat, columnIndex: Int) -> CGFloat {
        return (configuration.columnSpacing * CGFloat(columnIndex)) + (itemWidth * CGFloat(columnIndex)) + configuration.sidePadding
    }

    // MARK: - UICollectionViewLayout (Overrides)

    override func prepare() {
        super.prepare()

        itemAttributes = [UICollectionViewLayoutAttributes]()

        guard let collectionView = collectionView else {
            return
        }

        let columnsRange = 0 ..< configuration.numberOfColumns

        var columns = columnsRange.map { _ in 0 }
        var attributesCollection = [UICollectionViewLayoutAttributes]()
        var yOffset = configuration.topOffset

        if let height = delegate.adsGridViewLayout(self, heightForHeaderViewInCollectionView: collectionView) {
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
            attributes.frame = CGRect(x: 0, y: 0, width: collectionView.frame.size.width, height: height)
            attributesCollection.append(attributes)

            yOffset += height
        }

        var previousItemWasVIP = false
        for index in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: index, section: 0)
            let isVIP = delegate.adsGridViewLayout(self, itemIsVipAtIndexPath: indexPath, inCollectionView: collectionView)

            if isVIP {
                let imageHeightRatio = delegate.adsGridViewLayout(self, imageHeightRatioForItemAtIndexPath: indexPath, inCollectionView: collectionView)
                let itemNonImageHeight = delegate.adsGridViewLayout(self, itemNonImageHeightForItemAtIndexPath: indexPath, inCollectionView: collectionView)
                let itemHeight = (imageHeightRatio * itemWidth) + itemNonImageHeight

                let topPadding = index == 0 ? yOffset : 0.0

                var previousOffset = columns[0]
                if columns[1] >= previousOffset {
                    previousOffset = columns[1]
                }
                let verticalOffset = CGFloat(previousOffset) + topPadding

                let itemWidth = collectionView.frame.size.width - configuration.sidePadding * 2

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: configuration.sidePadding, y: verticalOffset, width: itemWidth, height: itemHeight)
                attributesCollection.append(attributes)

                columns[0] = Int(verticalOffset + itemHeight + configuration.columnSpacing)
                columns[1] = Int(verticalOffset + itemHeight + configuration.columnSpacing)
                previousItemWasVIP = true
            } else {
                let columnIndex = indexOfLowestValue(in: columns)

                let xOffset = xOffsetForItemInColumn(itemWidth: itemWidth, columnIndex: columnIndex)
                var topPadding: CGFloat = 0.0
                if previousItemWasVIP {
                    topPadding = 0
                    previousItemWasVIP = false
                } else if configuration.numberOfColumns > index {
                    topPadding = yOffset
                } else {
                    topPadding = 0
                }
                let verticalOffset = CGFloat(columns[columnIndex]) + topPadding

                let imageHeightRatio = delegate.adsGridViewLayout(self, imageHeightRatioForItemAtIndexPath: indexPath, inCollectionView: collectionView)
                let itemNonImageHeight = delegate.adsGridViewLayout(self, itemNonImageHeightForItemAtIndexPath: indexPath, inCollectionView: collectionView)

                let itemHeight = (imageHeightRatio * itemWidth) + itemNonImageHeight

                columns[columnIndex] = Int(verticalOffset + itemHeight + configuration.columnSpacing)

                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = CGRect(x: xOffset, y: verticalOffset, width: itemWidth, height: itemHeight)
                attributesCollection.append(attributes)
            }
        }

        itemAttributes.append(contentsOf: attributesCollection)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return itemAttributes.filter { itemAttribute in
            return itemAttribute.frame.intersects(rect)
        }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return itemAttributes[indexPath.row]
    }

    override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else {
            return .zero
        }

        guard collectionView.numberOfItems(inSection: 0) > 0 else {
            if let height = delegate.adsGridViewLayout(self, heightForHeaderViewInCollectionView: collectionView) {
                return CGSize(width: collectionView.frame.size.width, height: height)
            } else {
                return collectionView.bounds.size
            }
        }

        var size = collectionView.bounds.size
        size.height = maxY(forItemAttributes: itemAttributes)

        return size
    }
}
