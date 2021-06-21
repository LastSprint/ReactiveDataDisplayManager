//
//  FooterView.swift
//  ReactiveDataDisplayManagerExample
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

final class FooterView: UIView {

    // MARK: - IBOutlet

    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - Internal Methods

    func configure(with title: String) {
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .light)
    }

}
