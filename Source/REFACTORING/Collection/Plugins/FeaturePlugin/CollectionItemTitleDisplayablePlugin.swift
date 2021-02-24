//
//  CollectionItemTitleDisplayablePlugin.swift
//  ReactiveDataDisplayManager
//
//  Created by Anton Eysner on 18.02.2021.
//  Copyright © 2021 Александр Кравченков. All rights reserved.
//

import UIKit

/// Use this plugin if you need to configure the display of itemIndexTitle
open class CollectionItemTitleDisplayablePlugin: CollectionItemTitleDisplayable {

    // MARK: - Initialization

    public init() {}

    // MARK: - SectionTitleDisplayable

    open func indexTitles(with provider: CollectionGeneratorsProvider?) -> [String]? {
        let generators = provider?.generators.reduce([], +)

        let itemTitles = generators?.compactMap { generator -> String? in
            guard let generator = generator as? IndexTitleDisplayble else {
                return nil
            }
            return generator.needIndexTitle ? generator.title : nil
        }

        return itemTitles
    }

    open func indexPathForIndexTitle(_ title: String, at index: Int, with provider: CollectionGeneratorsProvider?) -> IndexPath {
        return getGeneratorIndexPath(with: title, for: provider)
    }

}

// MARK: - Private Methods

private extension CollectionItemTitleDisplayablePlugin {

    func getGeneratorIndexPath(with title: String, for provider: CollectionGeneratorsProvider?) -> IndexPath {
        guard let generators = provider?.generators else { return IndexPath() }
        for (sectionIndex, section) in generators.enumerated() {
            let generatorIndex = section.index(where: { ($0 as? IndexTitleDisplayble)?.title == title })

            if let generatorIndex = generatorIndex {
                return IndexPath(item: generatorIndex, section: sectionIndex)
            }
        }
        return IndexPath()
    }

}