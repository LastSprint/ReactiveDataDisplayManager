//
//  TableDisplayablePlugin.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 28.01.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

public class TableDisplayablePlugin: BaseTablePlugin<TableEvent> {

    // MARK: - BaseTablePlugin

    public override func process(event: TableEvent, with manager: BaseTableManager?) {
        switch event {
        case .willDisplayCell(let indexPath):
            let displayable = getDisplayableFlowCell(from: manager, at: indexPath)
            displayable?.willDisplayEvent.invoke(with: ())
        case .didEndDisplayCell(let indexPath):
            let displayable = getDisplayableFlowCell(from: manager, at: indexPath)
            displayable?.didEndDisplayEvent.invoke(with: ())
        case .willDisplayHeader(let section):
            let displayable = getDisplayableFlowHeader(from: manager, at: section)
            displayable?.willDisplayEvent.invoke(with: ())
        case .didEndDisplayHeader(let section):
            let displayable = getDisplayableFlowHeader(from: manager, at: section)
            displayable?.didEndDisplayEvent.invoke(with: ())
        default:
            break
        }
    }

}

// MARK: - Private Methods

private extension TableDisplayablePlugin {

    func getDisplayableFlowCell(from manager: BaseTableManager?, at indexPath: IndexPath) -> RDDMDisplayableItem? {
        manager?.generators[safe: indexPath.section]?[safe: indexPath.row] as? RDDMDisplayableItem
    }

    func getDisplayableFlowHeader(from manager: BaseTableManager?, at section: Int) -> RDDMDisplayableItem? {
        manager?.sections[safe: section] as? RDDMDisplayableItem
    }

}
