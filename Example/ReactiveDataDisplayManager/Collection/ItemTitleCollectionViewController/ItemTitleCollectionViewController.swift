//
//  ItemTitleCollectionViewController.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Anton Eysner on 18.02.2021.
//  Copyright © 2021 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

class ItemTitleCollectionViewController: UIViewController {

    // MARK: - Constants

    private enum Constants {
        static let sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }

    // MARK: - IBOutlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Private Properties

    private var appearance: Appearance = .grid

    private lazy var adapter = collectionView.rddm.baseBuilder
        .add(featurePlugin: .sectionTitleDisplayable())
        .build()

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Collection with item index titles"

        configureLayoutFlow(with: appearance)
        updateBarButtonItem(with: appearance.title)

        fillAdapter()
    }

}

// MARK: - Private methods

private extension ItemTitleCollectionViewController {

    func configureLayoutFlow(with appearance: Appearance) {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.itemSize = appearance.cellSize
        flowLayout.minimumLineSpacing = 10.0
        flowLayout.minimumInteritemSpacing = 10.0
        flowLayout.sectionInset = Constants.sectionInset
        flowLayout.scrollDirection = .vertical

        collectionView.setCollectionViewLayout(flowLayout, animated: true)
    }

    func updateBarButtonItem(with title: String) {
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(changeListAppearance))
        navigationItem.rightBarButtonItem = button
    }

    /// This method is used to fill adapter
    func fillAdapter() {
        let header = TitleCollectionHeaderGenerator(title: "Header")
        adapter.addSection(.init(header: header, footer: nil))

        for index in 0...50 {
            // Create generator
            let generator = TitleCollectionGenerator(model: "Item \(index)", needIndexTitle: index % 2 == 0 ? true : false)

            // Add generator to adapter
            adapter.addCellGenerator(generator)
        }

        // Tell adapter that we've changed generators
        adapter.forceRefill()
    }

    @objc
    func changeListAppearance() {
        switch appearance {
        case .grid:
            let horizontalSectionInset = Constants.sectionInset.left + Constants.sectionInset.right
            let maxWight = UIScreen.main.bounds.width - horizontalSectionInset

            appearance = .table(width: maxWight)
        case .table:
            appearance = .grid
        }

        configureLayoutFlow(with: appearance)
        updateBarButtonItem(with: appearance.title)
    }

}
