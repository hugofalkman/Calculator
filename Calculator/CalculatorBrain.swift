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
        // last parameter for unary and binary is the error test function
        case UnaryOperation(String, Double -> Double, (Double -> String?)?)
        // third parameter for binary is order of precedence
        case BinaryOperation(String, (Double, Double) -> Double, Int, ((Double, Double) -> String?)?)
       
        // computed property describing the Op enum cases
        var description: String {
            switch self {
            case .Operand(let operand):
                return "\(operand)"
            case .Variable(let symbol):
                return symbol
            case .NullaryOperation(let symbol, _):
                return symbol
            case .UnaryOperation(let symbol, _, _):
                return symbol
            case .BinaryOperation(let symbol, _, _, _):
                return symbol
            }
        }
        
        // computed property setting order of predecence for binary operations
        var opOrder: Int {
            switch self {
            case .BinaryOperation(_, _, let prec, _):
                return prec
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
        
        learnOp(Op.BinaryOperation("×", *, 2, nil))
        learnOp(Op.BinaryOperation("÷", {$1 / $0}, 2) {
            s0, s1 in
            if s0 == 0.0 {
                return "Error: Division by zero"
            } else {
                return nil
            }
                })
        learnOp(Op.BinaryOperation("+", +, 1, nil))
        learnOp(Op.BinaryOperation("−", {$1 - $0}, 1, nil))
        learnOp(Op.BinaryOperation("^", {pow($1, $0)}, 3, nil))
        learnOp(Op.UnaryOperation("√",sqrt) {
            s0 in
            if s0 < 0.0 {
                return "Error: Sq. root of negative number"
            } else {
                return nil
            }
            })
        learnOp(Op.UnaryOperation("sin",sin, nil))
        learnOp(Op.UnaryOperation("cos",cos, nil))
        learnOp(Op.UnaryOperation("tan",tan, nil))
        learnOp(Op.UnaryOperation("asin",asin, nil))
        learnOp(Op.UnaryOperation("acos",acos, nil))
        learnOp(Op.UnaryOperation("atan",atan, nil))
        learnOp(Op.UnaryOperation("exp",exp, nil))
        learnOp(Op.UnaryOperation("ln",log, nil))
        learnOp(Op.UnaryOperation("2log",log2, nil))
        learnOp(Op.UnaryOperation("inv", {1.0 / $0}, nil))
        learnOp(Op.UnaryOperation("+⁄-", {-$0}, nil))
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
    private func evaluate(ops: [Op]) -> (value: Double?, error: String, remainingOps: [Op]) {
        
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, " ", remainingOps)
            case .Variable(let variable):
                if let varValue = variableValues[variable] {
                    return (varValue, " ", remainingOps)
                } else {
                    return (nil, "Error: Variable \(variable) not set", remainingOps)
                }
            case .NullaryOperation(_, let operation):
                return (operation(), " ", remainingOps)
            case .UnaryOperation(_, let operation, let errorTest):
                let operandEvaluation = evaluate(remainingOps)
                if let operand = operandEvaluation.value {
                    if let errMessage = errorTest?(operand) {
                        return (nil, errMessage, remainingOps)
                    } else {
                        return (operation(operand), " ", operandEvaluation.remainingOps)
                    }
                }
            case .BinaryOperation(_, let operation, _, let errorTest):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.value {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.value {
                        if let errMessage = errorTest?(operand1, operand2) {
                            return (nil, errMessage, remainingOps)
                        } else {
                            return (operation(operand1, operand2), " ", op2Evaluation.remainingOps)
                        }
                    }
                }
            }
        }
        return (nil, "Error: Too few operands", ops)
    }
    
    func evaluate() -> (value: Double?, error: String) {
        let (value, error, remainder) = evaluate(opStack)
        // println("\(opStack) = \(result) with \(remainder) left over")
        // println(description)
        return (value, error)
    }
    
    func pushOperand(operand: Double) {
        opStack.append(Op.Operand(operand))
    }
    
    func pushOperand(symbol: String) {
        opStack.append(Op.Variable(symbol))
    }
    
    func performOperation(symbol: String) {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
    }
    
    func popStack() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
}

