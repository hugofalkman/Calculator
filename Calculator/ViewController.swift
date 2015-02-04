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
    
    var userIsTyping = false
    
    var brain = CalculatorBrain()
    
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
            if let result = brain.performOperation(operation){
                displayValue = result
            } else {
                displayValue = 0
            }
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
        userIsTyping = false
        brain = CalculatorBrain()
    }
    
    @IBAction func backspace() {
        if userIsTyping {
            display.text = dropLast(display.text!)
            if countElements(display.text!) == 0 {
                userIsTyping = false
                if let result = brain.evaluate() {
                    displayValue = result
                } else {
                    displayValue = 0
                }
            }
        }
    }
    
    @IBAction func enter() {
        userIsTyping = false
        if let result = brain.pushOperand(displayValue) {
            displayValue = result
        } else {
            displayValue = 0
        }
    }

    // computed value for UILabel display.text
    var displayValue: Double {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            display.text = "\(newValue)"
            userIsTyping = false
        }
    }
}









