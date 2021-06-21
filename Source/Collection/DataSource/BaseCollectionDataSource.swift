//
//  BaseCollectionDataSource.swift
//  ReactiveDataDisplayManager
//
//  Created by Vadim Tikhonov on 09.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

/// Base implementation for `UICollectionViewDataSource` protocol.
open class BaseCollectionDataSource: NSObject, CollectionDataSource {

    // MARK: - Properties

    public var modifier: Modifier<UICollectionView, CollectionItemAnimation>?
    public weak var provider: CollectionGeneratorsProvider?

    public var prefetchPlugins = PluginCollection<BaseCollectionPlugin<PrefetchEvent>>()
    public var collectionPlugins = PluginCollection<BaseCollectionPlugin<CollectionEvent>>()
    public var itemTitleDisplayablePlugin: CollectionItemTitleDisplayable?

}

// MARK: - CollectionBuilderConfigurable

extension BaseCollectionDataSource {

    public func configure<T>(with builder: CollectionBuilder<T>) where T: BaseCollectionManager {

        modifier = CollectionCommonModifier(view: builder.view, animator: builder.animator)

        collectionPlugins = builder.collectionPlugins
        itemTitleDisplayablePlugin = builder.itemTitleDisplayablePlugin

        if #available(iOS 10.0, *) {
            prefetchPlugins = builder.prefetchPlugins
        }

        provider = builder.manager

        prefetchPlugins.setup(with: builder.manager)
        collectionPlugins.setup(with: builder.manager)

    }

}

// MARK: - UICollectionViewDataSource

extension BaseCollectionDataSource {

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return provider?.sections.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let provider = provider, provider.generators.indices.contains(section) else {
            return 0
        }
        return provider.generators[section].count
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let provider = provider else {
            return UICollectionViewCell()
        }
        return provider
            .generators[indexPath.section][indexPath.row]
            .generate(collectionView: collectionView, for: indexPath)
    }

    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView {
        guard let provider = provider else {
            return UICollectionReusableView()
        }

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return provider
                .sections[indexPath.section]
                .header?
                .generate(collectionView: collectionView, for: indexPath) ?? UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            return provider
                .sections[indexPath.section]
                .footer?
                .generate(collectionView: collectionView, for: indexPath) ?? UICollectionReusableView()
        default:
            return UICollectionReusableView()
        }
    }

    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        collectionPlugins.process(event: .move(from: sourceIndexPath, to: destinationIndexPath), with: provider as? BaseCollectionManager)
    }

    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    open func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return itemTitleDisplayablePlugin?.indexTitles(with: provider)
    }

    open func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return itemTitleDisplayablePlugin?.indexPathForIndexTitle(title, at: index, with: provider) ?? IndexPath()
    }

}

// MARK: - UICollectionViewDataSourcePrefetching

extension BaseCollectionDataSource {

    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetchPlugins.process(event: .prefetch(indexPaths), with: provider as? BaseCollectionManager)
    }

    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        prefetchPlugins.process(event: .cancelPrefetching(indexPaths), with: provider as? BaseCollectionManager)
    }

}
