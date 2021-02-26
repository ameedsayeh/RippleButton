//
//  RippleButton.swift
//  Ripple
//
//  Created by Ameed Sayeh on 21/02/2021.
//

import UIKit

class RippleButton: UIButton {
    
    var rippleColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    var overRippleColor: UIColor = UIColor.gray.withAlphaComponent(0.2)
    
    var initialRippleRadius: CGFloat = 10
    var initialOverRippleRadius: CGFloat = 5
    
    var rippleAnimationTime: TimeInterval = 1.5
    var overRippleAnimationTime: TimeInterval = 1.8
    
    var overRippleDelay: TimeInterval = 0.1
    
    lazy var rippleLayer = CAShapeLayer()
    lazy var overRippleLayer = CAShapeLayer()
    
    var shouldShowOverRipple = true
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.layer.masksToBounds = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        guard let firstTouch = touches.first else { return }
        
        let point = firstTouch.location(in: self)
        
        self.insertRippleCircle(at: point)
        self.animateRippleScale(at: point)
        
        if self.shouldShowOverRipple {
            
            self.insertOverRippleCircle(at: point)
            self.animateOverRippleScale(at: point)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        self.rippleLayer.removeFromSuperlayer()
        self.overRippleLayer.removeFromSuperlayer()
    }
    
    private func insertRippleCircle(at point: CGPoint) {
        
        self.rippleLayer.path = self.computeInitialRipplePath(at: point)
        self.rippleLayer.fillColor = rippleColor.cgColor
        
        if let firstLayer = self.layer.sublayers?.first {
            self.layer.insertSublayer(self.rippleLayer, below: firstLayer)
        }
    }
    
    private func insertOverRippleCircle(at point: CGPoint) {
        
        self.overRippleLayer.path = self.computeInitialOverRipplePath(at: point)
        self.overRippleLayer.fillColor = overRippleColor.cgColor
        
        if let firstLayer = self.layer.sublayers?.first {
            self.layer.insertSublayer(self.overRippleLayer, above: firstLayer)
        }
    }
    
    private func animateRippleScale(at point: CGPoint) {
        
        let scaleAnimation = CABasicAnimation(keyPath: "path")
        
        scaleAnimation.fromValue = self.computeInitialRipplePath(at: point)
        scaleAnimation.toValue = self.computeFinalRipplePath(at: point)
        scaleAnimation.duration = self.rippleAnimationTime
        scaleAnimation.fillMode = .forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        scaleAnimation.isRemovedOnCompletion = false
        
        self.rippleLayer.add(scaleAnimation, forKey: "scaleRipple")
    }
    
    private func animateOverRippleScale(at point: CGPoint) {
        
        let scaleAnimation = CABasicAnimation(keyPath: "path")
        
        scaleAnimation.fromValue = self.computeInitialOverRipplePath(at: point)
        scaleAnimation.toValue = self.computeFinalRipplePath(at: point)
        scaleAnimation.duration = self.overRippleAnimationTime
        scaleAnimation.beginTime = CACurrentMediaTime() + self.overRippleDelay
        scaleAnimation.fillMode = .forwards
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        scaleAnimation.isRemovedOnCompletion = false
        
        self.overRippleLayer.add(scaleAnimation, forKey: "scaleOverRipple")
    }
}

extension RippleButton {
    
    internal func computeInitialRipplePath(at point: CGPoint) -> CGPath {
        
        let origin = CGPoint(x: point.x - self.initialRippleRadius, y: point.y - self.initialRippleRadius)
        let size = CGSize(width: self.initialRippleRadius * 2, height: self.initialRippleRadius * 2)
        
        return UIBezierPath(ovalIn: CGRect(origin: origin, size: size)).cgPath
    }
    
    internal func computeInitialOverRipplePath(at point: CGPoint) -> CGPath {
        
        let origin = CGPoint(x: point.x - self.initialOverRippleRadius, y: point.y - self.initialOverRippleRadius)
        let size = CGSize(width: self.initialOverRippleRadius * 2, height: self.initialOverRippleRadius * 2)
        
        return UIBezierPath(ovalIn: CGRect(origin: origin, size: size)).cgPath
    }
    
    internal func computeFinalRipplePath(at point: CGPoint) -> CGPath {
        
        let maxRadius = self.bounds.diagonal
        
        let origin = CGPoint(x: point.x - maxRadius, y: point.y - maxRadius)
        let size = CGSize(width: maxRadius * 2, height: maxRadius * 2)
        
        return UIBezierPath(ovalIn: CGRect(origin: origin, size: size)).cgPath
    }
}

extension CGRect {
    
    var diagonal: CGFloat {
        
        let a = self.width
        let b = self.height
        
        return CGFloat(sqrt(Double(a*a + b*b)))
    }
}
