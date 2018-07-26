//
//  InputPresentViewController.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/26/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import Cocoa
import PureLayout
import RxSwift
public class InputPresentView: NSView {
    private var items: [Item] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = NSColor(cgColor: CGColor.clear)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(items: [Item]) {
        self.init(frame: CGRect.zero)
        self.items = items
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        var viewItems  = items.map{ NSView(frame: CGRect(x: 0, y: 0, width: $0.width, height: $0.height))}
        for i in 0..<viewItems.count {
            viewItems[i].backgroundColor = NSColor(cgColor: items[i].color!)
            viewItems[i].autoSetDimensions(to: CGSize(width: items[i].width*2, height: items[i].height*2))
        }
        let label = NSTextField(string: "INPUT")
        label.isEditable = false
        label.drawsBackground = false
        label.isBordered = false
        let stackView = NSStackView(views: viewItems)
        stackView.orientation = .horizontal
        stackView.spacing = 2
        stackView.distribution = .fillProportionally
        let finalStack = NSStackView(views: [label, stackView])
        finalStack.orientation = .vertical
        finalStack.spacing = 10
        

        
        addSubview(finalStack)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            finalStack.autoPinEdgesToSuperviewEdges(with: NSEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))

        }
    }
}
