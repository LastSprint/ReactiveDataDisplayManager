//
//  MockTableHeaderGenerator.swift
//  ReactiveDataDisplayManagerTests
//
//  Created by Anton Eysner on 08.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

@testable import ReactiveDataDisplayManager

class MockTableHeaderGenerator: TableHeaderGenerator {

    override func generate() -> UIView {
        return UIView()
    }

    override func height(_ tableView: UITableView, forSection section: Int) -> CGFloat {
        return 1
    }

}
