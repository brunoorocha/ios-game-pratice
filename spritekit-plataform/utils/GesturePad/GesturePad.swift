//
//  GesturePad.swift
//  spritekit-demo
//
//  Created by Bruno Rocha on 11/02/19.
//  Copyright © 2019 Bruno Rocha. All rights reserved.
//

import SpriteKit

class GesturePad: NSObject {
    var view: SKView!
    var delegate: GesturePadDelegate!
    var leftArea: UIView!
    var rightArea: UIView!
    
    private var tapRecognizer: UITapGestureRecognizer!
    private var panRecognizer: UIPanGestureRecognizer!
    private var swipeUpRecognizer: UISwipeGestureRecognizer!
    private var swipeDownRecognizer: UISwipeGestureRecognizer!
    private let degressToRadians = Float(CGFloat.pi / 180)
    
    init(forView view: SKView) {
        super.init()
        self.view = view
        setupRecognizers()
    }
    
    private func setupRecognizers() {
        let areaSize = CGSize(width: self.view.frame.width / 2, height: self.view.frame.height)
        let xCenterPoint = self.view.frame.width / 2
        self.leftArea = UIView(frame: CGRect(origin: CGPoint(x: 0, y: 64.0), size: areaSize))
        self.rightArea = UIView(frame: CGRect(origin: CGPoint(x: xCenterPoint, y: 64.0), size: areaSize))
        
        self.tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        self.swipeUpRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        self.swipeDownRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        self.swipeUpRecognizer.direction = .up
        self.swipeDownRecognizer.direction = .down
        
        self.tapRecognizer.delegate = self
        self.panRecognizer.delegate = self
        self.swipeUpRecognizer.delegate = self
        self.swipeDownRecognizer.delegate = self
        
        
        self.leftArea.addGestureRecognizer(self.panRecognizer)
        self.rightArea.addGestureRecognizer(self.tapRecognizer)
        self.rightArea.addGestureRecognizer(self.swipeUpRecognizer)
        self.rightArea.addGestureRecognizer(self.swipeDownRecognizer)
        self.view.addSubview(self.leftArea)
        self.view.addSubview(self.rightArea)
    }
    
    func disable() {
        self.leftArea.isUserInteractionEnabled = false
        self.rightArea.isUserInteractionEnabled = false
    }
    
    func enable() {
        self.leftArea.isUserInteractionEnabled = true
        self.rightArea.isUserInteractionEnabled = true
    }
    
    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        delegate.performActionForTap()
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }

        if (gesture.state == .ended || gesture.state == .cancelled) {
            delegate.performActionForAnalogStopMoving()
        }
        
        if (gesture.state == .changed) {
            let translation = gesture.translation(in: view)
            var direction = float2(Float(translation.x), Float(translation.y))
            direction = normalize(direction)
            direction.x = direction.x.isNaN ? 0 : direction.x
            direction.y = direction.y.isNaN ? 0 : direction.y
            
            let directionInDegree = atan2(direction.x, direction.y)
            delegate.performActionForAnalogMoving(inAngle: CGFloat(directionInDegree), withDirectionX: CGFloat(direction.x), AndDirectionY: CGFloat(direction.y))
        }
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        if (gesture.state == .ended) {
            if (gesture.direction == .up) {
                delegate.performActionForSwipeUp()
            }
            else if(gesture.direction == .down) {
                delegate.performActionForSwipeDown()
            }
        }
    }
}

extension GesturePad: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if ((gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UISwipeGestureRecognizer) || (gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UITapGestureRecognizer)) {
            return true
        }
        
        return false
    }
}

protocol GesturePadDelegate {
    func performActionForAnalogMoving(inAngle angle: CGFloat, withDirectionX dx: CGFloat, AndDirectionY dy: CGFloat)
    func performActionForAnalogStopMoving()
    func performActionForTap()
    func performActionForSwipeUp()
    func performActionForSwipeDown()
}
