//
//  MainSPMCollectionViewController.swift
//  ReactiveDataDisplayManager
//
//  Created by Владислав Янковенко on 10.03.2021.
//  Copyright © 2017 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

/// This class is for displaying data only
/// The examples of `Swift Package Manager` support located in:
/// - headers: `SPMHeaderCollectionGenerator.swift`
/// - cells: `SPMCollectionViewCell.swift`
/// For correct work, you must specify your SPM module for all `.xib` files and `.storyboard`
/// In all descendants of an `ConfigurableItem`, you must use the static method `bundle()` and return `Bundle.module`
/// In all views related to `.xib`, you also need to specify `Bundle.module`
@available(iOS 14.0, *)
class MainSPMCollectionViewController: UIViewController {

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
private extension MainSPMCollectionViewController {

    func fillAdapter() {
        let header = SPMHeaderCollectionGenerator(title: "Section header")
        adapter.addSection(.init(header: header, footer: nil))

        for title in titles {
            let generator = SPMCollectionViewCell.rddm.baseGenerator(with: title)
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

// MARK: - Appearance

@available(iOS 14.0, *)
private extension UICollectionLayoutListConfiguration.Appearance {

    var title: String {
        switch self {
        case .plain:
            return "Plain"
        case .sidebarPlain:
            return "Sidebar Plain"
        case .sidebar:
            return "Sidebar"
        case .grouped:
            return "Grouped"
        case .insetGrouped:
            return "Inset Grouped"
        @unknown default:
            return ""
        }
    }

    var next: UICollectionLayoutListConfiguration.Appearance {
        switch self {
        case .plain:
            return .sidebarPlain
        case .sidebarPlain:
            return .sidebar
        case .sidebar:
            return .grouped
        case .grouped:
            return .insetGrouped
        case .insetGrouped:
            return .plain
        @unknown default:
            return .plain
        }
    }

}
