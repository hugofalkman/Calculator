//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-01-28.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import Foundation

class CalculatorBrain {
    
    private enum Op: Printable {
        case Operand(Double)
        case Variable(String)
        case NullaryOperation(String, () -> Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
       
        // computed property describing the Op enum cases
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .Variable(let symbol):
                return symbol
            case .NullaryOperation(let symbol, _):
                return symbol
            case .UnaryOperation(let symbol, _):
                return symbol
            case .BinaryOperation(let symbol, _):
                return symbol
            }
        }
        
        // computed property setting order of predecence for binary operations
        var opOrder: Int {
            switch self {
            case .BinaryOperation(let symbol, _):
                if symbol == "^" {
                    return 3
                } else if symbol == "×" || symbol == "÷" {
                    return 2
                } else {
                    return 1
                }
            default:
                return Int.max
            }
        }
    }
    
    private var opStack = [Op]()
    
    private var knownOps = [String: Op]()
    
    //  public property to allow setting of variables
    var variableValues = [String: Double]()

    // description of opStack passed to UI by the View Controller
    // computed read only property (get only)
    var description: String {
        var remainder = opStack
        var result = ""
        while !remainder.isEmpty {
            let opDescribe = describe(remainder)
            let op = opDescribe.result ?? "?"
            result = " " + op + "," + result
            remainder = opDescribe.remainingOps
        }
        if result == "" {
            return result
        } else {
            return dropFirst(dropLast(result)) + " ="
        }
    }
    
        init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×",*))
        learnOp(Op.BinaryOperation("÷") {$1 / $0})
        learnOp(Op.BinaryOperation("+",+))
        learnOp(Op.BinaryOperation("−") {$1 - $0})
        learnOp(Op.BinaryOperation("^") {pow($1, $0)})
        learnOp(Op.UnaryOperation("√",sqrt))
        learnOp(Op.UnaryOperation("sin",sin))
        learnOp(Op.UnaryOperation("cos",cos))
        learnOp(Op.UnaryOperation("tan",tan))
        learnOp(Op.UnaryOperation("asin",asin))
        learnOp(Op.UnaryOperation("acos",acos))
        learnOp(Op.UnaryOperation("atan",atan))
        learnOp(Op.UnaryOperation("exp",exp))
        learnOp(Op.UnaryOperation("ln",log))
        learnOp(Op.UnaryOperation("2log",log2))
        learnOp(Op.UnaryOperation("inv") {1.0 / $0})
        learnOp(Op.UnaryOperation("+⁄-") {-$0})
        learnOp(Op.NullaryOperation("π") {M_PI})
        learnOp(Op.NullaryOperation("e") {M_E})
    }
    
    // recursive helper function for public computed property "description"
    private func describe(ops: [Op]) -> (result: String?, prec: Int?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            let prec = op.opOrder
            let opDesc = op.description
            
            switch op {
            case .UnaryOperation:
                let op1Desc = describe(remainingOps)
                let operand1 = op1Desc.result ?? "?"
                return (opDesc + "(" + operand1 + ")", prec, op1Desc.remainingOps)
                
            case .BinaryOperation:
                let op1Desc = describe(remainingOps)
                var operand1 = op1Desc.result ?? "?"
                let prec1 = op1Desc.prec ?? Int.max
                if prec1 < prec {
                    operand1 = "(" + operand1 + ")"
                }
                
                let op2Desc = describe(op1Desc.remainingOps)
                var operand2 = op2Desc.result ?? "?"
                let prec2 = op2Desc.prec ?? Int.max
                if prec2 < prec {
                    operand2 = "(" + operand2 + ")"
                }
                
                return (operand2 + opDesc + operand1, prec, op2Desc.remainingOps)
                
            default:
                return (opDesc, prec, remainingOps)
            }
            
        } else {
            return (nil, nil, ops)
        }
    }
    
    // recursive helper function for public evaluate method below
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                return (variableValues[variable], remainingOps)
            case .NullaryOperation(_, let operation):
                return (operation(), remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                    }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        // println("\(opStack) = \(result) with \(remainder) left over")
        // println(description)
        return result
    }
    
    func pushOperand(operand: Double) -> Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        return evaluate()
    }
    
    func popStack() -> Double? {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
        return evaluate()
    }
}

