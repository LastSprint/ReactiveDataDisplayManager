//
//  GravityTableHeaderGenerator.swift
//  ReactiveDataDisplayManager
//
//  Created by Никита Коробейников on 18.06.2021.
//

import UIKit

open class GravityTableHeaderGenerator: TableHeaderGenerator, GravityItem {
    open var heaviness = 0

    open func getHeaviness() -> Int {
        preconditionFailure("\(#function) must be overriden in child")
    }
}

// MARK: - Equatable

extension GravityTableHeaderGenerator: Equatable {
    public static func == (lhs: GravityTableHeaderGenerator, rhs: GravityTableHeaderGenerator) -> Bool {
        return lhs.generate() == rhs.generate() && lhs.getHeaviness() == rhs.getHeaviness()
    }
}
