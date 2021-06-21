//
//  TableSection.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import Foundation

public struct TableSection {

    // MARK: - Properties

    public let header: TableHeaderGenerator?
    public let footer: TableHeaderGenerator?

    // MARK: - Initialisation

    public init(header: TableHeaderGenerator?,
                footer: TableHeaderGenerator?) {
        self.header = header
        self.footer = footer
    }

}

// MARK: - Defaults

public extension TableSection {

    static func empty() -> TableSection {
        .init(header: EmptyTableHeaderGenerator(), footer: EmptyTableHeaderGenerator())
    }

}
