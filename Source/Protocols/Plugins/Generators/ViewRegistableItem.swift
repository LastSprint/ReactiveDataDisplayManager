//
//  ViewRegistableItem.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

/// Protocol to specify bundle where we can register generated view.
public protocol ViewRegistableItem: AnyObject {

    /// Method for SPM support
    ///
    /// If you use SPM return Bundle.module
    static func bundle() -> Bundle?
}

// MARK: - Defaults

public extension ViewRegistableItem {

    static func bundle() -> Bundle? {
        return nil
    }

}
