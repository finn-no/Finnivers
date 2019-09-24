//
//  Copyright © FINN.no AS. All rights reserved.
//

import FinniversKit

public class AdManagementDemoView: UIView {
    private let estimatedRowHeight: CGFloat = 200

    private lazy var tableView: UITableView = {
        let tableView = UITableView(withAutoLayout: true)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UserAdManagementStatisticsCell.self)
        tableView.register(UserAdManagementStatisticsEmptyViewCell.self)
        tableView.register(UserAdManagementButtonAndInformationCell.self)
        tableView.register(UserAdManagementUserActionCell.self)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .bgSecondary
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()

    private var actionCellModels: [[AdManagementActionCellModel]] = [
        [
            AdManagementActionCellModel(actionType: .delete, title: "Slett annonsen"),
            AdManagementActionCellModel(actionType: .stop, title: "Skjul annonsen midlertidig", description: "Annonsen blir skjult fra FINNs søkeresultater")
        ],
        [
            AdManagementActionCellModel(actionType: .edit, title: "Rediger annonsen", description: "Sist redigert 13.12.2018"),
            AdManagementActionCellModel(actionType: .republish, title: "Legg ut annonsen på nytt")
        ],
        [
            AdManagementActionCellModel(actionType: .dispose, title: "Marker annonsen som solgt"),
            AdManagementActionCellModel(actionType: .externalFallback, title: "Eierskifteforsikring", description: "Se hvilke tilbud våre samarbeidspartnere kan by på")
        ],
        [
            AdManagementActionCellModel(actionType: .start, title: "Vis annonsen i søkeresultater"),
            AdManagementActionCellModel(actionType: .undispose, title: "Fjern solgtmarkering")
        ]
    ]

    private var statisticsCellModels: [StatisticsItemModel] = [
        StatisticsItemModel(type: .seen, value: 968, text: "har sett annonsen"),
        StatisticsItemModel(type: .favourited, value: 16, text: "har lagret annonsen"),
        StatisticsItemModel(type: .email, value: 1337, text: "har fått e-post om annonsen")
    ]

    private var statisticsEmptyViewCellModel: StatisticsItemEmptyViewModel = {
        return StatisticsItemEmptyViewModel(title: "Følg med på effekten",
                                            description: "Etter at du har publisert annonsen din kan du se statistikk for hvor mange som har sett annonsen din, favorisert den og som har fått tips om den.")
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public override func didMoveToSuperview() {
        tableView.reloadData()
    }

    public required init?(coder aDecoder: NSCoder) { fatalError() }

    private func setup() {
        addSubview(tableView)
        tableView.fillInSuperview()
    }
}

extension AdManagementDemoView: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : actionCellModels[section - 1].count
    }

    public func numberOfSections(in tableView: UITableView) -> Int {
        return actionCellModels.count + 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 && statisticsCellModels.isEmpty == true {
                let cell = tableView.dequeue(UserAdManagementStatisticsEmptyViewCell.self, for: indexPath)
                cell.itemModel = statisticsEmptyViewCellModel
                return cell
            }
            if indexPath.row == 0 {
                let cell = tableView.dequeue(UserAdManagementStatisticsCell.self, for: indexPath)
                cell.itemModels = statisticsCellModels
                return cell
            } else {
                let cell = tableView.dequeue(UserAdManagementButtonAndInformationCell.self, for: indexPath)
                cell.informationText = "Du kan øke synligheten av annonsen din ytterligere ved å oppgradere den."
                cell.buttonText = "Kjøp mer synlighet"
                return cell
            }
        } else {
            let cell = tableView.dequeue(UserAdManagementUserActionCell.self, for: indexPath)
            cell.setupWithModel(actionCellModels[indexPath.section - 1][indexPath.row])
            cell.showSeparator(indexPath.row != 0)
            return cell
        }
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        return view
    }
}

extension AdManagementDemoView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 16
    }
}
