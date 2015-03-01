//
//  GraphViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController
{
    @IBOutlet weak var graphView: GraphView! {
        didSet {
            graphView.addGestureRecognizer(UIPinchGestureRecognizer(target: graphView, action: "scaleUp:"))
            graphView.addGestureRecognizer(UIPanGestureRecognizer(target: graphView, action: "moveOrigin:"))
            graphView.addGestureRecognizer(UITapGestureRecognizer(target: graphView, action: "setOrigin:"))
        }
    }
    
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
}
