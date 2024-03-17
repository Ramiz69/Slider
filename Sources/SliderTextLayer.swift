//
//  SliderTextLayer.swift
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
import QuartzCore
import CoreGraphics

class SliderTextLayer: CATextLayer {
    
    // MARK: Properties
    
    var trackMaxColor: UIColor!
    var trackMinColor: UIColor!
    
    // MARK: Initial methods
    
    init(trackMaxColor: UIColor, trackMinColor: UIColor) {
        self.trackMaxColor = trackMaxColor
        self.trackMinColor = trackMinColor
        super.init()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    override func setNeedsDisplay() {
        super.setNeedsDisplay()
        
        configureBorder()
    }
    
    override func draw(in ctx: CGContext) {
        let height = bounds.size.height
        let yDiff = (height - fontSize) / 2 - fontSize / 10
        
        ctx.saveGState()
        ctx.translateBy(x: .zero, y: yDiff)
        super.draw(in: ctx)
        
        ctx.restoreGState()
    }
    
    open func configureBorder() {
        assert(trackMaxColor != nil, "trackMaxColor should not be nil. Check the color initialization.")
        assert(trackMinColor != nil, "trackMinColor should not be nil. Check the color initialization.")
        foregroundColor = trackMinColor.cgColor
        borderWidth = 4
        borderColor = trackMinColor.cgColor
    }
    
}

final class SliderMinimumTextLayer: SliderTextLayer {
    
    override func configureBorder() {
        
    }
    
}

final class SliderMaximumTextLayer: SliderTextLayer {
    
    override func configureBorder() {
        
    }
    
}
