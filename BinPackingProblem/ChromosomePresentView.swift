//
//  ChromosomePresentViewController.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/26/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import Cocoa
import PureLayout
import RxSwift
class ChromosomePresentView: NSView {
    var chromosome: Chromosome? {
        didSet {
            needsDisplay = true
        }
    }
    
    private var showOriginalSize = false
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = NSColor(cgColor: CGColor.clear)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(chromosome: Chromosome, showOriginalSize: Bool = false) {
        self.init(frame: CGRect.zero)
        self.chromosome = chromosome
        self.showOriginalSize = showOriginalSize
        backgroundColor = NSColor.white
        self.layer?.borderWidth = 0.5
        self.layer?.borderColor = NSColor.black.withAlphaComponent(0.5).cgColor
        
        guard let chromosome = self.chromosome else {
            return
        }
        let items = chromosome.items
        let itemsView = items.map { item -> NSView in
            let itemView = NSView()
            //            itemView.autoSetDimensions(to: CGSize(width: showOriginalSize ? item.displayWidth :  item.displayWidth, height: showOriginalSize ? item.height
            //                : item.displayHeight))
            itemView.backgroundColor = NSColor(cgColor: item.color!)
            return itemView
        }
        let expression = chromosome.Expression
        var stack = Stack<NSView>()
        for i in 0..<expression.count {
            if let itemIndex = Int(expression[i]) {
                stack.push(itemsView[itemIndex])
            } else {
                let left = stack.pop()
                let right = stack.pop()
                let stackView = NSStackView(views: [left!, right!])
                stackView.spacing = 0
                stackView.alignment = expression[i] == OperatorType.Vertical.rawValue ?NSLayoutConstraint.Attribute.bottom: NSLayoutConstraint.Attribute.right
                stackView.orientation = expression[i] ==  OperatorType.Vertical.rawValue ?NSUserInterfaceLayoutOrientation.vertical : NSUserInterfaceLayoutOrientation.horizontal
                stack.push(stackView)
            }
        }
        let finalStackView = stack.top
        finalStackView?.backgroundColor = NSColor.clear
        addSubview(finalStackView!)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            finalStackView?.autoPinEdgesToSuperviewEdges()
            for i in 0..<itemsView.count {
                itemsView[i].autoSetDimensions(to: CGSize(width: showOriginalSize ? items[i].displayWidth :  items[i].displayWidth, height: showOriginalSize ? items[i].height
                    : items[i].displayHeight))
            }
        }
    }
//    override public func draw(_ dirtyRect: NSRect) {
//
//    }
    
}
