//
//  BaseTableDataDisplayManager.swift
//  ReactiveDataDisplayManager
//
//  Created by Alexander Kravchenkov on 01.08.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import Foundation
import UIKit

/// Contains base implementation of DataDisplayManager with UITableView.
/// Registers nibs, determinates EstimatedRowHeight.
/// Can fill table with user data.
open class BaseTableDataDisplayManager: NSObject, DataDisplayManager {

    // MARK: - Typealiases

    public typealias CollectionType = UITableView
    public typealias CellGeneratorType = TableCellGenerator
    public typealias HeaderGeneratorType = TableHeaderGenerator

    // MARK: - Events

    /// Called if table scrolled
    public var scrollEvent = BaseEvent<UITableView>()
    public var scrollViewWillEndDraggingEvent: BaseEvent<CGPoint> = BaseEvent<CGPoint>()
    public var cellChangedPosition = BaseEvent<(oldIndexPath: IndexPath, newIndexPath: IndexPath)>()

    // MARK: - Readonly properties

    public private(set) weak var tableView: UITableView?
    public private(set) var cellGenerators: [[TableCellGenerator]]
    public private(set) var sectionHeaderGenerators: [TableHeaderGenerator]

    // MARK: - Public properties

    public var estimatedHeight: CGFloat = 40

    // MARK: - Initialization and deinitialization

    required public init(collection: UITableView) {
        self.cellGenerators = [[TableCellGenerator]]()
        self.sectionHeaderGenerators = [TableHeaderGenerator]()
        self.scrollViewWillEndDraggingEvent = BaseEvent<CGPoint>()
        super.init()
        self.tableView = collection
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
    }

}

// MARK: - Generator actions

extension BaseTableDataDisplayManager {

    // MARK: - DataDisplayManager actions

    public func addSectionHeaderGenerator(_ generator: TableHeaderGenerator) {
        self.sectionHeaderGenerators.append(generator)
    }

    public func addCellGenerator(_ generator: TableCellGenerator) {
        guard let table = self.tableView else { return }
        generator.registerCell(in: table)
        if self.cellGenerators.count != self.sectionHeaderGenerators.count || sectionHeaderGenerators.isEmpty {
            self.cellGenerators.append([TableCellGenerator]())
        }
        if sectionHeaderGenerators.count <= 0 {
            sectionHeaderGenerators.append(EmptyTableHeaderGenerator())
        }
        // Add to last section
        let index = sectionHeaderGenerators.count - 1
        self.cellGenerators[index < 0 ? 0 : index].append(generator)
    }

    public func addCellGenerators(_ generators: [TableCellGenerator]) {
        for generator in generators {
            self.addCellGenerator(generator)
        }
    }

    public func addCellGenerator(_ generator: TableCellGenerator, after: TableCellGenerator) {
        addCellGenerators([generator], after: after)
    }

    public func addCellGenerators(_ generators: [TableCellGenerator], after: TableCellGenerator) {
        guard let table = self.tableView else { return }
        generators.forEach { $0.registerCell(in: table) }
        guard let (sectionIndex, generatorIndex) = findGenerator(after) else {
            fatalError("Error adding cell generator. You tried to add generators after unexisted generator")
        }
        self.cellGenerators[sectionIndex].insert(contentsOf: generators, at: generatorIndex + 1)
    }

    public func update(generators: [TableCellGenerator]) {
        let indexes = generators.compactMap { [weak self] in self?.findGenerator($0) }
        let indexPaths = indexes.compactMap { IndexPath(row: $0.generatorIndex, section: $0.sectionIndex) }
        self.tableView?.reloadRows(at: indexPaths, with: .none)
    }

    public func clearCellGenerators() {
        self.cellGenerators.removeAll()
    }

    public func clearHeaderGenerators() {
        self.sectionHeaderGenerators.removeAll()
    }

    public func forceRefill() {
        self.tableView?.reloadData()
    }

    public func forceRefill(completion: @escaping (() -> Void)) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion()
        }
        self.forceRefill()
        CATransaction.commit()
    }

    public func reloadSection(by sectionHeaderGenerator: TableHeaderGenerator, with animation: UITableView.RowAnimation = .none) {
        guard let index = sectionHeaderGenerators.firstIndex(where: { (headerGenerator) -> Bool in
            return headerGenerator === sectionHeaderGenerator
        }) else { return }
        tableView?.reloadSections(IndexSet(integer: index), with: animation)
    }

    // MARK: - BaseTableDataDisplayManager actions
    // TODO: Move to DDM protocol and implement in BaseCollectionDDM

    public func addCellGenerators(_ generators: [TableCellGenerator], toHeader header: TableHeaderGenerator) {
        guard let table = self.tableView else { return }
        generators.forEach { $0.registerCell(in: table) }

        if self.cellGenerators.count != self.sectionHeaderGenerators.count || sectionHeaderGenerators.isEmpty {
            self.cellGenerators.append([TableCellGenerator]())
        }

        if let index = self.sectionHeaderGenerators.index(where: { $0 === header }) {
            self.cellGenerators[index].append(contentsOf: generators)
        }
    }

    /// Removes all cell generators from a given section
    public func removeAllGenerators(in header: TableHeaderGenerator) {
        guard let index = self.sectionHeaderGenerators.index(where: { $0 === header }), self.cellGenerators.count > index else {
            return
        }

        self.cellGenerators[index].removeAll()
    }

    public func addCellGenerator(_ generator: TableCellGenerator, toHeader header: TableHeaderGenerator) {
        addCellGenerators([generator], toHeader: header)
    }

}

// MARK: - TableView actions

public extension BaseTableDataDisplayManager {

    /// Removes generator from data display manager. Generators compares by references.
    ///
    /// - Parameters:
    ///   - generator: Generator to delete.
    ///   - animation: Animation for row action.
    ///   - needScrollAt: If not nil than performs scroll before removing generator.
    /// A constant that identifies a relative position in the table view (top, middle, bottom)
    /// for row when scrolling concludes. See UITableViewScrollPosition for descriptions of valid constants.
    ///   - needRemoveEmptySection: Pass **true** if you need to remove section if it'll be empty after deleting.
    public func remove(_ generator: TableCellGenerator,
                       with animation: UITableView.RowAnimation = .automatic,
                       needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                       needRemoveEmptySection: Bool = false) {
        guard let index = self.findGenerator(generator) else { return }
        self.removeGenerator(with: index,
                             with: animation,
                             needScrollAt: scrollPosition,
                             needRemoveEmptySection: needRemoveEmptySection)
    }

    // TODO: Add inserting arrays

    /// Inserts new generator after provided generator.
    ///
    /// - Parameters:
    ///   - after: Generator after which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    public func insert(after generator: TableCellGenerator,
                       new newGenerator: TableCellGenerator,
                       with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }
        self.insertGenerator(newGenerator, at: (sectionIndex: index.sectionIndex, generatorIndex: index.generatorIndex + 1), with: animation)
    }

    /// Inserts new generator before provided generator.
    ///
    /// - Parameters:
    ///   - after: Generator before which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    public func insert(before generator: TableCellGenerator,
                       new newGenerator: TableCellGenerator,
                       with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }
        self.insertGenerator(newGenerator, at: (sectionIndex: index.sectionIndex, generatorIndex: index.generatorIndex), with: animation)
    }

    /// Inserts new generator before provided header.
    ///
    /// - Parameters:
    ///   - to: Header before which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    public func insert(to header: TableHeaderGenerator,
                       new generator: TableCellGenerator,
                       with animation: UITableView.RowAnimation = .automatic) {
        guard let headerIndex = self.sectionHeaderGenerators.index(where: { $0 === header }) else { return }
        self.insertGenerator(generator, at: (sectionIndex: headerIndex, generatorIndex: 0), with: animation)
    }

    /// Replace an old generator on provided generator.
    ///
    /// - Parameters:
    ///   - oldGenerator: Generator that should be replaced. Must be in the DDM.
    ///   - newGenerator: Generator that should be added instead an old generator.
    ///   - removeAnimation: Animation for remove action.
    ///   - insertAnimation: Animation for insert action.
    public func replace(oldGenerator: TableCellGenerator,
                        on newGenerator: TableCellGenerator,
                        removeAnimation: UITableView.RowAnimation = .automatic,
                        insertAnimation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(oldGenerator), let table = self.tableView else { return }

        table.beginUpdates()
        self.cellGenerators[index.sectionIndex].remove(at: index.generatorIndex)
        self.cellGenerators[index.sectionIndex].insert(newGenerator, at: index.generatorIndex)
        let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
        table.deleteRows(at: [indexPath], with: removeAnimation)
        table.insertRows(at: [indexPath], with: insertAnimation)
        table.endUpdates()
    }

    /// Swaps two generators between each other.
    ///
    /// - Warning: Calls reload data in tableView.
    ///
    /// - Parameters:
    ///   - firstGenerator: Generator which must to move to new place. Must be in the DDM.
    ///   - secondGenerator: Generator which must to replaced with firstGenerator and move to it place.
    /// Must be in the DDM.
    public func swap(generator firstGenerator: TableCellGenerator, with secondGenerator: TableCellGenerator) {
        guard let firstIndex = findGenerator(firstGenerator), let secondIndex = findGenerator(secondGenerator) else { return }

        self.cellGenerators[firstIndex.sectionIndex].remove(at: firstIndex.generatorIndex)
        self.cellGenerators[secondIndex.sectionIndex].remove(at: secondIndex.generatorIndex)

        self.cellGenerators[secondIndex.sectionIndex].insert(firstGenerator, at: secondIndex.generatorIndex)
        self.cellGenerators[firstIndex.sectionIndex].insert(secondGenerator, at: firstIndex.generatorIndex)

        self.tableView?.reloadData()
    }

}

// MARK: - Private methods

private extension BaseTableDataDisplayManager {

    func insertGenerator(_ generator: TableCellGenerator,
                         at index: (sectionIndex: Int, generatorIndex: Int),
                         with animation: UITableView.RowAnimation = .automatic) {
        guard let table = self.tableView else { return }

        generator.registerCell(in: table)
        table.beginUpdates()
        self.cellGenerators[index.sectionIndex].insert(generator, at: index.generatorIndex)
        let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
        table.insertRows(at: [indexPath], with: animation)
        table.endUpdates()
    }

    // TODO: May be we should remove needScrollAt and move this responsibility to user
    func removeGenerator(with index: (sectionIndex: Int, generatorIndex: Int),
                                 with animation: UITableView.RowAnimation = .automatic,
                                 needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                                 needRemoveEmptySection: Bool = false) {
        guard let table = self.tableView else { return }

        // perform update
        table.beginUpdates()
        self.cellGenerators[index.sectionIndex].remove(at: index.generatorIndex)
        let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
        table.deleteRows(at: [indexPath], with: animation)

        // remove empty section if needed
        if needRemoveEmptySection && self.cellGenerators[index.sectionIndex].isEmpty {
            self.cellGenerators.remove(at: index.sectionIndex)
            self.sectionHeaderGenerators.remove(at: index.sectionIndex)
            table.deleteSections(IndexSet(integer: index.sectionIndex), with: animation)
        }

        // scroll if needed
        if let scrollPosition = scrollPosition {
            table.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        }

        table.endUpdates()
    }

    func findGenerator(_ generator: TableCellGenerator) -> (sectionIndex: Int, generatorIndex: Int)? {
        for (sectionIndex, section) in cellGenerators.enumerated() {
            if let generatorIndex = section.index(where: { $0 === generator }) {
                return (sectionIndex, generatorIndex)
            }
        }
        return nil
    }

}

// MARK: - UITableViewDelegate

extension BaseTableDataDisplayManager: UITableViewDelegate {

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let guardTable = self.tableView else { return }
        self.scrollEvent.invoke(with: guardTable)
    }

    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let generator = cellGenerators[indexPath.section][indexPath.row] as? MovableGenerator {
            return generator.canMove()
        }
        return false
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveToTheSameSection = sourceIndexPath.section == destinationIndexPath.section
        guard
            let generator = self.cellGenerators[sourceIndexPath.section][sourceIndexPath.row] as? MovableGenerator,
            moveToTheSameSection || generator.canMoveInOtherSection()
        else {
            return
        }

        let itemToMove = self.cellGenerators[sourceIndexPath.section][sourceIndexPath.row]

        // find oldSection and remove item from this array
        self.cellGenerators[sourceIndexPath.section].remove(at: sourceIndexPath.row)

        // findNewSection and add items to this array
        self.cellGenerators[destinationIndexPath.section].insert(itemToMove, at: destinationIndexPath.row)

        self.cellChangedPosition.invoke(with: (oldIndexPath: sourceIndexPath, newIndexPath: destinationIndexPath))

        // need to prevent crash with internal inconsistency of UITableView
        DispatchQueue.main.async {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellGenerators[indexPath.section][indexPath.row].cellHeight
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellGenerators[indexPath.section][indexPath.row].estimatedCellHeight ?? estimatedHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section > self.sectionHeaderGenerators.count - 1 {
            return nil
        }
        return self.sectionHeaderGenerators[section].generate()
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // This code needed to avoid empty header
        if section > sectionHeaderGenerators.count - 1 {
            return 0.01
        }
        return self.sectionHeaderGenerators[section].height(tableView, forSection: section)
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectable = cellGenerators[indexPath.section][indexPath.row] as? SelectableItem else { return }
        selectable.didSelectEvent.invoke(with: ())
        if selectable.isNeedDeselect {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        self.scrollViewWillEndDraggingEvent.invoke(with: velocity)
    }

}

// MARK: - UITableViewDataSource

extension BaseTableDataDisplayManager: UITableViewDataSource {

    open func numberOfSections(in tableView: UITableView) -> Int {
        return sectionHeaderGenerators.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if cellGenerators.indices.contains(section) {
            return cellGenerators[section].count
        } else {
            return 0
        }
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellGenerators[indexPath.section][indexPath.row].generate(tableView: tableView, for: indexPath)
    }

}

