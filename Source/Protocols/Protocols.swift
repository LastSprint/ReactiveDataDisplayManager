//
//  Protocols.swift
//  ReactiveDataDisplayManager
//
//  Created by Alexander Kravchenkov on 01.08.17.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import UIKit

/// Protocol that incapsulated type of current cell
public protocol TableCellGenerator: ViewRegistableItem {

    /// Nib type, which create this generator
    var identifier: String { get }

    /// Creates a cell.
    ///
    /// - Parameter tableView: TableView, which controlled cell grations
    /// - Return: New (may reused) cell.
    func generate(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell

    /// Register cell in tableView
    ///
    /// - Parameter in: TableView, in which cell will be registered
    func registerCell(in tableView: UITableView)

    /// Height for cell.
    ///
    /// Default implementation returns UITableView.automaticDimension
    var cellHeight: CGFloat { get }

    /// Estimated height for cell
    ///
    /// Default implementation returns nil
    var estimatedCellHeight: CGFloat? { get }
}

/// Protocol that incapsulated type of current cell
public protocol CollectionCellGenerator: ViewRegistableItem {

    /// Nib type, which create this generator
    var identifier: String { get }

    /// Creates a cell.
    ///
    /// - Parameter tableView: TableView, which controlled cell grations
    /// - Return: New (may reused) cell.
    func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell

    /// Register cell in collectionView
    ///
    /// - Parameter in: CollectionView, in which cell will be registered
    func registerCell(in collectionView: UICollectionView)
}

/// Protocol that incapsulated build logics for current View
public protocol ViewGenerator: AnyObject {

    associatedtype ViewType

    func generate() -> ViewType
}

/// Builder for concreate type of UIView
public protocol ViewBuilder {

    associatedtype ViewType: UIView

    /// Configures view.
    ///
    /// - Parameter view: UIView that should be configured.
    func build(view: ViewType)
}

@available(*, deprecated, message: "Use FoldableItem")
public protocol GravityFoldableItem: AnyObject {
    var didFoldEvent: BaseEvent<Bool> { get }
    var isExpanded: Bool { get set }
    var childGenerators: [GravityTableCellGenerator] { get set }
}

@available(*, deprecated, message: "Use DisplayableItem")
public protocol DisplayableFlow: AnyObject {

    /// Invokes when cell will displaying.
    var willDisplayEvent: BaseEvent<Void> { get }

    /// SORTA DEPRECATED
    /// Invokes when cell did end displaying.
    var didEndDisplayEvent: BaseEvent<Void> { get }

    /// Invokes when cell did end displaying. (Replacement for didEndDisplayEvent:; makes cell management easier.)
    /// To be clear, it is just a workaround.
    var didEndDisplayCellEvent: BaseEvent<UITableViewCell>? { get }

}

@available(*, deprecated, message: "Use DeletableItem")
public protocol DeletableGenerator {
    var eventDelete: BaseEmptyEvent { get }
}

@available(*, deprecated, message: "Use MovableItem")
public protocol MovableGenerator {
    func canMove() -> Bool
    func canMoveInOtherSection() -> Bool
}

@available(*, deprecated, message: "Use MovableItem")
public extension MovableGenerator {

    func canMove() -> Bool {
        return true
    }

    func canMoveInOtherSection() -> Bool {
        return true
    }

}

public extension TableCellGenerator {

    var cellHeight: CGFloat {
        return UITableView.automaticDimension
    }

    var estimatedCellHeight: CGFloat? {
        return nil
    }

}

public extension TableCellGenerator where Self: ViewBuilder {

    func generate(tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: self.identifier, for: indexPath) as? Self.ViewType else {
            return UITableViewCell()
        }

        self.build(view: cell)

        return cell as? UITableViewCell ?? UITableViewCell()
    }

    func registerCell(in tableView: UITableView) {
        tableView.registerNib(self.identifier, bundle: Self.bundle())
    }

}

public extension CollectionCellGenerator where Self: ViewBuilder {

    func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.identifier, for: indexPath) as? Self.ViewType else {
            return UICollectionViewCell()
        }

        self.build(view: cell)

        return cell as? UICollectionViewCell ?? UICollectionViewCell()
    }

    func registerCell(in collectionView: UICollectionView) {
        collectionView.registerNib(self.identifier, bundle: Self.bundle())
    }

}

/// Protocol that incapsulated type of current cell
public protocol StackCellGenerator: AnyObject {
    func generate(stackView: UIStackView, index: Int) -> UIView
}

public extension StackCellGenerator where Self: ViewBuilder {
    func generate(stackView: UIStackView, index: Int) -> UIView {
        let view = Self.ViewType()
        self.build(view: view)
        return view
    }
}

@available(*, deprecated, message: "Use GravityItem")
public protocol Gravity: AnyObject {
    var heaviness: Int { get set }
    func getHeaviness() -> Int
}

public typealias GravityTableCellGenerator = TableCellGenerator & GravityItem
