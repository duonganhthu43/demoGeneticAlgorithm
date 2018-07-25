//
//  Item.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/25/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
public class Item {
    init(width: Int, height: Int, name: String) {
        self.width = width
        self.height = height
        self.name = name
    }
    let name: String
    var width: Int
    var height: Int
}
