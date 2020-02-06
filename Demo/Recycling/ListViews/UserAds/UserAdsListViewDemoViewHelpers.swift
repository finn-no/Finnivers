//
//  Copyright © 2019 FINN AS. All rights reserved.
//

import FinniversKit

public struct UserAdHeaderCell: UserAdsListHeaderViewModel, Hashable {
    public let title: String
    public let buttonTitle: String

    public var accessibilityLabel: String {
        var message = title
        message += ". " + buttonTitle
        return message
    }

    public init(title: String = "", buttonTitle: String = "") {
        self.title = title
        self.buttonTitle = buttonTitle
    }
}

public struct UserAdCellViewModel: UserAdTableViewCellViewModel {
    public let titleText: String
    public let subtitleText: String?
    public let detailText: String?
    public let imagePath: String?
    public let ribbon: UserAdTableViewCellRibbonModel
}

public struct UserAdCell: UserAdsListViewModel {
    public let imagePath: String?
    public let imageSize: CGSize
    public let title: String
    public let price: String?
    public let detail: String
    public let status: String
    public let actionViewModel: UserAdsListActionViewModel?
    public let ratingViewModel: UserAdsListRatingViewModel?

    public var accessibilityLabel: String {
        let message = [title, (price ?? ""), detail, status].joined(separator: ". ")
        return message
    }

    public init(imagePath: String? = nil, imageSize: CGSize = CGSize(width: 0, height: 0),
                title: String = "", price: String? = nil, detail: String = "", status: String = "", actionViewModel: UserAdsListActionViewModel? = nil, ratingViewModel: UserAdsListRatingViewModel? = nil) {
        self.imagePath = imagePath
        self.imageSize = imageSize
        self.title = title
        self.price = price
        self.detail = detail
        self.status = status
        self.actionViewModel = actionViewModel
        self.ratingViewModel = ratingViewModel
    }
}

public struct UserAdCellAction: UserAdsListActionViewModel {
    public let title: String?
    public let description: String
    public let buttonTitle: String
    public let cancelButtonTitle: String?
}

public struct UserAdCellRatingAction: UserAdsListRatingViewModel {
    public var title: String
    public var feedbackText: String
}

public struct UserAdsFactory {
    private struct ImageSource {
        let path: String
        let size: CGSize
    }

    public static func createSectionedAds() -> [(header: UserAdHeaderCell, ads: [UserAdCell])] {
        let newAd = createNewAd()
        let emphasizedAds = createEmphasizedAds()
        let ongoingAds = createOngoingAds()
        let activeAds = createActiveAds()
        let inactiveAds = createInactiveAds()
        let seeAllAds = createSeeAllAds()
        return [newAd, emphasizedAds, ongoingAds, activeAds, inactiveAds, seeAllAds]
    }

    public static func createAds() -> [UserAdTableViewCellViewModel] {
        titles.enumerated().map {
            UserAdCellViewModel(
                titleText: $1,
                subtitleText: "Torget",
                detailText: details[$0],
                imagePath: imageSources[$0].path,
                ribbon: ribbons[$0]
            )
        }
    }

    private static func createNewAd() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        let header = UserAdHeaderCell()
        let ads: [UserAdCell] =  [UserAdCell(title: "Lag ny annonse")]
        return (header: header, ads: ads)
    }

    private static func createEmphasizedAds() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        let imageSource = imageSources[0]
        let action = UserAdCellAction(title: "Her går det unna!", description: "Nå er det mange som selger Rancho Cuccamonga! For 89 kr kan du løfte annonsen din øverst i resultatlista, akkurat som da den var ny", buttonTitle: "Legg annonsen min øverst", cancelButtonTitle: "Nei takk")
        let rating = UserAdCellRatingAction(title: "Hva synes du om å få tips om produktkjøp til dine annonser på denne måten?", feedbackText: "Takk for tilbakemeldingen")
        let adCell = UserAdCell(imagePath: imageSource.path, imageSize: imageSource.size, title: "Rancho Cuccamonga", price: nil, detail: "Schmorget - Huh?!", status: "active", actionViewModel: action, ratingViewModel: rating)
        let header = UserAdHeaderCell()
        return (header: header, ads: [adCell])
    }

    private static func createOngoingAds() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        var ongoingAds = [UserAdCell]()
        for index in 0 ... 1 {
            let imageSource = imageSources[index]
            let title = titles[index]
            let price = prices[index]
            let detail = details[index]
            let status = statuses[index]
            ongoingAds.append(UserAdCell(imagePath: imageSource.path, imageSize: imageSource.size,
                                         title: title, price: price, detail: detail, status: status))
        }

        let header = UserAdHeaderCell(title: "PÅBEGYNTE ANNONSER (\(ongoingAds.count))", buttonTitle: "Vis alle")
        return (header: header, ads: ongoingAds)
    }

    private static func createActiveAds() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        var activeAds = [UserAdCell]()
        for index in 2 ... 2 {
            let imageSource = imageSources[index]
            let title = titles[index]
            let price = prices[index]
            let detail = details[index]
            let status = statuses[index]
            activeAds.append(UserAdCell(imagePath: imageSource.path, imageSize: imageSource.size, title: title,
                                        price: price, detail: detail, status: status))
        }

        let header = UserAdHeaderCell(title: "AKTIVE ANNONSER (\(activeAds.count))", buttonTitle: "Vis alle")
        return (header: header, ads: activeAds)
    }

    private static func createInactiveAds() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        var inactiveAds = [UserAdCell]()
        for index in 3 ... 4 {
            let imageSource = imageSources[index]
            let title = titles[index]
            let price = prices[index]
            let detail = details[index]
            let status = statuses[index]
            inactiveAds.append(UserAdCell(imagePath: imageSource.path, imageSize: imageSource.size, title: title,
                                          price: price, detail: detail, status: status))
        }

        let header = UserAdHeaderCell(title: "INAKTIVE ANNONSER (\(inactiveAds.count))", buttonTitle: "Vis alle")
        return (header: header, ads: inactiveAds)
    }

    private static func createSeeAllAds() -> (header: UserAdHeaderCell, ads: [UserAdCell]) {
        let header = UserAdHeaderCell()
        let ads: [UserAdCell] =  [UserAdCell(title: "Se alle annonsene mine")]
        return (header: header, ads: ads)
    }

    private static var imageSources: [ImageSource] {
        return [
            ImageSource(path: "https://i.pinimg.com/736x/73/de/32/73de32f9e5a0db66ec7805bb7cb3f807--navy-blue-houses-blue-and-white-houses-exterior.jpg", size: CGSize(width: 450, height: 354)),
            ImageSource(path: "https://upload.wikimedia.org/wikipedia/commons/1/15/Red_Apple.jpg", size: CGSize(width: 992, height: 546)),
            ImageSource(path: "https://i.pinimg.com/736x/73/de/32/73de32f9e5a0db66ec7805bb7cb3f807--navy-blue-houses-blue-and-white-houses-exterior.jpg", size: CGSize(width: 450, height: 354)),
            ImageSource(path: "http://i3.au.reastatic.net/home-ideas/raw/a96671bab306bcb39783bc703ac67f0278ffd7de0854d04b7449b2c3ae7f7659/facades.jpg", size: CGSize(width: 800, height: 600)),
            ImageSource(path: "http://failing.example.com", size: CGSize(width: 992, height: 546)),
            ImageSource(path: "https://i.pinimg.com/736x/11/f0/79/11f079c03af31321fd5029f72a4586b1--exterior-houses-house-exteriors.jpg", size: CGSize(width: 736, height: 566)),
        ]
    }

    private static var titles: [String] {
        return [
            "George Condo - My twisted fantasy is an incredibly sick fantasy",
            "Macbook Air",
            "Fender Jaguar Blå",
            "Nixon Kamera",
            "Retro sko",
            "Dette er en halvlang tittel med noe ekstra informasjon",
        ]
    }

    private static var prices: [String?] {
        return [
            "1 200 00 000 000 000 000 000 000,-",
            "1200 Kroner",
            "58 000 000 000 000,-",
            nil,
            "Gis bort",
            nil,
        ]
    }

    private static var details: [String] {
        return [
            "45 dager igjen",
            "12 dager igjen",
            "Sist redigert: 09.10.2019",
            "Sist redigert: 12.12.2015",
            "Sist redigert: 17.01.2019",
            "Sist redigert: 28.01.2019",
        ]
    }

    private static var statuses: [String] {
        return [
            "Påbegynt",
            "Venter på betaling",
            "Aktiv",
            "Deaktivert",
            "Solgt",
            "",
        ]
    }

    private static var ribbons: [UserAdTableViewCellRibbonModel] {
        return [
            UserAdTableViewCellRibbonModel(title: "Aktiv", style: .success),
            UserAdTableViewCellRibbonModel(title: "Aktiv", style: .success),
            UserAdTableViewCellRibbonModel(title: "Solgt", style: .disabled),
            UserAdTableViewCellRibbonModel(title: "Påbegynt", style: .warning),
            UserAdTableViewCellRibbonModel(title: "Inaktiv", style: .disabled),
            UserAdTableViewCellRibbonModel(title: "Inaktiv", style: .disabled),
        ]
    }
}
