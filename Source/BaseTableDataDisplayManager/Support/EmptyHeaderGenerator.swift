//
//  EmptyHeaderGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Ivan Smetanin on 27/05/2018.
//  Copyright © 2018 Александр Кравченков. All rights reserved.
//

import Foundation

/// Генератор заголовков-заглушек.
/// Заголовок будет иметь минимальную высоту.
/// Может быть полезен в случае, если нужно разделение по секциям, но заголовки не нужны. 
public class EmptyTableHeaderGenerator: TableHeaderGenerator {

    open override func generate() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        return view
    }

    open override func height(_ tableView: UITableView, forSection section: Int) -> CGFloat {
        return 0.01
    }
}
