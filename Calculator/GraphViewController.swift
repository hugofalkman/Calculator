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
}
