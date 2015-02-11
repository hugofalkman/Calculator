//
//  ViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-01-27.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var stackDisplay: UILabel!
    
    var displayResult: Result = Result.Value(0.0) {
        didSet {
            switch displayResult {
            case .Value(let value):
                displayValue = value
            case .Error:
                displayValue = nil
            }
        }
    }
    
    var userIsTyping = false
    
    var brain = CalculatorBrain()
    
    // computed property displayValue mirroring UILabel display.text
    var displayValue: Double? {
        get {
            // set formatter to use US format (dot not comma)
            var formatter = NSNumberFormatter()
            formatter.locale = NSLocale(localeIdentifier:  "en_US")
            // nsNumber is nil if display.text does not contain number
            let nsNumber = formatter.numberFromString(display.text!)
            if let actualNSNumber = nsNumber {
                return actualNSNumber.doubleValue
            } else {
                return nil
            }
        }
        set {
            // using the description variable of the 
            // displayResult enum adhering to the printable protocol
            display.text = displayResult.description
            userIsTyping = false
            stackDisplay.text = brain.description
        }
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
        display.text = "0"
        displayResult = Result.Value(0.0)
        stackDisplay.text = " "
        userIsTyping = false
        brain = CalculatorBrain()
    }
    
    @IBAction func backspace() {
        if userIsTyping {
            display.text = dropLast(display.text!)
            if countElements(display.text!) == 0 {
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
        brain.pushOperand(displayValue!)
        displayResult = brain.evaluate()
    }
}









