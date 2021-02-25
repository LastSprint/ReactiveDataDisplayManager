//
//  MockTableCellGenerator.swift
//  ReactiveDataDisplayManagerTests
//
//  Created by Anton Eysner on 08.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

@testable import ReactiveDataDisplayManager

class MockTableCellGenerator: TableCellGenerator {

    var identifier: String {
        return String(describing: UITableViewCell.self)
    }

    func generate(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    func registerCell(in tableView: UITableView) {
        tableView.registerNib(identifier)
    }

}
