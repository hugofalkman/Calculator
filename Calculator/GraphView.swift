//
//  GraphView.swift
//  Calculator
//
//  Created by H Hugo Falkman on 2015-02-25.
//  Copyright (c) 2015 H Hugo Fakman. All rights reserved.
//

import UIKit

protocol GraphViewDataSource: class {
    func yForX(sender: GraphView, x: CGFloat) -> CGFloat?
    var origoRelCenter: CGPoint {get set}
    var scale: CGFloat {get}
}

@IBDesignable
class GraphView: UIView {
    
    // properties to decrease window to draw in from all of bounds
    var scaleSize: CGFloat = 0.9 {didSet {setNeedsDisplay()}}
    var scaleOrigin: CGFloat {
        return ((1 - scaleSize) / 2)
    }
    
    let axesdrawer = AxesDrawer(color: UIColor.blackColor())
    
    @IBInspectable
    var scale: CGFloat = 25
    @IBInspectable
    var color: UIColor = UIColor.blueColor() {didSet {setNeedsDisplay()}}
    @IBInspectable
    var lineWidth: CGFloat = 1.0 {didSet {setNeedsDisplay()}}
    var origo: CGPoint = CGPointZero
    
    func setOrigin(gesture: UITapGestureRecognizer) {
        gesture.numberOfTapsRequired = 2
        if gesture.state == .Ended {
            let orig = gesture.locationInView(self)
            dataSource?.origoRelCenter.x = orig.x - bounds.midX
            dataSource?.origoRelCenter.y = orig.y - bounds.midY
        }
    }
    
    weak var dataSource: GraphViewDataSource?
    
    override func drawRect(rect: CGRect) {
        
        // scale the bounds window
        var drawBounds = bounds
        drawBounds.size.width *= scaleSize
        drawBounds.size.height *= scaleSize
        drawBounds.origin.x += drawBounds.size.width * scaleOrigin
        drawBounds.origin.y += drawBounds.size.height * scaleOrigin
        
        // setting origo and scale from the delegate
        scale = dataSource?.scale ?? scale
        let orig = dataSource?.origoRelCenter ?? CGPointZero
            origo.x = orig.x + bounds.midX
            origo.y = orig.y + bounds.midY
        
        axesdrawer.contentScaleFactor = contentScaleFactor
        axesdrawer.drawAxesInRect(drawBounds, origin: origo, pointsPerUnit: scale)
        drawCurveInRect(drawBounds, origin: origo, pointsPerUnit: scale)
    }
    
    func drawCurveInRect(bounds: CGRect, origin: CGPoint, pointsPerUnit: CGFloat) {
        color.set()
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        var disContinuity = true
        var point = CGPoint()
        
        for i in 0...Int(bounds.size.width * contentScaleFactor) {
            point.x = bounds.minX + CGFloat(i) / contentScaleFactor
            if let y = dataSource?.yForX(self, x: (point.x - origin.x) / scale) {
                if y.isNormal || y.isZero  {
                    point.y = origin.y - y * scale
                    if point.y >= bounds.minY && point.y <= bounds.maxY {
                        if disContinuity {
                            path.moveToPoint(point)
                            disContinuity = false
                        } else {
                            path.addLineToPoint(point)
                        }
                    } else {disContinuity = true}
                } else {disContinuity = true}
            } else {disContinuity = true}
        }
        path.stroke()
    }
}






