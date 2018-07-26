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

class ViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout  {
    lazy var collectionView = createCollectionView()
    var chromosomeView: [NSView] = []
    var lstChromosome: [Chromosome] = []
    var items: [Item] = []
    let demo = Demo()

    override func viewDidAppear() {
        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
            NSNumber(integerLiteral: Int(presOptions.rawValue))]
        //self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        items = demo.generateItems(quantity: 10)
        let process = GeneticProcess(items: items)
        let population = process.executeSingleRound()
        lstChromosome = population
        // create horizontalStack
        let chroViews = population.map { (chro) -> ChromosomePresentView in
            return ChromosomePresentView(chromosome: chro)
        }
        chromosomeView = chroViews
        self.view.wantsLayer = true
        
        let scrollView:NSScrollView = {
            let v = NSScrollView(frame: NSRect.zero)
            v.translatesAutoresizingMaskIntoConstraints = false
            v.hasVerticalRuler = false
            v.hasVerticalScroller = true
            return v
        }()
        collectionView.register(ChromosomeCollectionViewItem.self, forItemWithIdentifier: NSUserInterfaceItemIdentifier("item"))
        collectionView.dataSource = self
        collectionView.delegate = self
        scrollView.documentView = collectionView
        let btn = createButton()
        let stackView = NSStackView()
        stackView.orientation = .horizontal
        stackView.distribution = .fillProportionally
        stackView.addArrangedSubview(btn)
        stackView.addArrangedSubview(scrollView)
        view.addSubview(stackView)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges()
        }
        //view.pbbPlace(scrollView, at:(0,0,0,0))
        
        
//        let demo = Demo()
//        let leftView = CustomStackView()
//        leftView.orientation = .vertical
//        leftView.instricsicWidth = 3
//        let rightView = CustomStackView()
//        rightView.instricsicWidth = 1
//        rightView.backgroundColor = NSColor.green
//
//        let stackView = NSStackView(views: [leftView, rightView])
//        stackView.orientation = .horizontal
//        stackView.distribution = .fillProportionally
//        view.addSubview(stackView)
//        let items = demo.generateItems(quantity: 10)
//        let process = GeneticProcess(items: items)
//        let population = process.executeSingleRound()
//
//        // create horizontalStack
//        let chroViews = population.map { (chro) -> ChromosomePresentView in
//            return ChromosomePresentView(chromosome: chro)
//        }
//        let chroStack = NSStackView(views: chroViews)
//        chroStack.orientation = .horizontal
//        stackView.distribution = .fillProportionally
//        let inputView = InputPresentView(items: items)
//        leftView.addView(inputView, in: .top)
//        leftView.addArrangedSubview(chroStack)
//        NSLayoutConstraint.autoCreateAndInstallConstraints {
//            stackView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsets(top: 10, left: 10, bottom: 0, right: 10))
//            rightView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
//            leftView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
//        }
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
    
    @objc func action() {
        for _ in 0...10 {
        let process = GeneticProcess(items: items)
        let population = process.executeSingleRound()
        lstChromosome = population
        collectionView.reloadData()
            
        }
    }
    
    func createCollectionView()-> NSCollectionView {
        let collectionView = NSCollectionView()
        collectionView.wantsLayer = true
        //collectionView.layer!.backgroundColor = NSColor.blue.withAlphaComponent(0.2).cgColor
        collectionView.isSelectable = true
        collectionView.allowsEmptySelection = false
        collectionView.delegate = self
        
        let l = NSCollectionViewFlowLayout()
        l.minimumInteritemSpacing = 10
        l.minimumLineSpacing = 10
        l.scrollDirection = NSCollectionView.ScrollDirection.vertical
        l.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //l.itemSize = CGSize(width: 150, height: 150)
        collectionView.collectionViewLayout = l
        return collectionView
    }
}

extension ViewController {
    // MARK: NSCollectionViewDataSource
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return chromosomeView.count
        //return strings.count * 5
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let chro =  lstChromosome[indexPath.item]
        let lo = LabelObject(title: String.init(format: "Area: %d \n Width: %d Height: %d", chro.Area, chro.Size.0, chro.Size.1))
        let item = collectionView.makeItem(withIdentifier:NSUserInterfaceItemIdentifier("item"), for: indexPath) as! ChromosomeCollectionViewItem
        item.labelObject = lo
        item.chromosomeView = chromosomeView[indexPath.item]
        return item
    }
//
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let chro = lstChromosome[indexPath.item]
        return NSSize(width: chro.Size.0, height: (chro.Size.1))
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 20)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 20)
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        var nibName: String?
        if kind == NSCollectionView.SupplementaryElementKind.sectionHeader {
            nibName = "Header"
        } else if kind == NSCollectionView.SupplementaryElementKind.sectionFooter {
            nibName = "Footer"
        }
        let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: nibName!), for: indexPath)
        
        view.wantsLayer = true
        //view.layer?.backgroundColor = NSColor.green.cgColor
        
        if let view = view as? HeaderView {
            view.titleTextField?.stringValue = "Custom Header"
        } else if let view = view as? HeaderView {
            view.titleTextField?.stringValue = "Custom Footer"
        }
        return view
    }
    // MARK: NSCollectionViewDelegate
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
