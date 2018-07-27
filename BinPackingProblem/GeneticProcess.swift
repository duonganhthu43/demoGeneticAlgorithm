//
//  PolishExpression.swift
//  BinPackingProblem
//
//  Created by anhthu on 7/22/18.
//  Copyright © 2018 anhthu. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
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

class OperatorToken {
    var index: Int
    var operatorType: OperatorType
    init(idx: Int, opt: OperatorType) {
        index = idx
        operatorType = opt
    }
}



class GeneticProcess {
    private static let mutationRate = 0.7
    private static let crossoverRate = 0.3
    private static let tournamentSize = 5
    var population: [Chromosome] = []
    private var populationSubject: PublishSubject<[Chromosome]> = PublishSubject()
    private var mutationsSubject: PublishSubject<[Chromosome]> = PublishSubject()

    private var bestChromosomeSubject: PublishSubject<Chromosome> = PublishSubject()

    private var logWriterPublisher: PublishSubject<String> = PublishSubject()
    
    public var logWriterDriver: Driver<String> {
        return logWriterPublisher.asDriver(onErrorJustReturn: "ERROR ")
    }

    public var mutationsDriver: Driver<[Chromosome]> {
        return mutationsSubject.asDriver(onErrorJustReturn: [])
    }
    public var populationDriver: Driver<[Chromosome]> {
        return populationSubject.asDriver(onErrorJustReturn: [])
    }
    

    init(items: [Item]) {
        updateItem(input: items)
//        let populationSize = 2 * items.count
//        for _ in 0..<populationSize {
//            population.append(Chromosome(exp: Demo.generateExpression(quantity: items.count), items: items))
//        }
//        // sort population by finessValue
//        population.sort { (left, right) -> Bool in
//           return left.Fitness > right.Fitness
//        }
//        populationSubject.onNext(population)
    }
    
    func updateItem(input: [Item]) {
        let populationSize = 2 * input.count
        population = []
        for _ in 0..<populationSize {
            population.append(Chromosome(exp: Utilities.generateExpression(quantity: input.count), items: input))
        }
        // sort population by finessValue
        population.sort { (left, right) -> Bool in
            return left.Fitness > right.Fitness
        }
        populationSubject.onNext(population)
    }
    
    func executeSingleRound()-> [Chromosome] {
        // CROSS OVER: Ex Selection using Tournament
        logWriterPublisher.onNext(String(format: "\n START \n"))
        var newChild: [Chromosome] = []
        let countJoinCrossOver = Int(Double(population.count) * GeneticProcess.crossoverRate)
        for i in 0..<countJoinCrossOver {
            let parent1 = GeneticProcess.tournamentSelection(population: population)
            let parent2 = GeneticProcess.tournamentSelection(population: population)
            let result =  parent1.crossover(with: parent2)
            newChild.append(result.0)
            newChild.append(result.1)
        }
        // mutation
        for i in 0..<newChild.count {
            let r = CGFloat.random()
            if r < 0.7 {
                newChild[i] = newChild[i].mutation(logWriter: logWriterPublisher)
            }
        }
        newChild.sort { (l, r) -> Bool in
            l.Fitness > r.Fitness
        }
        
        mutationsSubject.onNext(newChild)
        
        population.append(contentsOf: newChild)
        population = population.unique
        population.sort { (l, r) -> Bool in
            l.Fitness > r.Fitness
        }
        population = Array(population[0...(2*population[0].items.count)])
        populationSubject.onNext(population)
        logWriterPublisher.onNext(String(format: "BEST CHROMOSOME : %@ \n", population[0].Expression.joined(separator: " ")))
        logWriterPublisher.onNext(String(format: "FITNESS : %f \n", population[0].Fitness))
        logWriterPublisher.onNext(String(format: "AREA : %d \n", population[0].Area))
        logWriterPublisher.onNext(String(format: "SIZE : width %d  height %d \n", population[0].OriginalSize.0, population[0].OriginalSize.1))
        logWriterPublisher.onNext(String(format: "\n END \n"))
        return population
    }
    
    func execute() {
        var  endCondition = 400
        while endCondition > 0 {
            // Selection
            // CROSS OVER: Ex Selection using Tournament
            var newChild: [Chromosome] = []
            let countJoinCrossOver = Int(Double(population.count) * GeneticProcess.crossoverRate)
            for _ in 0..<countJoinCrossOver {
                let parent1 = GeneticProcess.tournamentSelection(population: population)
                let parent2 = GeneticProcess.tournamentSelection(population: population)
                let result =  parent1.crossover(with: parent2)
                newChild.append(result.0)
                newChild.append(result.1)
            }
            // mutation
            for i in 0..<newChild.count {
                let r = CGFloat.random()
                if r < 0.7 {
                   newChild[i] = newChild[i].mutation(logWriter: logWriterPublisher)
                }
            }
            population.append(contentsOf: newChild)
            population.sort { (l, r) -> Bool in
                l.Fitness > r.Fitness
            }
            population = Array(population[0...(2*population[0].items.count)])
            populationSubject.onNext(population)
            print("VALUE: ", endCondition)
            print("FITNESS " , population[0].Fitness)
            print("AREA " , population[0].Area)
            print("")
            endCondition = endCondition - 1
        }
    }
    
    static func tournamentSelection(population: [Chromosome]) -> Chromosome {
        // get random
        var currentPop = population
        var lstCompetitor: [Chromosome] = []
        while lstCompetitor.count < tournamentSize {
            currentPop = currentPop.shuffled()
            let randomIndex = Utilities.generateRandom(lim: currentPop.count - 1)
            let selected = currentPop[randomIndex]
            if !lstCompetitor.contains(where: { (select) -> Bool in
                return select.Expression == selected.Expression
            }) {
                lstCompetitor.append(selected)
            }
        }
        return  lstCompetitor.sorted { (left, right) -> Bool in
            left.Fitness > right.Fitness
        }[0]
    }
    
    static func uniformCrossOver(parent1: [OperatorToken], parent2: [OperatorToken]) -> ([OperatorToken], [OperatorToken]) {
        var child1: [OperatorToken] = []
        var child2: [OperatorToken] = []
        for i in 0..<parent1.count {
            let r = CGFloat.random()
            if r < 0.5 {
                child1.append(parent1[i])
                child2.append(parent2[i])
            } else {
                child1.append(parent2[i])
                child2.append(parent1[i])
            }
        }
        return (Array(child1),Array(child2))
    }
    
    static func pmxCrossOver(parent1: [String], parent2: [String]) -> ([String], [String]) {
        // randomly choose range
        let randomPosition1 = Utilities.generateRandom(lim: parent1.count - 1, exclude: [0, parent1.count])
        let randomPosition2 = Utilities.generateRandom(lim: parent1.count - 1, exclude: [0, parent1.count, randomPosition1 ])
        let start = min(randomPosition1, randomPosition2)
        let end = max(randomPosition1, randomPosition2)
        var p1 = parent1.map{ Int($0)!}
        var p2 = parent2.map{ Int($0)!}
        var offspring1 = Array(repeating: -1, count: p1.count)
        var offstring2 = Array(repeating: -1, count: p1.count)
        var replacement1: [Int] = Array(repeating: -1, count: p1.count)
        var replacement2: [Int] = Array(repeating: -1, count: p1.count)


        for i in start...end {
            offspring1[i] = p2[i]
            offstring2[i] = p1[i]
            replacement1[p2[i]] = p1[i]
            replacement2[p1[i]] = p2[i]
        }
        
        for i in 0..<parent1.count {
            if i < start || i > end {
                var n1 = p1[i]
                var m1 = replacement1[n1]
                
                var n2 = p2[i];
                var m2 = replacement2[n2]
                
                while m1 != -1 {
                    n1 = m1
                    m1 = replacement1[m1]
                }
                while m2 != -1 {
                    n2 = m2
                    m2 = replacement2[m2]
                }
                
                offspring1[i] = n1
                offstring2[i] = n2
            }
        }
        return (offspring1.map { String(format: "%d", $0)}, offstring2.map { String(format: "%d", $0)})
        
        //let start = 3
        //let end = 5
        //child 1 get subString Parent 2 ,child 2 get substring parent 1
//        var subArray1 = parent2[start...end ] // child 1
//        var subArray2 = parent1[start...end] // child 2
//        var child1 = parent1[0..<start] +  subArray1 + parent1[(end+1)..<parent1.count]
//        var child2 = parent2[0..<start] + subArray2 + parent2[(end+1)..<parent1.count]
//        for i in start...end {
//            let value1 = subArray1[i]
//            let value2 = subArray2[i]
//            if value1 == value2 { continue }
//            if subArray2.contains(value1) && subArray1.contains(value2) { continue}
//            // find index in child1 == value1
//            if let indexHead = parent1[0...start].index(of: value1) {
//                child1[indexHead] = value2
//            }
//            if let indexTail = parent1[end...parent1.count - 1].index(of: value1) {
//                child1[indexTail] = value2
//            }
//            // find index in child2 == value2
//            if let indexHead = parent2[0...start].index(of: value2) {
//                child2[indexHead] = value1
//            }
//            if let indexTail = parent2[end...parent1.count - 1].index(of: value2) {
//                child2[indexTail] = value1
//            }
//        }
//        return (Array(child1),Array(child2))
    }
}




