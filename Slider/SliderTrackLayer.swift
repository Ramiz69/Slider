//
//  SliderTrackLayer.swift
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

public final class SliderTrackLayer: CALayer {
    
    public var value: CGFloat = .zero
    public var minimumValue: CGFloat = .zero
    public var maximumValue: CGFloat = 1
    public var thumbWidth: CGFloat = .zero
    public var trackMaxColor: UIColor!
    public var trackMinColor: UIColor!
    
    override public func draw(in ctx: CGContext) {
        ctx.setFillColor(trackMaxColor.cgColor)
        ctx.addPath(UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath)
        ctx.fillPath()
        
        let trackWidth = bounds.width - cornerRadius
        let range = maximumValue - minimumValue
        var thresholdX: CGFloat = ((value - minimumValue) / range * trackWidth)
        let averangeValue = value - minimumValue
        if averangeValue > .zero {
            if averangeValue >= maximumValue / 2 {
                thresholdX += thumbWidth / 6
            } else {
                thresholdX += thumbWidth / 3
            }
        }
        if value == maximumValue {
            thresholdX += -thumbWidth / 3
        }
        let width = thresholdX.rounded(.down)
        let trackMinSize = CGSize(width: width, height: bounds.height)
        let trackMinRect = CGRect(origin: .zero, size: trackMinSize)
        let trackMinPath = UIBezierPath(roundedRect: trackMinRect, cornerRadius: cornerRadius)
        ctx.setFillColor(trackMinColor.cgColor)
        ctx.addPath(trackMinPath.cgPath)
        ctx.fillPath()
        
        let widthDifference = value >= minimumValue ? .zero : bounds.width - thresholdX
        let trackMaxRect = CGRect(x: thresholdX - cornerRadius, y: .zero,
                                  width: widthDifference,
                                  height: bounds.height)
        let trackMaxPath = UIBezierPath(roundedRect: trackMaxRect,
                                        cornerRadius: cornerRadius)
        ctx.setFillColor(trackMinColor.cgColor)
        ctx.addPath(trackMaxPath.cgPath)
        ctx.fillPath()
    }
}
