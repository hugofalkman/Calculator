//
//  StatGraphViewController.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-03-04.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import  UIKit

class StatGraphViewController: GraphViewController, UIPopoverPresentationControllerDelegate {
    
    var stats: String {
        let k = 100000.0
        var string = "\(graphView.num) plotted values\nMinimum value: \(Double(Int(k * Double(graphView.min))) / k)\n"
        if graphView.num != 0 {
        string += "Average value: \(Double(Int(k * Double(graphView.sum) / Double(graphView.num))) / k)\n"
        }
        string += "Maximum value: \(Double(Int(k * Double(graphView.max))) / k)"
        return string
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let _ = segue.identifier {
            if let tvc = segue.destinationViewController as? TextViewController {
                if let ppc = tvc.popoverPresentationController {
                    ppc.delegate = self
                }
                tvc.text = stats
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
}




