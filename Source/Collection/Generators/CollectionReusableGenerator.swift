//
//  CollectionReusableGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

/// Protocol that incapsulated type of Header
public protocol CollectionReusableGenerator: ViewRegistableItem {

    var identifier: UICollectionReusableView.Type { get }

    func generate(collectionView: UICollectionView, for indexPath: IndexPath) -> UICollectionReusableView

    func size(_ collectionView: UICollectionView, forSection section: Int) -> CGSize
}
