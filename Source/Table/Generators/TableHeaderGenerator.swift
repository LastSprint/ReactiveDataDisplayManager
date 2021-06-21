//
//  TableHEaderGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

open class TableHeaderGenerator: ViewGenerator {

    public let uuid = UUID().uuidString

    public init() { }

    open func generate() -> UIView {
        preconditionFailure("\(#function) must be overriden in child")
    }

    open func height(_ tableView: UITableView, forSection section: Int) -> CGFloat {
        preconditionFailure("\(#function) must be overriden in child")
    }
}
