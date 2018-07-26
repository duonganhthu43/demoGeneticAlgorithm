//
//  ViewController.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/22/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Cocoa
import PureLayout

class ViewController: NSViewController {
    
    override func viewDidAppear() {
        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
            NSNumber(integerLiteral: Int(presOptions.rawValue))]
        //self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.wantsLayer = true
        let demo = Demo()
        let leftView = CustomStackView()
        leftView.orientation = .vertical
        leftView.instricsicWidth = 3
        let rightView = CustomStackView()
        rightView.instricsicWidth = 1
        rightView.backgroundColor = NSColor.green
        
        let stackView = NSStackView(views: [leftView, rightView])
        stackView.orientation = .horizontal
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)
        let items = demo.generateItems(quantity: 10)
        let process = GeneticProcess(items: items)
        let population = process.executeSingleRound()
        
        // create horizontalStack
        let chroViews = population.map { (chro) -> ChromosomePresentView in
            return ChromosomePresentView(chromosome: chro)
        }
        let chroStack = NSStackView(views: chroViews)
        chroStack.orientation = .horizontal
        stackView.distribution = .fillProportionally
        let inputView = InputPresentView(items: items)
        leftView.addView(inputView, in: .top)
        leftView.addArrangedSubview(chroStack)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
            rightView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
            leftView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
        }
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    // Mark: Properties
//    let btnRun: NSButton = createButton()
}

extension ViewController {
    func createButton()-> NSButton {
        let button = NSButton()
        button.title = "Run"
        return button
    }
}
extension NSView {
    var backgroundColor: NSColor? {
        get {
            guard let color = layer?.backgroundColor else { return nil }
            return NSColor(cgColor: color)
        }
        set {
            wantsLayer = true
            layer?.backgroundColor = newValue?.cgColor
        }
    }
}
