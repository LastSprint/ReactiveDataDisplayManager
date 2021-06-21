//
//  Array.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Anton Eysner on 14.04.2021.
//

import ReactiveDataDisplayManager

extension Array {

    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }

}

extension Array where Element == CollectionSection {

    var asDiffableItemSources: [DiffableItemSource] {
        return compactMap { $0.header as? DiffableItemSource }
    }

}

extension Array where Element == [DiffableItemSource] {

    var asDiffableItems: [[DiffableItem]] {
        return map {
            $0.compactMap { $0.item }
        }
    }

}
