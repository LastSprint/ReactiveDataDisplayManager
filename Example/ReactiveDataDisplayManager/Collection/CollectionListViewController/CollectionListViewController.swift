//
//  CollectionListViewController.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Vadim Tikhonov on 09.02.2021.
//  Copyright © 2021 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

@available(iOS 14.0, *)
class CollectionListViewController: UIViewController {

    // MARK: - IBOutlets

    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Private Properties

    private lazy var adapter = collectionView.rddm.baseBuilder
        .add(plugin: .selectable())
        .build()

    private var titles = ["Item 1", "Item 2", "Item 3", "Item 4"]

    private var appearance = UICollectionLayoutListConfiguration.Appearance.plain

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()
        fillAdapter()

        configureLayoutFlow(with: appearance)
        updateBarButtonItem(with: appearance.title)
    }

}

// MARK: - Private Methods

@available(iOS 14.0, *)
private extension CollectionListViewController {

    func fillAdapter() {
        let header = HeaderCollectionListGenerator(title: "Section header")
        adapter.addSection(.init(header: header, footer: nil))

        for title in titles {
            let generator = TitleCollectionListCell.rddm.baseGenerator(with: title)
            generator.didSelectEvent += { debugPrint("\(title) selected") }
            adapter.addCellGenerator(generator)
        }

        adapter.forceRefill()
    }

    func configureLayoutFlow(with appearance: UICollectionLayoutListConfiguration.Appearance) {
        var configuration = UICollectionLayoutListConfiguration(appearance: appearance)
        configuration.headerMode = .supplementary
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        collectionView.setCollectionViewLayout(layout, animated: false)
    }

    func updateBarButtonItem(with title: String) {
        let button = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(changeListAppearance))
        navigationItem.rightBarButtonItem = button
    }

    @objc
    func changeListAppearance() {
        appearance = appearance.next

        configureLayoutFlow(with: appearance)
        updateBarButtonItem(with: appearance.title)
    }

}
