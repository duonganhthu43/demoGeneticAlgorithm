//
//  HeaderView.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/27/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import Cocoa

class HeaderView: NSView {
    
    lazy var titleTextField: NSTextField? = {
        for view in self.subviews {
            if view is NSTextField {
                return view as? NSTextField
            }
        }
        return nil
    }()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        // Drawing code here.
    }
    
}
