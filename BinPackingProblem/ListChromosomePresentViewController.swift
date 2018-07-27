//
//  ListChromosomePresentViewController.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/27/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Cocoa
import PureLayout
import RxSwift
import RxCocoa


class ListChromosomePresentViewController: NSViewController, NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout  {
    let disposeBag = DisposeBag()
    lazy var collectionView = createCollectionView()
    private var chromosomeView: [NSView] = []
    private let lstChromosomeDriver: Driver<[Chromosome]>
    private var lstChromosome: [Chromosome] = []
    private let titleHeader: String
    var counter = 0
    init(title: String, items: [Item], lstChromosome: Driver<[Chromosome]>) {
        self.lstChromosomeDriver = lstChromosome
        self.titleHeader = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func loadView() {
        self.view = NSView() // any view of your choice
    }
    override func viewDidAppear() {
        self.view.wantsLayer = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lstChromosomeDriver.drive(onNext: { [weak self] (lstPopulation) in
            self?.lstChromosome = lstPopulation
            self?.chromosomeView = lstPopulation.map { (chro) -> ChromosomePresentView in
                return ChromosomePresentView(chromosome: chro)
            }
            self?.collectionView.reloadData()
        }).disposed(by: self.disposeBag)
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
        let stackView = NSStackView(views: [scrollView])
        stackView.orientation = .horizontal
        stackView.distribution = .fillProportionally
        view.addSubview(stackView)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges(with: NSEdgeInsets.init(top: 10, left: 10, bottom: 10, right: 10))
        }
    }
    
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}

extension ListChromosomePresentViewController {
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    func createCollectionView()-> NSCollectionView {
        let collectionView = NSCollectionView()
        collectionView.wantsLayer = true
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

extension ListChromosomePresentViewController {
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
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let chro = lstChromosome[indexPath.item]
        return NSSize(width: chro.Size.0, height: chro.Size.1)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 30)
    }
    
    func collectionView(_ collectionView: NSCollectionView, layout collectionViewLayout: NSCollectionViewLayout, referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize(width: 0, height: 0)
    }
    
    func numberOfSectionsInCollectionView(collectionView: NSCollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind, at indexPath: IndexPath) -> NSView {
        var nibName: String?
        nibName = "Header"
//        if kind == NSCollectionView.SupplementaryElementKind.sectionHeader {
//            nibName = "Header"
//        } else if kind == NSCollectionView.SupplementaryElementKind.sectionFooter {
//            nibName = "Footer"
//        }
        let view = collectionView.makeSupplementaryView(ofKind: kind, withIdentifier: NSUserInterfaceItemIdentifier(rawValue: nibName!), for: indexPath)
        
        view.wantsLayer = true
        
        if let view = view as? HeaderView {
            view.titleTextField?.stringValue =  kind == NSCollectionView.SupplementaryElementKind.sectionHeader ? titleHeader : ""
            view.backgroundColor = NSColor.blue.withAlphaComponent(0.3)
        }
//        else if let view = view as? HeaderView {
//            view.titleTextField?.stringValue = "Custom Footer"
//            view.backgroundColor = NSColor.blue.withAlphaComponent(0.3)
//
//        }
        return view
    }
    // MARK: NSCollectionViewDelegate
}
