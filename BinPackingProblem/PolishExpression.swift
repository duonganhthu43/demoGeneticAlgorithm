//
//  PolishExpression.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/22/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
public enum OperatorType: String {
    case Vertical = "V"
    case Horizontal = "H"
}

public enum MutationType {
    case Rotate
    case RandomExchange
    case MoveOpt
    case ComplimentOpt
}

class Item {
    init(width: Int, height: Int, name: String) {
        self.width = width
        self.height = height
        self.name = name
    }
    let name: String
    var width: Int
    var height: Int
}

class OperatorToken {
    var index: Int
    var operatorType: OperatorType
    init(idx: Int, opt: OperatorType) {
        index = idx
        operatorType = opt
    }
}

class Chromosome {
    private var items: [Item]
    private var indexPart: [String]
    private var operatorPart: [OperatorToken]
    public var Expression: [String] {
        return constructExpression()
    }
    
    public var Area: Int {
        let boundingRect = getBoundingRect()
        return calculateArea(item: boundingRect)
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
    
    private func rotateItem(with index: Int ) {
        guard index < items.count, index > -1 else { return }
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
    }
    
    private func moveOpt() {
        // construct expression
        var myExp = self.Expression
        // randome pick operator
        let randomIndex = Demo.generateRandom(lim: self.operatorPart.count - 1)
        let myopt = self.operatorPart[randomIndex]
        let randomPosition = Demo.generateRandom(lim: myExp.count - 1)
        if randomPosition < myopt.index {
            myExp.insert(myopt.operatorType.rawValue, at: randomPosition)
            myExp.remove(at:  myopt.index + 1)
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

class GeneticProcess {
    private static let CrossOverRate = 0.3
    private static let MutationRate = 0.7
    private var population: [Chromosome] = []
    init(items: [Item]) {
        // init population: 2* size of items
        let populationSize = 2 * items.count
        for _ in 0..<populationSize {
            population.append(Chromosome(exp: Demo.generateExpression(quantity: items.count), items: items))
        }
        // sort population by finessValue
        population.sort { (left, right) -> Bool in
           return left.Fitness > right.Fitness
        }
        
    }
    func execute() {
        
//        for i in 0..<population.count {
//            print("VALUE: ", i)
//            print("FITNESS " , population[i].Fitness)
//            print("AREA " , population[i].Area)
//            print("")
//        }
    }
    
    func evolvePopulation() {
        
    }
    
    static func pmxCrossOver(parent1: [String], parent2: [String]) -> ([String], [String]) {
        // randomly choose range
        let randomPosition1 = Demo.generateRandom(lim: parent1.count - 1, exclude: [0, parent1.count])
        let randomPosition2 = Demo.generateRandom(lim: parent1.count - 1, exclude: [0, parent1.count, randomPosition1 ])
        let start = min(randomPosition1, randomPosition2)
        let end = max(randomPosition1, randomPosition2)
        //let start = 3
        //let end = 5
        //child 1 get subString Parent 2 ,child 2 get substring parent 1
        var subArray1 = parent2[start...end ] // child 1
        var subArray2 = parent1[start...end] // child 2
        var child1 = parent1[0..<start] +  subArray1 + parent1[(end+1)..<parent1.count]
        var child2 = parent2[0..<start] + subArray2 + parent2[(end+1)..<parent1.count]
        for i in start...end {
            let value1 = subArray1[i]
            let value2 = subArray2[i]
            if value1 == value2 { continue }
            if subArray2.contains(value1) || subArray1.contains(value2) { continue}
            // find index in child1 == value1
            if let indexHead = parent1[0...start].index(of: value1) {
                child1[indexHead] = value2
            }
            if let indexTail = parent1[end...parent1.count - 1].index(of: value1) {
                child1[indexTail] = value2
            }
            // find index in child2 == value2
            if let indexHead = parent2[0...start].index(of: value2) {
                child2[indexHead] = value1
            }
            if let indexTail = parent2[end...parent1.count - 1].index(of: value2) {
                child2[indexTail] = value1
            }
        }
        return (Array(child1),Array(child2))
    }
}



class Demo {
    let items: [Item] = []
    func generateItems(quantity: Int) -> [Item] {
        var result: [Item] = []
        for i in 0..<quantity {
            let item = Item(width: Int(arc4random_uniform(UInt32(100))) + 1, height:  Int(arc4random_uniform(UInt32(100))) + 1, name: String(format: "item %d", i))
            result.append(item)
        }
        return result
    }
    static func generateRandom(lim: Int, exclude: [Int]? = nil) -> Int {
        let random = Int(arc4random_uniform(UInt32(lim)))
        if let excludeNumbers = exclude, excludeNumbers.contains(random) {
            return generateRandom(lim: lim, exclude: exclude)
        }
        return random
    }
    
    static func generateExpression(quantity: Int) -> [String] {
        var result:[String] = []
        let itemByString = (0..<quantity).map{ String(format: "%d", $0)}
        var lstOperator: [String] = (0..<quantity - 1).map{ _ in Utilities.randomOperator() }
        lstOperator.append(contentsOf: itemByString)
        result = lstOperator.shuffled()
        return  correctExpression(input: result)
    }
    
    static func validateExpression(input: [String]) -> Bool {
        var stack = Stack<String>()
        for i in 0..<input.count {
            if Int(input[i]) != nil {
                stack.push(input[i])
            } else {
                guard stack.count > 1 else { return false }
                let _ = stack.pop()
                let _ = stack.pop()
                stack.push(input[i])
            }
        }
        return stack.count == 1
    }
    
    static func correctExpression(input: [String]) -> [String] {
        guard  !Demo.validateExpression(input: input) else {
            return input
        }
        var result = input
        var operatorCount = 0
        var operandCount = 0
        for i in 0..<result.count {
            if Int(result[i]) != nil {
                operandCount = operandCount + 1
            } else {
                operatorCount = operatorCount + 1
            }
            if operatorCount > operandCount - 1 {
                // if operator , find nearest operand and swap
                if Int(result[i]) == nil {
                    for j in i..<result.count {
                        if Int(result[j]) != nil {
                            result.insert(result[j], at: i)
                            result.remove(at: j + 1)
                            operatorCount = operatorCount - 1
                            operandCount = operandCount + 1
                            break
                        }
                    }
                }
            }
            
        }
        return result
    }
}

class Utilities {
    static func randomOperator() -> String {
        let opts = ["V", "H"]
        return opts[Int(arc4random_uniform(UInt32(opts.count)))]
    }
}

public struct Stack<T> {
    fileprivate var array = [T]()
    
    public var isEmpty: Bool {
        return array.isEmpty
    }
    
    public var count: Int {
        return array.count
    }
    
    public mutating func push(_ element: T) {
        array.append(element)
    }
    
    public mutating func pop() -> T? {
        return array.popLast()
    }
    
    public var top: T? {
        return array.last
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Array {
    mutating func rearrange(from: Int, to: Int) {
        precondition(from != to && indices.contains(from) && indices.contains(to), "invalid indexes")
        insert(remove(at: from), at: to)
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}



