//
//  ManualTableManager.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Anton Eysner on 12.02.2021.
//  Copyright © 2021 Alexander Kravchenkov. All rights reserved.
//

import ReactiveDataDisplayManager
import DifferenceKit

extension TableHeaderGenerator: Differentiable {

    // MARK: - Differentiable

    public var differenceIdentifier: String {
        return uuid
    }

    public func isContentEqual(to source: TableHeaderGenerator) -> Bool {
        return uuid == source.uuid
    }

}

extension DiffableItem: Differentiable { }

extension ManualTableManager {

    // MARK: - Typealias

    typealias Section = ArraySection<TableHeaderGenerator, DiffableItem>
    typealias ChangesetClosure = (Changeset<[Section]>) -> Bool
    typealias ChangesClosure = (ManualTableManager) -> Void
    typealias Animation = UITableView.RowAnimation

    // MARK: - Internal Methods

    /// - parameters:
    ///   - animation: An option to animate the updates.
    ///   - changes: A staged set of changes.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    func reload(animation: Animation = .automatic, changes: ChangesClosure, interrupt: ChangesetClosure? = nil) {
        update(with: changes,
               deleteSectionsAnimation: animation,
               insertSectionsAnimation: animation,
               reloadSectionsAnimation: animation,
               deleteRowsAnimation: animation,
               insertRowsAnimation: animation,
               reloadRowsAnimation: animation,
               interrupt: interrupt)
    }

    /// - parameters:
    ///   - deleteSectionsAnimation: An option to animate the section deletion.
    ///   - insertSectionsAnimation: An option to animate the section insertion.
    ///   - reloadSectionsAnimation: An option to animate the section reload.
    ///   - deleteRowsAnimation: An option to animate the row deletion.
    ///   - insertRowsAnimation: An option to animate the row insertion.
    ///   - reloadRowsAnimation: An option to animate the row reload.
    ///   - changes: A staged set of changes.
    ///   - interrupt: A closure that takes an changeset as its argument and returns `true` if the animated
    ///                updates should be stopped and performed reloadData. Default is nil.
    func reload(deleteSectionsAnimation: Animation = .automatic,
                insertSectionsAnimation: Animation = .automatic,
                reloadSectionsAnimation: Animation = .automatic,
                deleteRowsAnimation: Animation = .automatic,
                insertRowsAnimation: Animation = .automatic,
                reloadRowsAnimation: Animation = .automatic,
                changes: ChangesClosure,
                interrupt: ChangesetClosure? = nil) {
        update(with: changes,
               deleteSectionsAnimation: deleteSectionsAnimation,
               insertSectionsAnimation: insertSectionsAnimation,
               reloadSectionsAnimation: reloadSectionsAnimation,
               deleteRowsAnimation: deleteRowsAnimation,
               insertRowsAnimation: insertRowsAnimation,
               reloadRowsAnimation: reloadRowsAnimation,
               interrupt: interrupt)
    }

}

// MARK: - Private Methods

private extension ManualTableManager {

    func update(with changes: ChangesClosure,
                deleteSectionsAnimation: Animation = .automatic,
                insertSectionsAnimation: Animation = .automatic,
                reloadSectionsAnimation: Animation = .automatic,
                deleteRowsAnimation: Animation = .automatic,
                insertRowsAnimation: Animation = .automatic,
                reloadRowsAnimation: Animation = .automatic,
                interrupt: ChangesetClosure? = nil) {
        let oldSnapshot = makeSnapshot()

        changes(self)

        guard
            let source = oldSnapshot ?? makeSnapshot(),
            let data = makeSnapshot()
        else { return }

        let changeset = StagedChangeset(source: source, target: data)
        view.reload(using: changeset,
                    deleteSectionsAnimation: deleteSectionsAnimation,
                    insertSectionsAnimation: insertSectionsAnimation,
                    reloadSectionsAnimation: reloadSectionsAnimation,
                    deleteRowsAnimation: deleteRowsAnimation,
                    insertRowsAnimation: insertRowsAnimation,
                    reloadRowsAnimation: reloadRowsAnimation,
                    interrupt: interrupt) { _ in }
    }

    func makeSnapshot() -> [Section]? {
        guard let generators = generators as? [[DiffableItemSource]] else { return nil }
        return sections.enumerated().compactMap {
            guard let header = $1.header else {
                return nil
            }
            let elements = generators.asDiffableItems[safe: $0] ?? []
            return Section(model: header, elements: elements)
        }
    }

}
