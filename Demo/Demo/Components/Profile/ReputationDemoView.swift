//
// Copyright (c) 2019 FINN AS. All rights reserved.
//

import FinniversKit

class ReputationDemoView: UIView, Tweakable {

    // MARK: - Private properties

    lazy var tweakingOptions: [TweakingOption] = {
        let options = [
            TweakingOption(title: "Nil out view models", action: {
                self.reputationViews.forEach { $0.0.viewModel = nil }
            }),
            TweakingOption(title: "Assign view models", action: {
                self.reputationViews.forEach { $0.0.viewModel = $0.1 }
            })
        ]
        return options
    }()

    private var reputationViews: [(ReputationView, ReputationViewModel)] = []

    // MARK: - Setup

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    private func setup() {
        let views = [
            headerLabel(withText: "Compact"),
            summaryView(breakdownMode: .compact),
            headerLabel(withText: "Collapsed by Default"),
            summaryView(breakdownMode: .collapsedByDefault),
            headerLabel(withText: "Always Expanded"),
            summaryView(breakdownMode: .alwaysExpanded),
            headerLabel(withText: "Legacy Reviews"),
            legacySummaryView(breakdownMode: .alwaysExpanded)
        ]

        var anchor = topAnchor
        views.forEach {
            addView($0, below: anchor)
            anchor = $0.bottomAnchor
        }
    }

    private func summaryView(breakdownMode: ReputationBreakdownMode) -> ReputationView {
        let viewModel = ViewModel(breakdownMode: breakdownMode)
        let view = ReputationView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        reputationViews += [(view, viewModel)]
        return view
    }

    private func legacySummaryView(breakdownMode: ReputationBreakdownMode) -> ReputationView {
        let breakdownModel = BreakdownModel(category: .legacyGood, title: "Gode tilbakemeldinger")
        let viewModel = ViewModel(categoryBreakdowns: [breakdownModel], breakdownMode: breakdownMode)
        let view = ReputationView(viewModel: viewModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        reputationViews += [(view, viewModel)]
        return view
    }

    private func headerLabel(withText text: String) -> Label {
        let label = Label(style: .title3)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }

    private func addView(_ view: UIView, below anchor: NSLayoutYAxisAnchor) {
        addSubview(view)

        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: .spacingS),
            view.topAnchor.constraint(equalTo: anchor, constant: .spacingS),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -.spacingS)
        ])
    }
}

private struct ViewModel: ReputationViewModel {
    let title: String = "Veldig bra"
    let subtitle: String = "22 vurderinger"
    let score: Float = 0.843419429

    let categoryBreakdowns: [ReputationBreakdownModel]
    let breakdownMode: ReputationBreakdownMode

    init(breakdownMode: ReputationBreakdownMode) {
        self.breakdownMode = breakdownMode

        self.categoryBreakdowns = [
            BreakdownModel(category: .communication, title: "Veldig bra kommunikasjon"),
            BreakdownModel(category: .transaction, title: "Problemfri overlevering"),
            BreakdownModel(category: .description, title: "Nøyaktig beskrivelse"),
            BreakdownModel(category: .payment, title: "Problemfri betaling")
        ]
    }

    init(categoryBreakdowns: [ReputationBreakdownModel], breakdownMode: ReputationBreakdownMode) {
        self.categoryBreakdowns = categoryBreakdowns
        self.breakdownMode = breakdownMode
    }
}

private struct BreakdownModel: ReputationBreakdownModel {
    let category: ReputationBreakdownCategory
    let title: String
}
