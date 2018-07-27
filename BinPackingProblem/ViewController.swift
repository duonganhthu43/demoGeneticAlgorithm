//
//  ViewController.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/22/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Cocoa
import PureLayout
import RxSwift
import RxCocoa


class ViewController: NSViewController {
    let disposeBag = DisposeBag()
    var chromosomeView: [NSView] = []
    var lstChromosome: [Chromosome] = []
    var items: [Item] = []
    let process: GeneticProcess
    let demo = Demo()
    var counter = 0
    var lstMutationController: ListChromosomePresentViewController
    var lstPopulationController: ListChromosomePresentViewController
    var inputView : InputPresentView
    
    init() {
        items = demo.generateItems(quantity: 10)
        process = GeneticProcess(items: items)
        lstMutationController = ListChromosomePresentViewController(title: "Mutation ", items: items, lstChromosome: process.mutationsDriver)
        lstPopulationController = ListChromosomePresentViewController(title: "Population ", items: items, lstChromosome: process.populationDriver)
        inputView = InputPresentView(items: items)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        items = demo.generateItems(quantity: 10)
        process = GeneticProcess(items: items)
        lstMutationController = ListChromosomePresentViewController(title: "Mutation ", items: items, lstChromosome: process.mutationsDriver)
        lstPopulationController = ListChromosomePresentViewController(title: "Population ", items: items, lstChromosome: process.populationDriver)
        inputView = InputPresentView(items: items)
        super.init(coder: coder)
    }
    
    override func viewDidAppear() {
        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
            NSNumber(integerLiteral: Int(presOptions.rawValue))]
        //self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(lstPopulationController)
        addChildViewController(lstMutationController)
        let leftView = CustomStackView()
        leftView.instricsicWidth = 4
        leftView.orientation = .vertical
        leftView.distribution = .fillEqually
        leftView.spacing = 10
        leftView.addArrangedSubview(inputView)
        leftView.addArrangedSubview(lstPopulationController.view)
        leftView.addArrangedSubview(lstMutationController.view)
//        lstPopulationController.view.autoresizingMask = [.width, .height]
//        lstMutationController.view.autoresizingMask = [.width, .height]
        
        let btn = createButton()
        
        let buttonStack = CustomStackView()
        buttonStack.instricsicWidth = 1
        buttonStack.orientation = .horizontal
        buttonStack.alignment = .centerX
        buttonStack.addArrangedSubview(btn)
        
        let leftStackOuterView = CustomStackView()
        leftStackOuterView.instricsicWidth = 3
        leftStackOuterView.orientation = .vertical
        leftStackOuterView.distribution = .gravityAreas
        leftStackOuterView.addArrangedSubview(buttonStack)
        leftStackOuterView.addArrangedSubview(leftView)

        // Notify Child View Controller
        lstPopulationController.view.viewDidMoveToSuperview()
        lstMutationController.view.viewDidMoveToSuperview()

        let rightView = CustomStackView()
        rightView.instricsicWidth = 1
        rightView.backgroundColor = NSColor.black
        
        
        
        let logTextField = NSTextView()
        logTextField.isEditable = false
        logTextField.isFieldEditor = false
        logTextField.drawsBackground = false
        logTextField.font = NSFont.systemFont(ofSize: 15)
        logTextField.backgroundColor = NSColor.black
        logTextField.textColor = NSColor.white
        
        let scrollTextView :NSScrollView = {
            let v = NSScrollView()
            v.translatesAutoresizingMaskIntoConstraints = false
            v.hasVerticalRuler = false
            v.hasVerticalScroller = true
            return v
        }()
        scrollTextView.documentView = logTextField
        scrollTextView.backgroundColor = NSColor.red

        
        rightView.addArrangedSubview(scrollTextView)
        
        
        
        process.mutationLogDriver.drive(onNext: { (text) in
            logTextField.string = logTextField.string + text
        }).disposed(by: disposeBag)
        
        let stackView = NSStackView(views: [leftStackOuterView, rightView])
        stackView.orientation = .horizontal
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10))
            rightView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
            leftStackOuterView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
            logTextField.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
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
        button.target = self
        button.action = #selector(ViewController.action)
        return button
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    @objc func action() {
        self.process.executeSingleRound()
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
