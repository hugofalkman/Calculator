//
//  CalculatorViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-01-27.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//  C

import UIKit

class CalculatorViewController: UIViewController, GraphViewControllerDataSource {

    private struct Constants {
        static let scaleDefault: CGFloat = 20.0
    }
    
    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var stackDisplay: UILabel!
    
    var userIsTyping = false
    
    private var brain = CalculatorBrain()
    
    // property storing the evaluation results from the brain model
    // its Result type defined by enum in the brain model
    var displayResult: CalculatorBrain.Result = .Value(0.0) {
        // also updates the two IBOutlet text fields
        didSet {
            // using the description property of the
            // Result enum adhering to the printable protocol
            display.text = displayResult.description
            userIsTyping = false
            stackDisplay.text = brain.description
        }
    }
    
    // computed read-only property mirroring UILabel display.text
    var displayValue: Double {
        // set formatter to use US format (dot not comma)
        var formatter = NSNumberFormatter()
        formatter.locale = NSLocale(localeIdentifier:  "en_US")
        return formatter.numberFromString(display.text!)!.doubleValue
    }

    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsTyping {
            // skip if second dot entered, in all other cases execute
            if digit != "." || nil == display.text?.rangeOfString(".") {
            display.text = display.text! + digit
            }
        } else {
            display.text = digit
            userIsTyping = true
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsTyping {
            enter()
        }
        if let operation = sender.currentTitle {
            brain.performOperation(operation)
            displayResult = brain.evaluate()
        }
    }
    
    @IBAction func sign(sender: UIButton) {
        // first address the +⁄- while typing case
        if userIsTyping {
            if display.text!.hasPrefix("-") {
                display.text = dropFirst(display.text!)
            } else {
                display.text = "-" + display.text!
            }
        } else if display.text == "0" {
            // case when typing starts with the +⁄- key
            display.text = "-"
            userIsTyping = true
        } else {
            // if not typing treat like any other operator
            operate(sender)
        }
    }

    @IBAction func clear() {
        brain = CalculatorBrain()
        display.text = "0"
        stackDisplay.text = " "
        userIsTyping = false
        scale = Constants.scaleDefault
        origoRelCenter = CGPointZero
    }
    
    @IBAction func backspace() {
        if userIsTyping {
            display.text = dropLast(display.text!)
            if count(display.text!) == 0 {
                userIsTyping = false
                displayResult = brain.evaluate()
            }
        } else {
            brain.popStack()
            displayResult = brain.evaluate()
        }
    }
    
    @IBAction func setM() {
        userIsTyping = false
        brain.variableValues["M"] = displayValue
        displayResult = brain.evaluate()
    }
    
    @IBAction func pushM() {
        userIsTyping = false
        brain.pushOperand("M")
        displayResult = brain.evaluate()
    }
    
    @IBAction func enter() {
        userIsTyping = false
        brain.pushOperand(displayValue)
        displayResult = brain.evaluate()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        var destination = segue.destinationViewController as? UIViewController
        if let navCon = destination as? UINavigationController {
            destination = navCon.visibleViewController
        }
        if let gvc = destination as? GraphViewController {
            if let _ = segue.identifier {
                gvc.dataSource = self
                gvc.brainPList = brain.program
                gvc.scale = scale
                gvc.origoRelCenter = origoRelCenter
            }
        }
    }
    
    // delegate properties will be kept as long as app remains in background
    // properties returned to default by clear button
    var scale: CGFloat = Constants.scaleDefault
    var origoRelCenter: CGPoint = CGPointZero
}









