//
//  Chromosome.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/25/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
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
        let correctExp = Demo.correctExpression(input: constructExpression())
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
    
    func mutation() -> Chromosome {
        let randomNumber = Demo.generateRandom(lim: 3)
        switch randomNumber {
        case 0 :
            rotateItem()
            return self
        case 1:
            randomExchange()
            return self
        case 2:
            moveOpt()
            return self
        default:
            complementOpt()
            return self
        }
    }
    
    private func rotateItem() {
        let index = Demo.generateRandom(lim: items.count-1)
        let height = items[index].height
        items[index].height = items[index].width
        items[index].width = height
    }
    
    private func randomExchange() {
        let fromIdx = Demo.generateRandom(lim: indexPart.count - 1)
        let toIdx = Demo.generateRandom(lim: indexPart.count - 1, exclude: [fromIdx])
        let from = indexPart[fromIdx]
        let to = indexPart[toIdx]
        let temp = from
        self.indexPart[fromIdx] = to
        self.indexPart[toIdx] = temp
        _ = Expression
    }
    
    
    private func moveOpt() {
        // construct expression
        var myExp = self.Expression
        // randome pick operator
        let randomIndex = Demo.generateRandom(lim: self.operatorPart.count - 1)
        let myopt = self.operatorPart.sorted(by: { (l, r) -> Bool in
            return l.index < r.index
        })[randomIndex]
        let randomPosition = Demo.generateRandom(lim: myExp.count - 1)
        if randomPosition < myopt.index {
            myExp.remove(at:  myopt.index)
            myExp.insert(myopt.operatorType.rawValue, at: randomPosition)
        } else {
            myExp.insert(myopt.operatorType.rawValue, at: randomPosition)
            myExp.remove(at:  myopt.index)
        }
        myExp = Demo.correctExpression(input: myExp)
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
    
    private func complementOpt() {
        // randome pick operator
        let randomIndex = Demo.generateRandom(lim: self.operatorPart.count - 1)
        let myopt = self.operatorPart[randomIndex]
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
                if expression[i] == "V" {
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
}
