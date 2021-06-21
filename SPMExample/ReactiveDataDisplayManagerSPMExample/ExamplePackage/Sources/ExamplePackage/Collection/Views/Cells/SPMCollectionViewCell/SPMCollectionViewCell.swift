//
//  TitleCollectionViewCell.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Ivan Smetanin on 27/01/2018.
//  Copyright © 2018 Alexander Kravchenkov. All rights reserved.
//

import UIKit
import ReactiveDataDisplayManager

class SPMCollectionViewCell: UICollectionViewCell, ConfigurableItem {

    // MARK: - IBOutlets

    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Configurable

    func configure(with title: String) {
        titleLabel.text = title
    }

}
