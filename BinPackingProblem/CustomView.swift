//
//  CustomView.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/26/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import Cocoa

class CustomStackView: NSStackView {
    var instricsicHeight = 1.0
    var instricsicWidth = 1.0
    override var intrinsicContentSize: NSSize {
        return NSSize(width: instricsicWidth, height: instricsicHeight)
    }
}
