//
//  SectionedTableManager.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

// MARK: - SectionedDataDisplayManager

/// Extended implementation of `BaseTableManager` with supporting of  custom `headers` and `footers` for section
public class SectionedTableManager: BaseTableManager, SectionedDataDisplayManager {

    public func addSection(_ section: TableSection) {
        sections.append(section)
    }

    public func addCellGenerators(_ generators: [TableCellGenerator], toSection section: TableSection) {
        generators.forEach { $0.registerCell(in: view) }

        if self.generators.count != self.sections.count || sections.isEmpty {
            self.generators.append([TableCellGenerator]())
        }

        let sectionIndex = sections
            .firstIndex(where: {
                            $0.header === section.header && $0.footer === section.footer
            })

        if let index = sectionIndex {
            self.generators[index].append(contentsOf: generators)
        }
    }

    public func removeSection(_ section: TableSection) {

        let sectionIndex = sections
            .firstIndex(where: {
                            $0.header === section.header && $0.footer === section.footer
            })

        guard let index = sectionIndex,
            generators.count > index
                else {
                    return
                }

        generators[index].removeAll()
    }

    public func clearAllSections() {
        sections.removeAll()
        clearCellGenerators()
    }

}
