//
//  EmptyCollectionHeaderGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Anton Dryakhlykh on 25.11.2019.
//  Copyright © 2019 Александр Кравченков. All rights reserved.
//

import UIKit

public class EmptyCollectionHeaderGenerator: CollectionHeaderGenerator {

    public let uuid = UUID().uuidString

    public func size(_ collectionView: UICollectionView, forSection section: Int) -> CGSize {
        return .zero
    }

    public func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                     withReuseIdentifier: self.identifier.nameOfClass,
                                                                     for: indexPath)
        return header
    }

    public func registerHeader(in collectionView: UICollectionView) {
        collectionView.register(identifier, forCellWithReuseIdentifier: identifier.nameOfClass)
    }

    public var identifier: UICollectionReusableView.Type {
        return UICollectionReusableView.self
    }
}

// MARK: - DiffableItemSource

extension EmptyCollectionHeaderGenerator: DiffableItemSource {

    public var item: DiffableItem {
        DiffableItem(id: uuid, state: .init("RDDM.Diffable.EmptySection.Header"))
    }

}
