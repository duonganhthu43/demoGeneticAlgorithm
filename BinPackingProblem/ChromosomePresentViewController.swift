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
    private var chromosome: Chromosome?
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = NSColor(cgColor: CGColor.clear)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience init(chromosome: Chromosome) {
        self.init(frame: CGRect.zero)
        self.chromosome = chromosome
        backgroundColor = NSColor.white
        self.layer?.borderWidth = 0.5
        self.layer?.borderColor = NSColor.black.withAlphaComponent(0.5).cgColor
    }
    
    override public func draw(_ dirtyRect: NSRect) {
        guard let chromosome = self.chromosome else {
            return
        }
        let itemsView = chromosome.items.map { item -> NSView in
            let itemView = NSView()
            itemView.autoSetDimensions(to: CGSize(width: item.width, height: item.height))
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
                stackView.alignment = expression[i] == "V" ?NSLayoutConstraint.Attribute.bottom: NSLayoutConstraint.Attribute.right
                stackView.orientation = expression[i] == "V" ?NSUserInterfaceLayoutOrientation.vertical : NSUserInterfaceLayoutOrientation.horizontal
                stack.push(stackView)
            }
        }
        let finalStackView = stack.top
        finalStackView?.backgroundColor = NSColor.clear
         addSubview(finalStackView!)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            //finalStackView?.autoCenterInSuperview()
            finalStackView?.autoPinEdgesToSuperviewEdges()
        }
    }
}
