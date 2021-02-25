////
////  BaseTableManager.swift
////  ReactiveDataDisplayManager
////
////  Created by Aleksandr Smirnov on 02.11.2020.
////  Copyright © 2020 Александр Кравченков. All rights reserved.
////

import UIKit

/// Base implementation of DataDisplayManager for UITableView that contains minimal interface
open class BaseTableManager: DataDisplayManager, TableGeneratorsProvider {

    // MARK: - Typealias

    public typealias CollectionType = UITableView
    public typealias CellGeneratorType = TableCellGenerator
    public typealias HeaderGeneratorType = TableHeaderGenerator

    public typealias TableAnimator = Animator<CollectionType>

    // MARK: - Public properties

    public weak var view: UITableView!

    public var generators: [[TableCellGenerator]]
    public var sections: [TableHeaderGenerator]

    var delegate: TableDelegate?
    var dataSource: TableDataSource?
    var animator: TableAnimator?

    // MARK: - Initialization

    public init() {
        generators = [[TableCellGenerator]]()
        sections = [TableHeaderGenerator]()
    }

    // MARK: - DataDisplayManager

    public func forceRefill() {
        view?.reloadData()
    }

    open func addCellGenerator(_ generator: TableCellGenerator) {
        guard let table = view else { return }
        generator.registerCell(in: table)
        if self.generators.count != self.sections.count || sections.isEmpty {
            self.generators.append([TableCellGenerator]())
        }
        if sections.count <= 0 {
            sections.append(EmptyTableHeaderGenerator())
        }
        // Add to last section
        let index = sections.count - 1
        self.generators[index < 0 ? 0 : index].append(generator)
    }

    open func addCellGenerators(_ generators: [TableCellGenerator], after: TableCellGenerator) {
        generators.forEach { $0.registerCell(in: view) }
        guard let (sectionIndex, generatorIndex) = findGenerator(after) else {
            fatalError("Error adding TableCellGenerator generator. You tried to add generators after unexisted generator")
        }
        self.generators[sectionIndex].insert(contentsOf: generators, at: generatorIndex + 1)
    }

    open func addCellGenerator(_ generator: TableCellGenerator, after: TableCellGenerator) {
        addCellGenerators([generator], after: after)
    }

    open func addCellGenerators(_ generators: [TableCellGenerator]) {
        for generator in generators {
            self.addCellGenerator(generator)
        }
    }

    open func update(generators: [TableCellGenerator]) {
        let indexes = generators.compactMap { [weak self] in self?.findGenerator($0) }
        let indexPaths = indexes.compactMap { IndexPath(row: $0.generatorIndex, section: $0.sectionIndex) }
        view?.reloadRows(at: indexPaths, with: .none)
    }

    open func clearCellGenerators() {
        generators.removeAll()
    }

    /// Removes generator from data display manager. Generators compares by references.
    ///
    /// - Parameters:
    ///   - generator: Generator to delete.
    ///   - animation: Animation for row action.
    ///   - needScrollAt: If not nil than performs scroll before removing generator.
    /// A constant that identifies a relative position in the table view (top, middle, bottom)
    /// for row when scrolling concludes. See UITableViewScrollPosition for descriptions of valid constants.
    ///   - needRemoveEmptySection: Pass **true** if you need to remove section if it'll be empty after deleting.
    ///   - completion: A completion handler block to execute when all of the operations are finished
    open func remove(_ generator: TableCellGenerator,
                     with animation: UITableView.RowAnimation = .automatic,
                     needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                     needRemoveEmptySection: Bool = false,
                     completion: (() -> Void)? = nil) {
        guard let index = findGenerator(generator) else { return }
        self.removeGenerator(with: index,
                             with: animation,
                             needScrollAt: scrollPosition,
                             needRemoveEmptySection: needRemoveEmptySection,
                             completion: completion)
    }

}

// MARK: - Helper

extension BaseTableManager {

    func findGenerator(_ generator: TableCellGenerator) -> (sectionIndex: Int, generatorIndex: Int)? {
        for (sectionIndex, section) in generators.enumerated() {
            if let generatorIndex = section.firstIndex(where: { $0 === generator }) {
                return (sectionIndex, generatorIndex)
            }
        }
        return nil
    }

    func removeGenerator(with index: (sectionIndex: Int, generatorIndex: Int),
                         with animation: UITableView.RowAnimation = .automatic,
                         needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                         needRemoveEmptySection: Bool = false,
                         completion: (() -> Void)? = nil) {

        animator?.perform(in: view) { [weak self] in
            self?.generators[index.sectionIndex].remove(at: index.generatorIndex)
            let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
            view.deleteRows(at: [indexPath], with: animation)

            // remove empty section if needed
            let sectionIsEmpty = self?.generators[index.sectionIndex].isEmpty ?? true
            if needRemoveEmptySection && sectionIsEmpty {
                self?.generators.remove(at: index.sectionIndex)
                self?.sections.remove(at: index.sectionIndex)
                view.deleteSections(IndexSet(integer: index.sectionIndex), with: animation)
            }

            // scroll if needed
            if let scrollPosition = scrollPosition {
                view.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
            }

            completion?()
        }
    }

}
