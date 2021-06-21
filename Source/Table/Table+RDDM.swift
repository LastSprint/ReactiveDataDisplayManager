//
//  Table+RDDM.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 21.01.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

extension UITableView: DataDisplayCompatible { }

public extension DataDisplayWrapper where Base: UITableView {

    var baseBuilder: TableBuilder<BaseTableManager> {
        TableBuilder(view: base, manager: BaseTableManager())
    }

    var manualBuilder: TableBuilder<ManualTableManager> {
        TableBuilder(view: base, manager: ManualTableManager())
    }

    var sectionedBuilder: TableBuilder<SectionedTableManager> {
        TableBuilder(view: base, manager: SectionedTableManager())
    }

    var gravityBuilder: TableBuilder<GravityTableManager> {
        TableBuilder(view: base, manager: GravityTableManager())
    }

}
