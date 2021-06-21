//
//  BaseTableDelegate.swift
//  ReactiveDataDisplayManager
//
//  Created by Aleksandr Smirnov on 02.11.2020.
//  Copyright © 2020 Александр Кравченков. All rights reserved.
//

import UIKit

/// Base implementation for `UITableViewDelegate` protocol.
open class BaseTableDelegate: NSObject, TableDelegate {

    // MARK: - Properties

    public weak var manager: BaseTableManager?

    public var estimatedHeight: CGFloat = 40

    public var tablePlugins = PluginCollection<BaseTablePlugin<TableEvent>>()
    public var scrollPlugins = PluginCollection<BaseTablePlugin<ScrollEvent>>()
    public var movablePlugin: TableMovableDelegate?

    @available(iOS 11.0, *)
    public var swipeActionsPlugin: TableSwipeActionsConfigurable? {
        set { _swipeActionsPlugin = newValue }
        get { _swipeActionsPlugin as? TableSwipeActionsConfigurable }
    }

    // MARK: - Private Properties

    private var _swipeActionsPlugin: TableFeaturePlugin?

}

// MARK: - TableBuilderConfigurable

extension BaseTableDelegate {

    open func configure<T>(with builder: TableBuilder<T>) where T: BaseTableManager {

        movablePlugin = builder.movablePlugin
        tablePlugins = builder.tablePlugins
        scrollPlugins = builder.scrollPlugins

        if #available(iOS 11.0, *) {
            swipeActionsPlugin = builder.swipeActionsPlugin as? TableSwipeActionsConfigurable
        }

        manager = builder.manager

        tablePlugins.setup(with: builder.manager)
        scrollPlugins.setup(with: builder.manager)
    }

}

// MARK: - UITableViewDelegate

extension BaseTableDelegate {

    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .willDisplayCell(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        tablePlugins.process(event: .willDisplayHeader(section), with: manager)
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        tablePlugins.process(event: .didEndDisplayHeader(section), with: manager)
    }

    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .didEndDisplayCell(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        tablePlugins.process(event: .willDisplayFooter(section), with: manager)
    }

    open func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        tablePlugins.process(event: .didEndDisplayFooter(section), with: manager)
    }

    open func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return movablePlugin?.canFocusRow(at: indexPath, with: manager) ?? false
    }

    open func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }

    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        manager?.generators[indexPath.section][indexPath.row].cellHeight ?? UITableView.automaticDimension
    }

    open func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        manager?.generators[indexPath.section][indexPath.row].estimatedCellHeight ?? estimatedHeight
    }

    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let manager = manager, section <= manager.sections.count - 1 else {
            return nil
        }
        return manager.sections[section].header?.generate()
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let manager = manager, section <= manager.sections.count - 1 else {
            return 0.1
        }
        return manager.sections[section].header?.height(tableView, forSection: section) ?? 0.1
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let manager = manager, section <= manager.sections.count - 1 else {
            return nil
        }
        return manager.sections[section].footer?.generate()
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let manager = manager, section <= manager.sections.count - 1 else {
            return 0.1
        }
        return manager.sections[section].footer?.height(tableView, forSection: section) ?? 0.1
    }

    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .didSelect(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .didDeselect(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        tablePlugins.process(event: .didBeginMultipleSelectionInteraction(indexPath), with: manager)
    }

    open func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView) {
        tablePlugins.process(event: .didEndMultipleSelectionInteraction, with: manager)
    }

    open func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        tablePlugins.process(event: .accessoryButtonTapped(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .didHighlight(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .didUnhighlight(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        tablePlugins.process(event: .willBeginEditing(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        tablePlugins.process(event: .didEndEditing(indexPath), with: manager)
    }

    open func tableView(_ tableView: UITableView,
                        didUpdateFocusIn context: UITableViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator) {
        tablePlugins.process(event: .didUpdateFocus(context: context, coordinator: coordinator), with: manager)
    }

    @available(iOS 11.0, *)
    open func tableView(_ tableView: UITableView,
                        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return swipeActionsPlugin?.leadingSwipeActionsConfigurationForRow(at: indexPath, with: manager)
    }

    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView,
                          trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return swipeActionsPlugin?.trailingSwipeActionsConfigurationForRow(at: indexPath, with: manager)
    }

}

// MARK: UIScrollViewDelegate

extension BaseTableDelegate {

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didScroll, with: manager)
    }

    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didScrollToTop, with: manager)
    }

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .willBeginDragging, with: manager)
    }

    open func scrollViewWillEndDragging(_ scrollView: UIScrollView,
                                        withVelocity velocity: CGPoint,
                                        targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollPlugins.process(event: .willEndDragging(velocity: velocity,
                                                      targetContentOffset: targetContentOffset), with: manager)
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollPlugins.process(event: .didEndDragging(decelerate), with: manager)
    }

    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .willBeginDecelerating, with: manager)
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didEndDecelerating, with: manager)
    }

    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollPlugins.process(event: .willBeginZooming(view), with: manager)
    }

    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollPlugins.process(event: .didEndZooming(view: view, scale: scale), with: manager)
    }

    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didZoom, with: manager)
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didEndScrollingAnimation, with: manager)
    }

    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        scrollPlugins.process(event: .didChangeAdjustedContentInset, with: manager)
    }

}
