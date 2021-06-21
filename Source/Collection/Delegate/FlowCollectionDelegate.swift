//
//  FlowCollectionDelegate.swift
//  ReactiveDataDisplayManager
//
//  Created by Vadim Tikhonov on 12.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

open class FlowCollectionDelegate: BaseCollectionDelegate { }

// MARK: - UICollectionViewDelegateFlowLayout

extension FlowCollectionDelegate: UICollectionViewDelegateFlowLayout {

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let sizableCell = manager?.generators[indexPath.section][indexPath.row] as? SizableItem {
            return sizableCell.getSize()
        }

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.itemSize
        }

        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             insetForSectionAt section: Int) -> UIEdgeInsets {

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.sectionInset
        }

        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumLineSpacingForSectionAt section: Int) -> CGFloat {

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.minimumLineSpacing
        }

        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.minimumInteritemSpacing
        }

        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForHeaderInSection section: Int) -> CGSize {

        if let size = manager?.sections[section].header?.size(collectionView, forSection: section) {
            return size
        }

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.headerReferenceSize
        }

        return .zero
    }

    open func collectionView(_ collectionView: UICollectionView,
                             layout collectionViewLayout: UICollectionViewLayout,
                             referenceSizeForFooterInSection section: Int) -> CGSize {

        if let size = manager?.sections[section].footer?.size(collectionView, forSection: section) {
            return size
        }

        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            return flowLayout.footerReferenceSize
        }

        return .zero
    }

}
