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

/// `SliderTrackLayer` is a custom `CALayer` subclass used to render the track and fill of the slider.
///
/// This layer contains two sublayers: one for the track's background and one for the fill that indicates the current value.
final class SliderTrackLayer: CALayer {
    
    /// The color used for the background of the track layer.
    ///
    /// Changing this property will update the background color of the `backgroundLayer`.
    var trackBackgroundColor: CGColor = CGColor(gray: .zero, alpha: 1) {
        didSet {
            backgroundLayer.backgroundColor = trackBackgroundColor
        }
    }
    
    /// The color used for the fill portion of the track layer.
    ///
    /// Changing this property will update the background color of the `fillLayer`.
    var fillColor: CGColor! {
        didSet {
            fillLayer.backgroundColor = fillColor
        }
    }
    
    /// The frame for the fill layer within the track.
    ///
    /// Setting this property updates the frame of `fillLayer` to represent the current value.
    var fillFrame: CGRect = .zero {
        didSet {
            fillLayer.frame = fillFrame
        }
    }
    
    /// The layer representing the track's background.
    private let backgroundLayer = CALayer()
    
    /// The layer representing the fill portion of the track.
    private let fillLayer = CALayer()
    
    /// Initializes a new `SliderTrackLayer` instance copying from another layer.
    ///
    /// - Parameter layer: The layer from which to copy properties.
    override init(layer: Any) {
        super.init(layer: layer)
        configureLayer()
    }
    
    /// Initializes a new `SliderTrackLayer` instance.
    override init() {
        super.init()
        configureLayer()
    }
    
    /// This initializer is not available for `SliderTrackLayer`.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Lays out the sublayers of `SliderTrackLayer`.
    ///
    /// Sets the frame for `backgroundLayer` and `fillLayer`, applying the corner radius.
    override func layoutSublayers() {
        super.layoutSublayers()
        backgroundLayer.frame = bounds
        backgroundLayer.cornerRadius = cornerRadius
        fillLayer.cornerRadius = cornerRadius
    }
    
    /// Updates the frame of the fill layer, typically used during animation.
    ///
    /// - Parameter frame: The new frame for the fill layer.
    func updateFillLayerForAnimation(_ frame: CGRect) {
        fillFrame = frame
    }
    
    /// Configures the `SliderTrackLayer`, setting up the `backgroundLayer` and `fillLayer`.
    private func configureLayer() {
        backgroundLayer.masksToBounds = true
        backgroundLayer.backgroundColor = trackBackgroundColor
        addSublayer(backgroundLayer)
        backgroundLayer.addSublayer(fillLayer)
    }
}

