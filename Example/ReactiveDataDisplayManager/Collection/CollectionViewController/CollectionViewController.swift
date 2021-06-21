//
//  CollectionViewController.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Ivan Smetanin on 27/01/2018.
//  Copyright © 2018 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

class CollectionViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Private Properties

    private lazy var adapter = collectionView.rddm.baseBuilder
        .add(plugin: .selectable())
        .build()

    private lazy var titles: [String] = ["One", "Two", "Three", "Four"]

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        fillAdapter()
    }

    // MARK: - Private methods

    /// This method is used to fill adapter
    private func fillAdapter() {
        let header = TitleCollectionHeaderGenerator(title: "Header")
        adapter.addSection(.init(header: header, footer: nil))

        for title in titles {
            // Create generator
            let generator = TitleCollectionViewCell.rddm.baseGenerator(with: title)
            generator.didSelectEvent += {
                debugPrint("\(title) selected")
            }
            // Add generator to adapter
            adapter.addCellGenerator(generator)
        }

        // Tell adapter that we've changed generators
        adapter.forceRefill()
    }

}
