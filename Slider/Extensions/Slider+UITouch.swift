//
//  Slider+UITouch.swift
//
//  Copyright (c) 2020 Ramiz Kichibekov (https://instagram.com/kichibekov69)
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
    
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previousTouchPoint = touch.location(in: self)
        if thumbLayer.frame.contains(previousTouchPoint) {
            delegate?.didBeginTracking(self)
            
            return true
        }
        
        return false
    }
    
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        let delta = (touchPoint.x - previousTouchPoint.x).rounded(.toNearestOrEven)
        let ratio = delta / usableTrackingLength
        let valueDelta = ((maximum - minimum) * ratio).rounded(.toNearestOrEven)
        let tempValue = value + valueDelta
        let noOfStep = (tempValue / step).rounded(.toNearestOrEven)
        var currentValue = noOfStep * step
        if (currentValue == maximum || currentValue == minimum) && currentValue != value {
            hapticConfiguration.reachValueGenerate()
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
        hapticConfiguration.valueGenerate()
        previousTouchPoint = touchPoint
        delegate?.didContinueTracking(self)
        if continuous {
            sendActions(for: .valueChanged)
        }
        
        return true
    }
    
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        if step > .zero {
            let noOfStep = (value / step).rounded(.toNearestOrEven)
            value = noOfStep * step
            delegate?.didEndTracking(self)
        }
        if !continuous {
            sendActions(for: .valueChanged)
        }
    }
    
}
