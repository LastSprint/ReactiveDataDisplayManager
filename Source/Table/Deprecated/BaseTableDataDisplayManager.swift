//
//  BaseTableDataDisplayManager.swift
//  ReactiveDataDisplayManager
//
//  Created by Alexander Kravchenkov on 01.08.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import UIKit

/// Contains base implementation of DataDisplayManager with UITableView.
/// Registers nibs, determinates EstimatedRowHeight.
/// Can fill table with user data.
@available(*, deprecated, message: "Use ManualTableManager instead")
open class BaseTableDataDisplayManager: NSObject {

    // MARK: - Typealiases

    public typealias CollectionType = UITableView
    public typealias CellGeneratorType = TableCellGenerator
    public typealias HeaderGeneratorType = TableHeaderGenerator

    // MARK: - Events

    /// Called if table scrolled
    public var scrollEvent = BaseEvent<UITableView>()
    public var scrollViewWillEndDraggingEvent: BaseEvent<CGPoint> = BaseEvent<CGPoint>()
    public var cellChangedPosition = BaseEvent<(oldIndexPath: IndexPath, newIndexPath: IndexPath)>()

    /// Celled when cells displaying
    public var willDisplayCellEvent = BaseEvent<(TableCellGenerator, IndexPath)>()
    public var didEndDisplayCellEvent = BaseEvent<(TableCellGenerator, IndexPath)>()

    // MARK: - Readonly properties

    public private(set) weak var view: UITableView!
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
        self.view = collection
        self.view?.delegate = self
        self.view?.dataSource = self
    }

}

// MARK: - DataDisplayManager

extension BaseTableDataDisplayManager: DataDisplayManager {

    public func addSection(header generator: TableHeaderGenerator, cells: [TableCellGenerator]) {
        cells.forEach { $0.registerCell(in: view) }
        self.sectionHeaderGenerators.append(generator)
        self.cellGenerators.append(cells)
    }

    public func addSectionHeaderGenerator(_ generator: TableHeaderGenerator) {
        self.sectionHeaderGenerators.append(generator)
    }

    public func insert(headGenerator: TableHeaderGenerator, after: TableHeaderGenerator) {
        if self.sectionHeaderGenerators.contains(where: { $0 === headGenerator }) {
            fatalError("Error adding header generator. Header generator was added earlier")
        }
        guard let anchorIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === after }) else {
            fatalError("Error adding header generator. You tried to add generators after unexisted generator")
        }
        let newIndex = anchorIndex + 1
        self.insert(headGenerator: headGenerator, by: newIndex)
    }

    public func insert(headGenerator: TableHeaderGenerator, before: TableHeaderGenerator) {
        if self.sectionHeaderGenerators.contains(where: { $0 === headGenerator }) {
            fatalError("Error adding header generator. Header generator was added earlier")
        }
        guard let anchorIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === before }) else {
            fatalError("Error adding header generator. You tried to add generators after unexisted generator")
        }
        let newIndex = max(anchorIndex - 1, 0)
        self.insert(headGenerator: headGenerator, by: newIndex)
    }

    public func addCellGenerator(_ generator: TableCellGenerator) {
        generator.registerCell(in: view)
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
        generators.forEach { $0.registerCell(in: view) }
        guard let (sectionIndex, generatorIndex) = findGenerator(after) else {
            fatalError("Error adding cell generator. You tried to add generators after unexisted generator")
        }
        self.cellGenerators[sectionIndex].insert(contentsOf: generators, at: generatorIndex + 1)
    }

    public func update(generators: [TableCellGenerator]) {
        let indexes = generators.compactMap { [weak self] in self?.findGenerator($0) }
        let indexPaths = indexes.compactMap { IndexPath(row: $0.generatorIndex, section: $0.sectionIndex) }
        self.view?.reloadRows(at: indexPaths, with: .none)
    }

    public func clearCellGenerators() {
        self.cellGenerators.removeAll()
    }

    public func clearHeaderGenerators() {
        self.sectionHeaderGenerators.removeAll()
    }

    public func forceRefill() {
        self.view?.reloadData()
    }

    public func reloadSection(by sectionHeaderGenerator: TableHeaderGenerator, with animation: UITableView.RowAnimation = .none) {
        guard let index = sectionHeaderGenerators.firstIndex(where: { (headerGenerator) -> Bool in
            return headerGenerator === sectionHeaderGenerator
        }) else { return }
        view?.reloadSections(IndexSet(integer: index), with: animation)
    }
}

// MARK: - HeaderDataDisplayManager

extension BaseTableDataDisplayManager: HeaderDataDisplayManager {

    public func addCellGenerators(_ generators: [TableCellGenerator], toHeader header: TableHeaderGenerator) {
        generators.forEach { $0.registerCell(in: view) }

        if self.cellGenerators.count != self.sectionHeaderGenerators.count || sectionHeaderGenerators.isEmpty {
            self.cellGenerators.append([TableCellGenerator]())
        }

        if let index = self.sectionHeaderGenerators.firstIndex(where: { $0 === header }) {
            self.cellGenerators[index].append(contentsOf: generators)
        }
    }

    /// Removes all cell generators from a given section
    public func removeAllGenerators(from header: TableHeaderGenerator) {
        guard let index = self.sectionHeaderGenerators.firstIndex(where: { $0 === header }), self.cellGenerators.count > index else {
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
    func remove(_ generator: TableCellGenerator,
                with animation: UITableView.RowAnimation = .automatic,
                needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                needRemoveEmptySection: Bool = false) {
        guard let index = self.findGenerator(generator) else { return }
        self.removeGenerator(with: index,
                             with: animation,
                             needScrollAt: scrollPosition,
                             needRemoveEmptySection: needRemoveEmptySection)
    }

    /// Inserts new head generator.
    ///
    /// - Parameters:
    ///   - headGenerator: Header which you want to insert.
    ///   - by: Index which new header will be added.
    ///   - generators: Generators which you want to insert.
    ///   - with: Animation for row action.
    func insert(headGenerator: TableHeaderGenerator,
                by index: Int,
                generators: [TableCellGenerator],
                with animation: UITableView.RowAnimation = .automatic) {
        self.insert(headGenerator: headGenerator, by: index, animation: animation)
        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === headGenerator }) else {
            return
        }

        let elements = generators.enumerated().map {
            ($0.element, headerIndex, $0.offset)
        }

        self.insert(elements: elements, with: animation)
    }

    /// Inserts new section.
    ///
    /// - Parameters:
    ///   - before: Header before which new section will be added.
    ///   - new: Header which you want to insert before current header.
    ///   - generators: Generators which you want to insert.
    ///   - with: Animation for row action.
    func insertSection(before header: TableHeaderGenerator,
                       new sectionHeader: TableHeaderGenerator,
                       generators: [TableCellGenerator],
                       with animation: UITableView.RowAnimation = .automatic) {
        self.insert(headGenerator: sectionHeader, before: header)

        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: {
            $0 === sectionHeader
        }) else {
            return
        }

        let elements = generators.enumerated().map {
            ($0.element, headerIndex, $0.offset)
        }

        self.insert(elements: elements, with: animation)
    }

    /// Inserts new section.
    ///
    /// - Parameters:
    ///   - after: Header after which new section will be added.
    ///   - new: Header which you want to insert after current header.
    ///   - generators: Generators which you want to insert.
    ///   - with: Animation for row action.
    func insertSection(after header: TableHeaderGenerator,
                       new sectionHeader: TableHeaderGenerator,
                       generators: [TableCellGenerator],
                       with animation: UITableView.RowAnimation = .automatic) {
        self.insert(headGenerator: sectionHeader, after: header)

        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: {
            $0 === sectionHeader
        }) else {
            return
        }

        let elements = generators.enumerated().map { item in
            (item.element, headerIndex, item.offset)
        }

        self.insert(elements: elements, with: animation)
    }

    /// Inserts new generators after provided generator.
    ///
    /// - Parameters:
    ///   - after: Generator after which new generator will be added. Must be in the DDM.
    ///   - new: Generators which you want to insert after current generator.
    ///   - with: Animation for row action.
    func insert(after generator: TableCellGenerator,
                new newGenerators: [TableCellGenerator],
                with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }

        let elements = newGenerators.enumerated().map { item in
            (item.element, index.sectionIndex, index.generatorIndex + item.offset + 1)
        }
        self.insert(elements: elements, with: animation)
    }

    /// Inserts new generators before provided generator.
    ///
    /// - Parameters:
    ///   - before: Generator before which new generators will be added. Must be in the DDM.
    ///   - new: Generators which you want to insert before current generator.
    ///   - with: Animation for row action.
    func insert(before generator: TableCellGenerator,
                new newGenerators: [TableCellGenerator],
                with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }
        let elements = newGenerators.enumerated().map { item in
            (item.element, index.sectionIndex, index.generatorIndex + item.offset)
        }
        self.insert(elements: elements, with: animation)
    }

    /// Inserts new generator after provided generator.
    ///
    /// - Parameters:
    ///   - after: Generator after which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    func insert(after generator: TableCellGenerator,
                new newGenerator: TableCellGenerator,
                with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }
        self.insert(elements: [(newGenerator, index.sectionIndex, index.generatorIndex + 1)], with: animation)
    }

    /// Inserts new generator before provided generator.
    ///
    /// - Parameters:
    ///   - after: Generator before which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    func insert(before generator: TableCellGenerator,
                new newGenerator: TableCellGenerator,
                with animation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(generator) else { return }
        self.insert(elements: [(newGenerator, index.sectionIndex, index.generatorIndex)], with: animation)
    }

    /// Inserts new generator before provided header.
    ///
    /// - Parameters:
    ///   - to: Header before which new generator will be added. Must be in the DDM.
    ///   - new: Generator which you want to insert after current generator.
    ///   - with: Animation for row action.
    func insert(to header: TableHeaderGenerator,
                new generator: TableCellGenerator,
                with animation: UITableView.RowAnimation = .automatic) {
        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === header }) else {
            return
        }
        self.insert(elements: [(generator, headerIndex, 0)], with: animation)
    }

    /// Inserts new generators before provided header.
    ///
    /// - Parameters:
    ///   - to: Header before which new generator will be added. Must be in the DDM.
    ///   - new: Generators which you want to insert before current generator.
    ///   - with: Animation for row action.
    func insertAtBeginning(to header: TableHeaderGenerator,
                           new generators: [TableCellGenerator],
                           with animation: UITableView.RowAnimation = .automatic) {
        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === header }) else {
            return
        }
        let elements = generators.enumerated().map { item in
            (item.element, headerIndex, item.offset)
        }
        self.insert(elements: elements, with: animation)
    }

    /// Inserts new generators before provided header.
    ///
    /// - Parameters:
    ///   - to: Header before which new generator will be added. Must be in the DDM.
    ///   - new: Generators which you want to insert after current generator.
    ///   - with: Animation for row action.
    func insertAtEnd(to header: TableHeaderGenerator,
                     new generators: [TableCellGenerator],
                     with animation: UITableView.RowAnimation = .automatic) {
        guard let headerIndex = self.sectionHeaderGenerators.firstIndex(where: { $0 === header }) else {
            return
        }
        let base = self.cellGenerators[headerIndex].count
        let elements = generators.enumerated().map { item in
            (item.element, headerIndex, base + item.offset)
        }
        self.insert(elements: elements, with: animation)
    }

    /// Replace an old generator on provided generator.
    ///
    /// - Parameters:
    ///   - oldGenerator: Generator that should be replaced. Must be in the DDM.
    ///   - newGenerator: Generator that should be added instead an old generator.
    ///   - removeAnimation: Animation for remove action.
    ///   - insertAnimation: Animation for insert action.
    func replace(oldGenerator: TableCellGenerator,
                 on newGenerator: TableCellGenerator,
                 removeAnimation: UITableView.RowAnimation = .automatic,
                 insertAnimation: UITableView.RowAnimation = .automatic) {
        guard let index = self.findGenerator(oldGenerator) else { return }

        view.beginUpdates()
        self.cellGenerators[index.sectionIndex].remove(at: index.generatorIndex)
        self.cellGenerators[index.sectionIndex].insert(newGenerator, at: index.generatorIndex)
        let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
        view.deleteRows(at: [indexPath], with: removeAnimation)
        view.insertRows(at: [indexPath], with: insertAnimation)
        view.endUpdates()
    }

    /// Swaps two generators between each other.
    ///
    /// - Warning: Calls reload data in tableView.
    ///
    /// - Parameters:
    ///   - firstGenerator: Generator which must to move to new place. Must be in the DDM.
    ///   - secondGenerator: Generator which must to replaced with firstGenerator and move to it place.
    /// Must be in the DDM.
    func swap(generator firstGenerator: TableCellGenerator, with secondGenerator: TableCellGenerator) {
        guard let firstIndex = findGenerator(firstGenerator), let secondIndex = findGenerator(secondGenerator) else {
            return
        }

        self.cellGenerators[firstIndex.sectionIndex].remove(at: firstIndex.generatorIndex)
        self.cellGenerators[secondIndex.sectionIndex].remove(at: secondIndex.generatorIndex)

        self.cellGenerators[secondIndex.sectionIndex].insert(firstGenerator, at: secondIndex.generatorIndex)
        self.cellGenerators[firstIndex.sectionIndex].insert(secondGenerator, at: firstIndex.generatorIndex)

        self.view?.reloadData()
    }

}

// MARK: - Private methods

private extension BaseTableDataDisplayManager {

    func insert(headGenerator: TableHeaderGenerator,
                by index: Int,
                animation: UITableView.RowAnimation = .none) {
        let index = min(max(index, 0), self.sectionHeaderGenerators.count)
        self.sectionHeaderGenerators.insert(headGenerator, at: index)
        self.cellGenerators.insert([], at: index)
        view?.insertSections([index], with: animation)
    }

    func insert(elements: [(generator: TableCellGenerator, sectionIndex: Int, generatorIndex: Int)],
                with animation: UITableView.RowAnimation = .automatic) {

        elements.forEach { [weak self] element in
            element.generator.registerCell(in: view)
            self?.cellGenerators[element.sectionIndex].insert(element.generator, at: element.generatorIndex)
        }

        let indexPaths = elements.map {
            IndexPath(row: $0.generatorIndex, section: $0.sectionIndex)
        }

        view.beginUpdates()
        view.insertRows(at: indexPaths, with: animation)
        view.endUpdates()
    }

    // TODO: May be we should remove needScrollAt and move this responsibility to user
    func removeGenerator(with index: (sectionIndex: Int, generatorIndex: Int),
                                 with animation: UITableView.RowAnimation = .automatic,
                                 needScrollAt scrollPosition: UITableView.ScrollPosition? = nil,
                                 needRemoveEmptySection: Bool = false) {
        // perform update
        view.beginUpdates()
        self.cellGenerators[index.sectionIndex].remove(at: index.generatorIndex)
        let indexPath = IndexPath(row: index.generatorIndex, section: index.sectionIndex)
        view.deleteRows(at: [indexPath], with: animation)

        // remove empty section if needed
        if needRemoveEmptySection && self.cellGenerators[index.sectionIndex].isEmpty {
            self.cellGenerators.remove(at: index.sectionIndex)
            self.sectionHeaderGenerators.remove(at: index.sectionIndex)
            view.deleteSections(IndexSet(integer: index.sectionIndex), with: animation)
        }

        // scroll if needed
        if let scrollPosition = scrollPosition {
            view.scrollToRow(at: indexPath, at: scrollPosition, animated: true)
        }

        view.endUpdates()
    }

    func findGenerator(_ generator: TableCellGenerator) -> (sectionIndex: Int, generatorIndex: Int)? {
        for (sectionIndex, section) in cellGenerators.enumerated() {
            if let generatorIndex = section.firstIndex(where: { $0 === generator }) {
                return (sectionIndex, generatorIndex)
            }
        }
        return nil
    }

}

// MARK: - Scrolling

public extension BaseTableDataDisplayManager {

    func scrollTo(headGenerator: TableHeaderGenerator, scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard let index = sectionHeaderGenerators.firstIndex(where: { $0 === headGenerator }) else {
            return
        }
        view?.scrollToRow(at: IndexPath(row: 0, section: index), at: scrollPosition, animated: animated)
    }

    func scrollTo(generator: TableCellGenerator, scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        for sectionElement in cellGenerators.enumerated() {
            for rowElement in sectionElement.element.enumerated() {
                if rowElement.element === generator {
                    let indexPath = IndexPath(row: rowElement.offset, section: sectionElement.offset)
                    view?.scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
                    return
                }
            }
        }
    }

}

// MARK: - UITableViewDelegate

extension BaseTableDataDisplayManager: UITableViewDelegate {

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let guardTable = self.view else { return }
        self.scrollEvent.invoke(with: guardTable)
    }

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let generator = self.cellGenerators[safe: indexPath.section]?[safe: indexPath.row] else {
            return
        }
        self.willDisplayCellEvent.invoke(with: (generator, indexPath))
        if let displayable = generator as? DisplayableFlow {
            displayable.willDisplayEvent.invoke(with: ())
        }
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let displayable = self.sectionHeaderGenerators[safe: section] as? DisplayableFlow else {
            return
        }
        displayable.willDisplayEvent.invoke(with: ())
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        guard let displayable = self.sectionHeaderGenerators[safe: section] as? DisplayableFlow else {
            return
        }
        displayable.didEndDisplayEvent.invoke(with: ())
    }

    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let generator = self.cellGenerators[safe: indexPath.section]?[safe: indexPath.row] else {
            return
        }
        self.didEndDisplayCellEvent.invoke(with: (generator, indexPath))
        if let displayable = generator as? DisplayableFlow {
            displayable.didEndDisplayEvent.invoke(with: ())
            displayable.didEndDisplayCellEvent?.invoke(with: cell)
        }
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
        }
        return 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellGenerators[indexPath.section][indexPath.row].generate(tableView: tableView, for: indexPath)
    }

}
