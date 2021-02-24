//
//  VerticalSizableTextGenerator.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Vadim Tikhonov on 11.02.2021.
//  Copyright © 2021 Alexander Kravchenkov. All rights reserved.
//

import ReactiveDataDisplayManager

final class VerticalSizableTextGenerator: BaseCollectionCellGenerator<SizableCollectionViewCell> {

    // MARK: - Private Properties

    private let text: String
    private let maxWight: CGFloat

    // MARK: - Initializers

    public init(with text: String, maxWight: CGFloat) {
        self.text = text
        self.maxWight = maxWight
        super.init(with: text)
    }

}

// MARK: - SizableCollectionCellGenerator

extension VerticalSizableTextGenerator: SizableCollectionCellGenerator {

    func getSize() -> CGSize {
        return SizableCollectionViewCell.getCellSize(for: text, withWight: maxWight)
    }

}
