//
//  CollectionGeneratorsProvider.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 12.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

public protocol CollectionGeneratorsProvider: AnyObject {
    var generators: [[CollectionCellGenerator]] { get set }
    var sections: [CollectionSection] { get set }
}
