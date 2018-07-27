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
    var counter = 0
    var lstMutationController: ListChromosomePresentViewController
    var lstPopulationController: ListChromosomePresentViewController
    var inputView : InputPresentView
    var bestChild : ChromosomePresentView
    var bestChromosomeView: ListChromosomePresentViewController
    
    var currentChromosome: Chromosome?
    var countSteadyTime = 0
    var shouldStop: PublishSubject<Bool> = PublishSubject()
    
    private let itemQuantity = 12

    init() {
        items = Utilities.generateItems(quantity: itemQuantity)
        process = GeneticProcess(items: items)
        lstMutationController = ListChromosomePresentViewController(title: "Mutation ", lstChromosome: process.mutationsDriver)
        lstPopulationController = ListChromosomePresentViewController(title: "Population ", lstChromosome: process.populationDriver)
        inputView = InputPresentView(items: items)
        bestChromosomeView = ListChromosomePresentViewController(title: "Best Chromosome ", lstChromosome: process.populationDriver.map({ (array) -> [Chromosome] in
            let best = array[0]
            return [best]
        }), showOriginalSize : true)
        bestChild = ChromosomePresentView(chromosome: process.population[0])
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        items = Utilities.generateItems(quantity: itemQuantity)
        process = GeneticProcess(items: items)
        lstMutationController = ListChromosomePresentViewController(title: "Mutation ", lstChromosome: process.mutationsDriver)
        lstPopulationController = ListChromosomePresentViewController(title: "Population ", lstChromosome: process.populationDriver)
        inputView = InputPresentView(items: items)
        bestChromosomeView = ListChromosomePresentViewController(title: "Best Chromosome ", lstChromosome: process.populationDriver.map({ (array) -> [Chromosome] in
            let best = array[0]
            return [best]
        }), showOriginalSize : true)
        bestChild = ChromosomePresentView(chromosome: process.population[0])
        super.init(coder: coder)
    }

    override func viewDidAppear() {
        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
            NSNumber(integerLiteral: Int(presOptions.rawValue))]
        //self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
    
    private let textViewController = TextWithScrollViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        addChildViewController(lstPopulationController)
        //addChildViewController(lstMutationController)
        addChildViewController(textViewController)

        let topLeftView = NSStackView()
        topLeftView.orientation = .vertical
        topLeftView.distribution = .fillProportionally
        //topLeftView.addArrangedSubview(inputView)
        //topLeftView.addArrangedSubview(bestChild)
        let leftView = NSStackView()
        //leftView.instricsicWidth = 1
        leftView.orientation = .vertical
        leftView.distribution = .fillProportionally
        leftView.spacing = 1
        leftView.addArrangedSubview(inputView)
        //leftView.addArrangedSubview(bestChild)

        leftView.addArrangedSubview(lstPopulationController.view)
        //leftView.addArrangedSubview(lstMutationController.view)
        lstPopulationController.view.autoresizingMask = [.width, .height]
        lstMutationController.view.autoresizingMask = [.width, .height]

        let btnRun = createRunButton()
        let btnGenerateItem = createGenerateButton()
        let btnStop = createStopButton()
        let btnClear = createClearLog()

        let buttonStack = NSStackView()
        buttonStack.orientation = .horizontal
        buttonStack.distribution = .fillProportionally
        buttonStack.addArrangedSubview(btnRun)
        buttonStack.addArrangedSubview(btnGenerateItem)
        buttonStack.addArrangedSubview(btnStop)
        buttonStack.addArrangedSubview(btnClear)


        let leftStackOuterView = NSStackView()
        leftStackOuterView.orientation = .vertical
        leftStackOuterView.distribution = .fill
        leftStackOuterView.addArrangedSubview(buttonStack)
        leftStackOuterView.addArrangedSubview(leftView)

        // Notify Child View Controller
        lstPopulationController.view.viewDidMoveToSuperview()
        //lstMutationController.view.viewDidMoveToSuperview()
        textViewController.view.viewDidMoveToSuperview()
        let rightView = NSStackView()
        rightView.addArrangedSubview(textViewController.view)



        process.logWriterDriver.drive(onNext: {[weak self] (text) in
            guard let strongSelf = self else { return }
            strongSelf.textViewController.textView.string = strongSelf.textViewController.textView.string + text
            //strongSelf.textViewController.scrollView.scrollToEndOfDocument(nil)
        }).disposed(by: disposeBag)

        process.populationDriver.drive(onNext: {[weak self] (chro) in
            guard let strongSelf = self else { return}
            if let current = strongSelf.currentChromosome, current == chro[0] {
                strongSelf.countSteadyTime = strongSelf.countSteadyTime + 1
            } else {
                strongSelf.countSteadyTime = 0

            }
            strongSelf.currentChromosome = chro[0]
            if strongSelf.countSteadyTime > 10 {
                strongSelf.StopTimer()
            }
        }).disposed(by: disposeBag)

        let stackView = NSStackView(views: [leftStackOuterView, rightView])
        stackView.orientation = .horizontal
        stackView.distribution = .fill
        view.addSubview(stackView)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdgesToSuperviewEdges()
            rightView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
            rightView.autoMatch(.width, to: .width, of: stackView, withMultiplier: 1/3)
            leftStackOuterView.autoMatch(.height, to: .height, of: stackView, withMultiplier: 1)
            leftView.autoMatch(.width, to: .width, of: stackView, withMultiplier: 2/3)
            lstPopulationController.view.autoMatch(.height, to: .height, of: stackView, withMultiplier: 3/4)
            //bestChromosomeView.view.autoMatch(.width, to: .width, of: stackView, withMultiplier: 1/5)
        }
    }


    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    var timerDisposeBag = DisposeBag()


    // Mark: Properties
//    let btnRun: NSButton = createButton()
}

extension ViewController {
    
    
    func createGenerateButton()-> NSButton {
        let button = NSButton()
        button.title = "Re-Generate Item"
        button.target = self
        button.action = #selector(ViewController.GenerateItems)
        button.autoSetDimensions(to: CGSize(width: 200, height: 100))
        return button
    }
    
    func createRunButton()-> NSButton {
        let button = NSButton()
        button.title = "Run"
        button.target = self
        button.action = #selector(ViewController.StartTimer)
        button.autoSetDimensions(to: CGSize(width: 200, height: 100))
        return button
    }
    
    
    func createStopButton()-> NSButton {
        let button = NSButton()
        button.title = "Stop"
        button.target = self
        button.action = #selector(ViewController.StopTimer)
        button.autoSetDimensions(to: CGSize(width: 200, height: 100))
        return button
    }
    
    func createClearLog()-> NSButton {
        let button = NSButton()
        button.title = "Clear Log"
        button.target = self
        button.action = #selector(ViewController.ClearLog)
        button.autoSetDimensions(to: CGSize(width: 200, height: 100))
        return button
    }
    
    @objc func GenerateItems() {
        ClearLog()
       items = Utilities.generateItems(quantity: itemQuantity)
       process.updateItem(input: items)
       inputView.setItem(input: items)
    }

    @objc func StartTimer() {
        ClearLog()
        Observable<Int>.timer(1, period: 1, scheduler: MainScheduler.instance).subscribe(onNext: { (time) in
            self.process.executeSingleRound()
        }).disposed(by: timerDisposeBag)
    }
    
    @objc func StopTimer() {
        timerDisposeBag = DisposeBag()
    }
    
    @objc func ClearLog() {
        textViewController.textView.string = ""
    }
    
}



class TextWithScrollViewController: NSViewController {
    let scrollView = NSScrollView()
    let textView = NSTextView()
    override func loadView() {
        self.view = NSView() // any view of your choice
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.autoresizingMask = .width
        textView.isVerticallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        textView.drawsBackground = false
        textView.font = NSFont.systemFont(ofSize: 15)
        textView.backgroundColor = NSColor.black
        textView.textColor = NSColor.white
        
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = textView
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
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
