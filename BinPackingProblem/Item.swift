//
//  Item.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/25/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
public struct Item {
    init(width: Int, height: Int, name: String, color: CGColor? = nil) {
        self.width = width
        self.height = height
        self.name = name
        self.color = color
    }
    let name: String
    let color: CGColor?
    var width: Int
    var height: Int
}
