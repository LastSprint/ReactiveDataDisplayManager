//
//  SPMHeaderCollectionGenerator.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Vadim Tikhonov on 09.02.2021.
//  Copyright © 2021 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

final class SPMHeaderCollectionGenerator {

    // MARK: - Constants

    private let title: String

    // MARK: - Initialization and deinitialization

    init(title: String) {
        self.title = title
    }

}

// MARK: - CollectionHeaderGenerator

extension SPMHeaderCollectionGenerator: CollectionHeaderGenerator {

    var identifier: UICollectionReusableView.Type {
        return SPMHeaderCollectionView.self
    }

    func size(_ collectionView: UICollectionView, forSection section: Int) -> CGSize {
        // This method used only with default layout.
        return .zero
    }

}

// MARK: - ViewBuilder

extension SPMHeaderCollectionGenerator: ViewBuilder {

    func build(view: SPMHeaderCollectionView) {
        view.fill(title: title)
    }

}
