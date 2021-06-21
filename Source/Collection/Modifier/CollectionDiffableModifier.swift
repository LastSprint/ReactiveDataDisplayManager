//
//  CollectionDiffableModifier.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 16.03.2021.
//

import UIKit

/// Helper class to modify `UICollectionView` cells
///
/// - Note: Based on `UICollectionViewDiffableDataSource` and `NSDiffableDataSourceSnapshot` updating.
/// Animations selected automatically or ignored.
@available(iOS 13, *)
class CollectionDiffableModifier: Modifier<UICollectionView, CollectionItemAnimation> {

    typealias CellGeneratorType = CollectionCellGenerator & DiffableItemSource
    typealias HeaderGeneratorType = CollectionHeaderGenerator & DiffableItemSource
    typealias FooterGeneratorType = CollectionFooterGenerator & DiffableItemSource

    // MARK: - Properties

    private weak var provider: CollectionGeneratorsProvider?
    private weak var dataSource: DiffableCollectionDataSource?

    // MARK: - Init

    /// - parameter view: parent view
    /// - parameter provider: wrapped collection of sections and generators
    /// - parameter dataSource: `UICollectionViewDiffableDataSource` to apply new snapshots
    init(view: UICollectionView, provider: CollectionGeneratorsProvider, dataSource: DiffableCollectionDataSource) {
        super.init(view: view)
        self.provider = provider
        self.dataSource = dataSource
    }

    // MARK: - Methods

    /// Update snapshot
    override func reload() {
        apply(animated: true)
    }

    /// Reload items with animation
    ///
    /// - parameter indexPaths: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter updateAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func reloadRows(at indexPaths: [IndexPath], with updateAnimation: CollectionItemAnimation) {
        apply(animated: updateAnimation != .none)
    }

    /// Reload items with animation
    ///
    /// - parameter indexPaths: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter updateAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func reloadSections(at indexPaths: IndexSet, with updateAnimation: CollectionItemAnimation) {
        apply(animated: updateAnimation != .none)
    }

    /// Update snapshot after items replaced
    ///
    /// - parameter indexPath: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter removeAnimation: **ignored**,  see insertAnimation
    /// - parameter insertAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func replace(at indexPath: IndexPath, with removeAnimation: CollectionItemAnimation, and insertAnimation: CollectionItemAnimation) {
        apply(animated: insertAnimation != .none)
    }

    /// Update snapshot after sections inserted
    ///
    /// - parameter indexPaths: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter insertAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func insertSections(at indexPaths: IndexSet, with insertAnimation: CollectionItemAnimation) {
        apply(animated: insertAnimation != .none)
    }

    /// Update snapshot after items inserted
    ///
    /// - parameter indexPaths: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter insertAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func insertRows(at indexPaths: [IndexPath], with insertAnimation: CollectionItemAnimation) {
        apply(animated: insertAnimation != .none)
    }

    /// Remove items and section with animation
    ///
    /// - parameter indexPaths: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter section: **ignored**, automatically calculated using `DiffableSnapshot`
    /// - parameter removeAnimation:
    ///     - **allowed** none to disable animation
    ///     - **ignored** any other, because automatically selected by `UICollectionViewDiffableDataSource`
    override func removeRows(at indexPaths: [IndexPath], and section: IndexSet?, with removeAnimation: CollectionItemAnimation) {
        apply(animated: removeAnimation != .none)
    }

}

// MARK: - Private

@available(iOS 13, *)
private extension CollectionDiffableModifier {

    func apply(animated: Bool = false, completion: (() -> Void)? = nil) {
        guard let snapshot = makeSnapshot() else { return }

        safeApplySnapshot(snapshot, animated: animated, completion: completion)
    }

    func makeSnapshot() -> DiffableSnapshot? {
        guard let provider = provider else { return nil }

        assert(provider.generators is [[CellGeneratorType]], "This strategy support only \(CellGeneratorType.Type.self)")
        assert(provider.sections.map { $0.header } is [HeaderGeneratorType], "This strategy support only \(HeaderGeneratorType.Type.self)")
        assert(provider.sections.map { $0.footer } is [FooterGeneratorType], "This strategy support only \(FooterGeneratorType.Type.self)")

        guard let generators = provider.generators as? [[CellGeneratorType]]
        else { return nil }

        var snapshot = DiffableSnapshot()

        for (index, section) in provider.sections.enumerated() {

            guard let headerItem = (section.header as? HeaderGeneratorType)?.item else { continue }

            snapshot.appendSections([headerItem])

            guard let generators = generators[safe: index] else { continue }

            let items = generators.map { $0.item }
            snapshot.appendItems(items, toSection: headerItem)
        }

        return snapshot
    }

    func safeApplySnapshot(_ snapshot: DiffableSnapshot, animated: Bool = false, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak dataSource] in
            dataSource?.apply(snapshot, animatingDifferences: animated, completion: completion)
        }
    }

}
