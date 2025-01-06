//
//  Slider+UITouch.swift
//
//  Copyright (c) 2020 Ramiz Kichibekov (https://github.com/ramiz69)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

extension Slider {
    
    /// Notifies the control when a touch event enters the control’s bounds.
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTouchPoint = touch.location(in: self)
        if thumbLayer.frame.contains(previousTouchPoint) {
            didBeginTracking()
            delegate?.didBeginTracking(self)
            let (sharpness, intensity) = sharpnessAndIntensityAt(location: previousTouchPoint)
            try? hapticManager.playTransientHaptic(intensity: intensity, sharpness: sharpness)
            if hapticConfiguration.kind.contains(.continuous) {
                transientTimer?.cancel()
                transientTimer = DispatchSource.makeTimerSource(queue: .main)
                if let timer = transientTimer {
                    timer.schedule(deadline: .now() + .milliseconds(750), repeating: .milliseconds(600))
                    timer.setEventHandler() { [unowned self] in
                        let (sharpness, intensity) = self.sharpnessAndIntensityAt(location: self.previousTouchPoint)
                        try? hapticManager.playTransientHaptic(intensity: intensity, sharpness: sharpness)
                    }
                    timer.resume()
                }
            }

            return true
        }
        
        return false
    }
    
    /// Notifies the control when a touch event for the control updates.
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        let deltaLocation: CGFloat
        switch direction {
            case .leftToRight, .rightToLeft:
                deltaLocation = (touchPoint.x - previousTouchPoint.x).rounded(.toNearestOrEven)
            case .bottomToTop, .topToBottom:
                deltaLocation = (touchPoint.y - previousTouchPoint.y).rounded(.toNearestOrEven)
        }
        let ratio = deltaLocation / usableTrackingLength
        let deltaValue = ((maximum - minimum) * ratio).rounded(.toNearestOrEven)
        let tempValue: CGFloat
        switch direction {
            case .leftToRight, .topToBottom:
                tempValue = value + deltaValue
            case .rightToLeft, .bottomToTop:
                tempValue = value - deltaValue
        }
        let noOfStep = (tempValue / step).rounded(.toNearestOrEven)
        var currentValue = noOfStep * step
        if (currentValue == maximum || currentValue == minimum) && currentValue != value {
            if currentValue == minimum {
                try? hapticManager.playTransientHaptic(intensity: hapticConfiguration.initialIntensity,
                                                       sharpness: hapticConfiguration.initialSharpness)
            } else if currentValue == maximum {
                try? hapticManager.playTransientHaptic(intensity: 1, sharpness: 1)
            }
        }
        if currentValue > maximum {
            currentValue = maximum
        } else if currentValue < minimum {
            currentValue = minimum
        }
        if currentValue == value {
            return true
        }
        
        value = currentValue
        previousTouchPoint = touchPoint
        sendActions(for: .valueChanged)
        
        return true
    }
    
    /// Notifies the control when a touch event associated with the control ends.
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        endTracking()
        if step > .zero {
            let noOfStep = (value / step).rounded(.toNearestOrEven)
            value = noOfStep * step
            delegate?.didEndTracking(self)
            if hapticConfiguration.kind.contains(.continuous) {
                transientTimer?.cancel()
                transientTimer = nil
            }
        }
        if !continuous {
            sendActions(for: .valueChanged)
        }
    }
    
}
