//
//  CollectionSection.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import Foundation

public struct CollectionSection {

    // MARK: - Properties

    public let header: CollectionHeaderGenerator?
    public let footer: CollectionFooterGenerator?

    // MARK: - Initialisation

    public init(header: CollectionHeaderGenerator?,
                footer: CollectionFooterGenerator?) {
        self.header = header
        self.footer = footer
    }

}

// MARK: - Defaults

public extension CollectionSection {

    static func empty() -> CollectionSection {
        .init(header: EmptyCollectionHeaderGenerator(), footer: EmptyCollectionFooterGenerator())
    }

}
