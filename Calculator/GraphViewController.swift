//
//  GraphViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

protocol GraphViewControllerDataSource: class {
    var origoRelCenter: CGPoint {get set}
    var scale: CGFloat {get set}
}

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
    weak var dataSource: GraphViewControllerDataSource?
    
    // property list for setting calculator brain opstack. set from calculator view controller
    var brainPList: AnyObject? {
        didSet {
            brain.variableValues["M"] = 0
            brain.program = brainPList!
            title = brain.description.componentsSeparatedByString(",").last ?? " "
            if count(title!) > 1 {title = "y = " + dropLast(dropLast(title!))}
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
    // variables set by gestures that in turn set the corresponding delegate variables
    var scale: CGFloat = 20.0 {didSet{
        graphView?.setNeedsDisplay()
        dataSource?.scale = scale}}
    var origoRelCenter: CGPoint = CGPointZero {didSet{
        graphView?.setNeedsDisplay()
        dataSource?.origoRelCenter = origoRelCenter}}
}



