//
//  SliderTextLayer.swift
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

public class SliderTextLayer: CATextLayer {
    
    public var trackMaxColor: UIColor!
    public var trackMinColor: UIColor!
    
    public override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        configureBorder()
    }
    
    override public func draw(in ctx: CGContext) {
        let height = bounds.size.height
        let yDiff = (height - fontSize) / 2 - fontSize / 10
        
        ctx.saveGState()
        ctx.translateBy(x: .zero, y: yDiff)
        super.draw(in: ctx)
        
        ctx.restoreGState()
    }
    
    open func configureBorder() {
        foregroundColor = trackMinColor.cgColor
        borderWidth = 4
        borderColor = trackMinColor.cgColor
    }
    
}

public final class SliderMinimumTextLayer: SliderTextLayer {
    
    public override func configureBorder() {
        
    }
    
}

public final class SliderMaximumTextLayer: SliderTextLayer {
    
    public override func configureBorder() {
        
    }
    
}
