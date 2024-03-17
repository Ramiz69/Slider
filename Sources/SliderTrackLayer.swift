//
//  SliderTrackLayer.swift
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

import Foundation
import QuartzCore
import CoreGraphics

final class SliderTrackLayer: CALayer {
    
    // MARK: Properties
    
    var trackBackgroundColor: CGColor = CGColor(gray: .zero, alpha: 1) {
        didSet {
            backgroundLayer.backgroundColor = trackBackgroundColor
        }
    }
    var fillColor: CGColor! {
        didSet {
            fillLayer.backgroundColor = fillColor
        }
    }
    var fillFrame: CGRect = .zero {
        didSet {
            fillLayer.frame = fillFrame
        }
    }
    private let backgroundLayer = CALayer()
    private let fillLayer = CALayer()
    
    // MARK: Initial methods
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        configureLayer()
    }
    
    override init() {
        super.init()
        
        configureLayer()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = cornerRadius
        fillLayer.cornerRadius = cornerRadius
    }
    
    // MARK: Public methods
    
    func updateFillLayerForAnimation(_ frame: CGRect) {
        fillFrame = frame
    }
    
    // MARK: Private methods
    
    private func configureLayer() {
        backgroundLayer.masksToBounds = true
        backgroundLayer.backgroundColor = trackBackgroundColor
        addSublayer(backgroundLayer)
        backgroundLayer.addSublayer(fillLayer)
    }
}
