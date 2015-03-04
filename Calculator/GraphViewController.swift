//
//  GraphViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, GraphViewDataSource
{
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.dataSource = self
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "setOrigin:"))
        }
    }
    
    // property storing the evaluation results from the brain model
    // its Result type defined by enum in the brain model
    var displayResult: CalculatorBrain.Result = .Error("")
    
    private var brain = CalculatorBrain()
    
    // property list for setting calculator brain opstack. set from calculator view controller
    var brainPList: AnyObject? {
        didSet {
            brain.variableValues["M"] = 0
            brain.program = brainPList!
            title = brain.description.componentsSeparatedByString(",").last ?? " "
            if countElements(title!) > 1 {title = "y = " + dropLast(dropLast(title!))}
            updateUI()
        }
    }
    
    func updateUI() {
        graphView?.setNeedsDisplay()
    }
    
    @IBAction func scaleUp(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= gesture.scale
            gesture.scale = 1
        }
    }

    @IBAction func moveOrigin(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(graphView)
            if translation != CGPointZero {
                origoRelCenter.x += translation.x
                origoRelCenter.y += translation.y
                gesture.setTranslation(CGPointZero, inView: graphView)
            }
        default: break
        }
    }
    
    // delegate method and properties
    func yForX(sender: GraphView, x: CGFloat) -> CGFloat? {
        brain.variableValues["M"] = Double(x)
        displayResult = brain.evaluate()
        switch displayResult {
        case .Value(let y): return CGFloat(y)
        case .Error: return nil
        }
    }
    var scale: CGFloat = 100.0 {didSet{graphView?.setNeedsDisplay()}}
    var origoRelCenter: CGPoint = CGPoint(x: 100, y: 0) {didSet{graphView?.setNeedsDisplay()}}
}



