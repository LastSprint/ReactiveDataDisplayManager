//
//  CollectionFooterGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

/// Protocol that incapsulated type of Footer
public protocol CollectionFooterGenerator: CollectionReusableGenerator {

    func registerFooter(in collectionView: UICollectionView)
}

// MARK: - ViewBuilder

public extension CollectionFooterGenerator where Self: ViewBuilder {

    func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
                                                                           withReuseIdentifier: self.identifier.nameOfClass,
                                                                           for: indexPath) as? Self.ViewType else {
            return UICollectionReusableView()
        }

        self.build(view: header)

        return header as? UICollectionReusableView ?? UICollectionReusableView()
    }

    func registerFooter(in collectionView: UICollectionView) {
        collectionView.registerNib(self.identifier, kind: UICollectionView.elementKindSectionFooter, bundle: Self.bundle())
    }
}
