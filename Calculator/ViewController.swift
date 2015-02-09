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
    
    var displayResult: (value: Double?, error: String) = (nil, " ")
    
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
            if let actualNewValue = newValue {
                display.text = "\(actualNewValue)"
            } else {
                display.text = displayResult.error
            }
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
            updateValue()
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
        stackDisplay.text = " "
        userIsTyping = false
        brain = CalculatorBrain()
    }
    
    @IBAction func backspace() {
        if userIsTyping {
            display.text = dropLast(display.text!)
            if countElements(display.text!) == 0 {
                userIsTyping = false
                updateValue()
            }
        } else {
            brain.popStack()
            updateValue()
        }
    }
    
    @IBAction func setM() {
        userIsTyping = false
        brain.variableValues["M"] = displayValue
        updateValue()
    }
    
    @IBAction func pushM() {
        userIsTyping = false
        brain.pushOperand("M")
        updateValue()
    }
    
    @IBAction func enter() {
        userIsTyping = false
        brain.pushOperand(displayValue!)
        updateValue()
    }

    private func updateValue() {
        displayResult = brain.evaluate()
        displayValue = displayResult.value
    }
}









