//
//  GraphView.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

@IBDesignable
class GraphView: UIView {
    
    override var contentScaleFactor: CGFloat {didSet {setNeedsDisplay()}}
    
    var scaleSize: CGFloat = 0.9 {didSet {setNeedsDisplay()}}
    var scaleOrigin: CGFloat {
        return ((1 - scaleSize) / 2)
    }
    
    let axesdrawer = AxesDrawer(color: UIColor.blackColor())
    
    var origo: CGPoint {
        get {return convertPoint(center, fromView: superview)}
        set {setNeedsDisplay()}
    }
    var scale: CGFloat = 25 {didSet {setNeedsDisplay()}}
    
    func viewDidLoad() {
        axesdrawer.contentScaleFactor = self.contentScaleFactor
        let test: CGRect = bounds
        
    }
    
    override func drawRect(rect: CGRect) {
        var drawBounds = bounds
        drawBounds.size.width *= scaleSize
        drawBounds.size.height *= scaleSize
        drawBounds.origin.x += drawBounds.size.width * scaleOrigin
        drawBounds.origin.y += drawBounds.size.height * scaleOrigin
        axesdrawer.drawAxesInRect(drawBounds, origin: origo, pointsPerUnit: scale)
    }
}

        