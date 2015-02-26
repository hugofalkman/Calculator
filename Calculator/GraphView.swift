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
    
    var origo: CGPoint? {didSet {setNeedsDisplay()}
    }
    
    @IBInspectable
    var scale: CGFloat = 25 {didSet {setNeedsDisplay()}}
    
    func scaleUp(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .Changed {
            scale *= 2 - gesture.scale
            gesture.scale = 1
        }
    }
    
    func moveOrigin(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .Ended: fallthrough
        case .Changed:
            let translation = gesture.translationInView(self)
            if translation != CGPointZero {
                origo!.x += translation.x
                origo!.y += translation.y
                gesture.setTranslation(CGPointZero, inView: self)
            }
        default: break
        }
    }
    
    func setOrigin(gesture: UITapGestureRecognizer) {
        gesture.numberOfTapsRequired = 2
        if gesture.state == .Ended {
            origo = gesture.locationInView(self)
        }
    }
    
    override var bounds: CGRect {
        didSet {
            origo = convertPoint(center, fromView: superview)
        }
    }
    
    override func drawRect(rect: CGRect) {
        
        var drawBounds = bounds
        drawBounds.size.width *= scaleSize
        drawBounds.size.height *= scaleSize
        drawBounds.origin.x += drawBounds.size.width * scaleOrigin
        drawBounds.origin.y += drawBounds.size.height * scaleOrigin
        
        axesdrawer.drawAxesInRect(drawBounds, origin: origo!, pointsPerUnit: scale)
    }
}

        