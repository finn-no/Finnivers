//
//  Copyright © FINN.no AS, Inc. All rights reserved.
//

// Generated by generate_image_assets_symbols as a "Run Script" Build Phase
// WARNING: This file is autogenerated, do not modify by hand

import UIKit

private class BundleHelper {
}

extension UIImage {
    convenience init(named imageAsset: ImageAsset) {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: BundleHelper.self)
        #endif
        self.init(named: imageAsset.rawValue, in: bundle, compatibleWith: nil)!
    }

    @objc class func assetNamed(_ assetName: String) -> UIImage {
        #if SWIFT_PACKAGE
        let bundle = Bundle.module
        #else
        let bundle = Bundle(for: BundleHelper.self)
        #endif
        return UIImage(named: assetName, in: bundle, compatibleWith: nil)!
    }
}

//swiftlint:disable superfluous_disable_command
//swiftlint:disable type_body_length
enum ImageAsset: String {
    case adsenseDemo
    case arrowCounterClockwise
    case avatar
    case betaImageSearch
    case blinkRocketMini
    case boat
    case boatNew
    case car
    case carNew
    case checkCircleFilled
    case classifieds
    case classifiedsNew
    case consentTransparencyImage
    case cross
    case displayTypeGrid
    case displayTypeList
    case dissatisfiedFace
    case distance
    case emptyMoon
    case emptyStateSaveSearch
    case favoriteActive
    case favorites
    case favouriteAdded
    case filledMoon
    case filter
    case finnLogoSimple
    case gift
    case heartEmpty
    case home
    case iconRealestateApartments
    case iconRealestateBedrooms
    case iconRealestateOwner
    case iconRealestatePrice
    case jobs
    case jobsNew
    case leiebilNew
    case magnifyingGlass
    case mc
    case mcNew
    case messages
    case mittanbud
    case mittanbudNew
    case moteplassen
    case moteplassenNew
    case nettbilNew
    case notifications
    case notificationsBell
    case npCompare
    case npDrive
    case npHouseWeather
    case npPublicTransport
    case npRecommended
    case npSafeNeighborhood
    case npSchool
    case npStopwatch
    case npStore
    case npWalk
    case nyhetsbrevFraFinn
    case okonomi
    case okonomiNew
    case pin
    case playVideo
    case plus
    case primingFavoritesComments
    case primingFavoritesSearch
    case primingFavoritesSharing
    case profile
    case ratings
    case realestate
    case realestateNew
    case remove
    case removeFilterTag
    case savedSearches
    case search
    case service
    case shopping
    case sold
    case travel
    case travelNew
    case vehicles
    case virtualViewing
    case warranty
    case webview
    case wrench
    case yourads

    static var imageNames: [ImageAsset] {
        return [
            .adsenseDemo,
            .arrowCounterClockwise,
            .avatar,
            .betaImageSearch,
            .blinkRocketMini,
            .boat,
            .boatNew,
            .car,
            .carNew,
            .checkCircleFilled,
            .classifieds,
            .classifiedsNew,
            .consentTransparencyImage,
            .cross,
            .displayTypeGrid,
            .displayTypeList,
            .dissatisfiedFace,
            .distance,
            .emptyMoon,
            .emptyStateSaveSearch,
            .favoriteActive,
            .favorites,
            .favouriteAdded,
            .filledMoon,
            .filter,
            .finnLogoSimple,
            .gift,
            .heartEmpty,
            .home,
            .iconRealestateApartments,
            .iconRealestateBedrooms,
            .iconRealestateOwner,
            .iconRealestatePrice,
            .jobs,
            .jobsNew,
            .leiebilNew,
            .magnifyingGlass,
            .mc,
            .mcNew,
            .messages,
            .mittanbud,
            .mittanbudNew,
            .moteplassen,
            .moteplassenNew,
            .nettbilNew,
            .notifications,
            .notificationsBell,
            .npCompare,
            .npDrive,
            .npHouseWeather,
            .npPublicTransport,
            .npRecommended,
            .npSafeNeighborhood,
            .npSchool,
            .npStopwatch,
            .npStore,
            .npWalk,
            .nyhetsbrevFraFinn,
            .okonomi,
            .okonomiNew,
            .pin,
            .playVideo,
            .plus,
            .primingFavoritesComments,
            .primingFavoritesSearch,
            .primingFavoritesSharing,
            .profile,
            .ratings,
            .realestate,
            .realestateNew,
            .remove,
            .removeFilterTag,
            .savedSearches,
            .search,
            .service,
            .shopping,
            .sold,
            .travel,
            .travelNew,
            .vehicles,
            .virtualViewing,
            .warranty,
            .webview,
            .wrench,
            .yourads,
    ]
  }
}
