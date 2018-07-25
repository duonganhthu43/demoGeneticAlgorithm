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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let demo = Demo()
        let items = demo.generateItems(quantity: 8 )
//        for i in 0...10 {
//            let expression = demo.generateExpression(quantity: 8)
//            print( "EXP      ", expression.reduce("", { (result, current) -> String in
//                return result + " " + current
//            }))
//            let isValid = demo.validateExpression(input: expression)
//            if !isValid {
//                let expCorrect = demo.correctExpression(input: expression)
//                print( "EXP AFTER ADJUSTMENT     ",expCorrect.reduce("", { (result, current) -> String in
//                    return result + " " + current
//                }))
//            }
//            print(" ")
//        }
//        let btnRun = createButton()
//        view.addSubview(btnRun)
//        NSLayoutConstraint.autoCreateAndInstallConstraints {
//            btnRun.autoPicnEdgesToSuperviewEdges()
//        }
        
          let geneticProcess = GeneticProcess(items: items)
          geneticProcess.execute()
        
//        let string1: [String] = "4,8,7,3,6,5,1,10,9,2".components(separatedBy: ",")
//        let string2:[String] =  "3,1,4,2,7,9,10,8,6,5".components(separatedBy: ",")
//        let result = GeneticProcess.pmxCrossOver(parent1: string1, parent2: string2)
//        print("PARENT1: ", string1.joined(separator: " "))
//        print("PARENT2: ", string2.joined(separator: " "))
//        print(" ")
//        print("CHILD1: ", result.0.joined(separator: " "))
//        print("CHILD2: ", result.1.joined(separator: " "))

        
        let validExpression = Demo.correctExpression(input: ["H","0","H", "4" ,"6" ,"V", "V", "H", "5" ,"7", "H", "V", "3", "1", "2"])
        print( "EXP AFTER ADJUSTMENT     ",validExpression.reduce("", { (result, current) -> String in
                                return result + " " + current
                            }))
        let viewItems  = items.map{ NSView(frame: CGRect(x: 0, y: 0, width: $0.width, height: $0.height))}
        for j in 0..<viewItems.count {
            viewItems[j].backgroundColor = NSColor(cgColor: CGColor(red: .random(), green: .random(), blue: .random(), alpha: 1))
            viewItems[j].autoSetDimensions(to: CGSize(width: items[j].width*2, height: items[j].height*2))
        }
        var stack = Stack<NSView>()
        for i in 0..<validExpression.count {
            if let itemIndex = Int(validExpression[i]) {
                stack.push(viewItems[itemIndex])
            } else {
                let left = stack.pop()
                let right = stack.pop()
                let stackView = NSStackView(views: [left!, right!])
                stackView.spacing = 0
                stackView.alignment = validExpression[i] == "V" ? NSLayoutConstraint.Attribute.bottom: NSLayoutConstraint.Attribute.right
                stackView.orientation = validExpression[i] == "V" ? NSUserInterfaceLayoutOrientation.vertical : NSUserInterfaceLayoutOrientation.horizontal
                stack.push(stackView)
            }
        }
        let finalView = stack.top
        view.addSubview(finalView!)
        //finalView?.layer?.backgroundColor = CGColor.black
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            finalView?.autoCenterInSuperview()
        }
        
        print("CUSTOM VALID : ",Demo.validateExpression(input: ["7", "6", "H", "5", "4","V", "H","3", "2","V","H", "1","V", "0","V"]))

        // Do any additional setup after loading the view.
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
