//
//  UITableViewSpy.swift
//  ReactiveDataDisplayManagerTests
//
//  Created by Anton Eysner on 08.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

final class UITableViewSpy: UITableView {

    var reloadDataWasCalled: Bool = false
    var registerNibWasCalled: Bool = false
    var scrollToRowWasCalled: Bool = false
    var lastReloadedRows: [IndexPath] = []
    var sectionWasReloaded: Bool = false

    override func reloadData() {
        super.reloadData()
        reloadDataWasCalled = true
    }

    override func register(_ nib: UINib?, forCellReuseIdentifier identifier: String) {
        registerNibWasCalled = true
        // don't call super to avoid UI API call
    }

    override func scrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        scrollToRowWasCalled = true
    }

    override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        lastReloadedRows = indexPaths
    }

    override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
        sectionWasReloaded = true
    }

}
