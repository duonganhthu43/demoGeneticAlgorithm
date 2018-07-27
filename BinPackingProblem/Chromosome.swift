//
//  Chromosome.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/25/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
public class Chromosome: Equatable {
    public static func == (lhs: Chromosome, rhs: Chromosome) -> Bool {
        return lhs.Expression == rhs.Expression && lhs.Area == rhs.Area
    }
    
    var items: [Item]
    var IndexPart: [String] {
        return indexPart
    }
    var OperatorPart: [OperatorToken] {
        return operatorPart
    }
    private var indexPart: [String]
    private var operatorPart: [OperatorToken]
    public var Expression: [String] {
        let correctExp = Utilities.correctExpression(input: constructExpression())
        self.indexPart = correctExp.filter({ (str) -> Bool in
            return Int(str) != nil
        })
        operatorPart = []
        for i in 0..<correctExp.count {
            if Int(correctExp[i]) == nil {
                operatorPart.append(OperatorToken(idx: i, opt: OperatorType(rawValue: correctExp[i])!))
            }
        }
        return correctExp
    }
    
    public var Area: Int {
        let boundingRect = getBoundingRect()
        return calculateArea(item: boundingRect)
    }
    
    public var Size: (Int,Int) {
        let boundingRect = getDisplayBoundingRect()
        return (boundingRect.width, boundingRect.height)
    }
    
    public var OriginalSize: (Int,Int) {
        let boundingRect = getBoundingRect()
        return (boundingRect.width, boundingRect.height)
    }
    
    public var Fitness: Float {
        return fitness()
    }
    
    init(exp: [String], items: [Item]) {
        self.items = items
        self.indexPart = exp.filter({ (str) -> Bool in
            return Int(str) != nil
        })
        operatorPart = []
        for i in 0..<exp.count {
            if Int(exp[i]) == nil {
                operatorPart.append(OperatorToken(idx: i, opt: OperatorType(rawValue: exp[i])!))
            }
        }
    }
    
    private init(opt: [OperatorToken], index: [String], items: [Item]) {
        self.items = items
        self.indexPart = index
        self.operatorPart = opt
    }
    
    func crossover(with: Chromosome) -> (Chromosome, Chromosome) {
        let crossOverIndexP = GeneticProcess.pmxCrossOver(parent1: self.IndexPart, parent2: with.IndexPart)
        let crossOverOperaterP = GeneticProcess.uniformCrossOver(parent1: self.OperatorPart, parent2: with.OperatorPart)
        return (Chromosome(opt: crossOverOperaterP.0, index: crossOverIndexP.0, items: self.items), Chromosome(opt: crossOverOperaterP.1, index: crossOverIndexP.1, items: with.items))
    }
    
    func mutation(logWriter: PublishSubject<String>) -> Chromosome {
        //logWriter.onNext("\n")

        //logWriter.onNext("MUTATION :  \n")

        let randomNumber = Utilities.generateRandom(lim: 3)
        //logWriter.onNext(String(format: "Choose random method : %d \n", arguments: [randomNumber]))
        switch randomNumber {
        case 0 :
            rotateItem(logWriter: logWriter)
            return self
        case 1:
            randomExchange(logWriter: logWriter)
            return self
        case 2:
            moveOpt(logWriter: logWriter)
            return self
        default:
            complementOpt(logWriter: logWriter)
            return self
        }
    }
    
    private func rotateItem(logWriter: PublishSubject<String>) {
        let index = Utilities.generateRandom(lim: items.count-1)
//        logWriter.onNext(String(format: " ROTATE ITEM AT INDEX: %d \n" , index) )
//        logWriter.onNext(String(format: "Before: %@  \n" ,Expression.joined(separator: " ")) )

        let height = items[index].height
        items[index].height = items[index].width
        items[index].width = height
        //logWriter.onNext(String(format: "After: %@  \n" ,Expression.joined(separator: " ")) )

    }
    
    private func randomExchange(logWriter: PublishSubject<String>) {
        let fromIdx = Utilities.generateRandom(lim: indexPart.count - 1)
        let toIdx = Utilities.generateRandom(lim: indexPart.count - 1, exclude: [fromIdx])
//        logWriter.onNext(String(format: " RANDOM EXCHANGE ITEM : from %d to %d \n" , fromIdx, toIdx) )
//        logWriter.onNext(String(format: "Before: %@  \n" ,Expression.joined(separator: " ")) )

        let from = indexPart[fromIdx]
        let to = indexPart[toIdx]
        let temp = from
        self.indexPart[fromIdx] = to
        self.indexPart[toIdx] = temp
        _ = Expression
        //logWriter.onNext(String(format: "After: %@  \n" ,Expression.joined(separator: " ")) )

    }
    
    
    private func moveOpt(logWriter: PublishSubject<String>) {
        // construct expression
        var myExp = self.Expression
        // randome pick operator
        let randomIndex = Utilities.generateRandom(lim: self.operatorPart.count - 1)
        let myopt = self.operatorPart.sorted(by: { (l, r) -> Bool in
            return l.index < r.index
        })[randomIndex]
        let randomPosition = Utilities.generateRandom(lim: myExp.count - 1)
//        logWriter.onNext(String(format: " MOVE OPERATOR : from %d to %d \n" , myopt.index, myopt.index) )
//        logWriter.onNext(String(format: "Before: %@  \n" ,myExp.joined(separator: " ")) )


        if randomPosition < myopt.index {
            myExp.remove(at:  myopt.index)
            myExp.insert(myopt.operatorType.rawValue, at: randomPosition)
        } else {
            myExp.insert(myopt.operatorType.rawValue, at: randomPosition)
            myExp.remove(at:  myopt.index)
        }
        myExp = Utilities.correctExpression(input: myExp)
//        logWriter.onNext(String(format: "After : %@  \n" ,myExp.joined(separator: " ")) )

        // part back to data
        self.indexPart = myExp.filter({ (str) -> Bool in
            return Int(str) != nil
        })
        operatorPart = []
        for i in 0..<myExp.count {
            if Int(myExp[i]) == nil {
                operatorPart.append(OperatorToken(idx: i, opt: OperatorType(rawValue: myExp[i])!))
            }
        }
    }
    
    private func complementOpt(logWriter: PublishSubject<String>) {
        // randome pick operator
        let randomIndex = Utilities.generateRandom(lim: self.operatorPart.count - 1)

        let myopt = self.operatorPart[randomIndex]
//        logWriter.onNext(String(format: " COMPLEMENT OPERATOR : at %d with value %@ \n" , randomIndex, myopt.operatorType.rawValue) )

        self.operatorPart[randomIndex].operatorType = myopt.operatorType == OperatorType.Horizontal ? .Vertical : .Horizontal
    }
    
    private func constructExpression() -> [String] {
        var myIndexPart = self.indexPart
        for i in 0..<self.operatorPart.count {
            let opt = self.operatorPart[i]
            myIndexPart.insert(opt.operatorType.rawValue, at: opt.index)
        }
        return myIndexPart
    }
    
    private func getBoundingRect() -> Item {
        let items = self.items
        let expression = Expression
        var stack = Stack<Item>()
        for i in 0..<expression.count {
            if let itemIndex = Int(expression[i]) {
                stack.push(items[itemIndex])
            } else {
                let item2 = stack.pop()
                let item1 = stack.pop()
                if expression[i] == OperatorType.Vertical.rawValue {
                    stack.push(Item(width: max(item1!.width, item2!.width), height: item1!.height + item2!.height, name: item1!.name + item2!.name))
                } else {
                    stack.push(Item(width: item1!.width + item2!.width, height: max(item1!.height, item2!.height), name: item1!.name + item2!.name))
                }
            }
        }
        return stack.top!
    }
    
    private func getDisplayBoundingRect() -> Item {
        let items = self.items.map { (item) -> Item in
            return Item(width: item.displayWidth, height: item.displayHeight, name: item.name, color: item.color)
        }
        let expression = Expression
        var stack = Stack<Item>()
        for i in 0..<expression.count {
            if let itemIndex = Int(expression[i]) {
                stack.push(items[itemIndex])
            } else {
                let item2 = stack.pop()
                let item1 = stack.pop()
                if expression[i] == OperatorType.Vertical.rawValue {
                    stack.push(Item(width: max(item1!.width, item2!.width), height: item1!.height + item2!.height, name: item1!.name + item2!.name))
                } else {
                    stack.push(Item(width: item1!.width + item2!.width, height: max(item1!.height, item2!.height), name: item1!.name + item2!.name))
                }
            }
        }
        return stack.top!
    }

    
    private func calculateArea(item: Item) -> Int {
        return item.height * item.width
    }
    
    private func penalty(item: Item)-> Int {
        let AAR = 1.2
        let width = item.width
        let height = item.height
        if Double(width/height) > AAR || Double(width/height) < 1/AAR {
            return (width - height) * (width - height);
        }
        return 0
    }
    
    private func fitness() -> Float {
        let boundingRect = getBoundingRect()
        return 1000000.0/Float((calculateArea(item: boundingRect) + penalty(item: boundingRect)))
    }
    
    func getViewPresent() -> ChromosomePresentView {
        return ChromosomePresentView(chromosome: self)
    }
}
