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
        
        // treat +⁄- while typing case separate and return
        if sender.currentTitle == "+⁄-" &&
            (userIsTyping || display.text == "0") {
            if displayValue < 0 {
                display.text = dropFirst(display.text!)
            } else if userIsTyping {
                display.text = "-" + display.text!
            } else {
                // case when typing starts with +⁄-
                display.text = "-"
                userIsTyping = true
            }
            return
        }
        
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









