//
//  Utilities.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/28/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation


class Utilities {
    static func  generateItems(quantity: Int) -> [Item] {
        var result: [Item] = []
        for i in 0..<quantity {
            let item = Item(width: Int(arc4random_uniform(UInt32(100))) + 1, height:  Int(arc4random_uniform(UInt32(100))) + 1, name: String(format: "item %d", i), color: CGColor(red: .random(), green: .random(), blue: .random(), alpha: 1))
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
        var lstOperator: [String] = (0..<quantity - 1).map{ _ in randomOperator() }
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
        guard  !Utilities.validateExpression(input: input) else {
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
    static func randomOperator() -> String {
        let opts = [OperatorType.Vertical.rawValue, OperatorType.Horizontal.rawValue]
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

extension Array where Element : Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            if !uniqueValues.contains(item) {
                uniqueValues += [item]
            }
        }
        return uniqueValues
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
