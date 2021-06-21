//
//  TableGeneratorsProvider.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 12.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

public protocol TableGeneratorsProvider: AnyObject {
    var generators: [[TableCellGenerator]] { get set }
    var sections: [TableSection] { get set }
}
