//
//  ThumbConfiguration.swift
//
//  Copyright (c) 2024 Ramiz Kichibekov (https://github.com/ramiz69)
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

/// `RangeEndpointsConfiguration` defines the appearance and positioning of the endpoint labels on a `Slider`.
///
/// This configuration allows you to customize the anchor point, text color, font size, and alignment mode
/// for the text displayed at the minimum and maximum endpoints of the slider.
public struct RangeEndpointsConfiguration {
    
    /// The anchor point of the endpoint label's layer.
    ///
    /// It determines the position of the label relative to its frame. The default is `(0.5, 0.5)`, which centers the label.
    let anchorPoint: CGPoint
    
    /// The color of the endpoint label's text.
    ///
    /// The default color is white.
    let foregroundColor: CGColor
    
    /// The font size of the endpoint label's text.
    ///
    /// Default value is `12`.
    let fontSize: CGFloat
    
    /// The alignment mode of the endpoint label's text within its layer.
    ///
    /// Default alignment mode is `.center`.
    let aligmentMode: CATextLayerAlignmentMode
    
    /// Initializes a `RangeEndpointsConfiguration` with the provided values or defaults.
    ///
    /// - Parameters:
    ///   - anchorPoint: The anchor point for the text layer. Defaults to `(0.5, 0.5)`.
    ///   - foregroundColor: The text color. Defaults to white.
    ///   - fontSize: The text font size. Defaults to `12`.
    ///   - aligmentMode: The text alignment within the layer. Defaults to `.center`.
    public init(anchorPoint: CGPoint = CGPoint(x: 0.5, y: 0.5),
                foregroundColor: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1),
                fontSize: CGFloat = 12,
                aligmentMode: CATextLayerAlignmentMode = .center) {
        self.anchorPoint = anchorPoint
        self.foregroundColor = foregroundColor
        self.fontSize = fontSize
        self.aligmentMode = aligmentMode
    }
}
