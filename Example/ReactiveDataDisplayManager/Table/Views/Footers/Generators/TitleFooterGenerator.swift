//
//  TitleFooterGenerator.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Никита Коробейников on 18.06.2021.
//

import ReactiveDataDisplayManager
import UIKit

final class TitleFooterGenerator: TableHeaderGenerator {

    // MARK: - Constants

    private enum Constants {
        static let defaultHeight: CGFloat = 24
    }

    // MARK: - Private Property

    private let model: String
    private lazy var view = FooterView().fromNib()

    // MARK: - Initialization

    init(model: String) {
        self.model = model
    }

    // MARK: - TableHeaderGenerator

    override func generate() -> UIView {
        guard let view = view else { return UIView() }
        view.configure(with: model)
        return view
    }

    override func height(_ tableView: UITableView, forSection section: Int) -> CGFloat {
        view?.frame.height ?? Constants.defaultHeight
    }

}

// MARK: - Diffable

extension TitleFooterGenerator: DiffableItemSource {

    var item: DiffableItem {
        DiffableItem(id: uuid, state: .init(model))
    }

}
