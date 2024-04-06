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

import UIKit

/// `ThumbConfiguration` defines the appearance settings for the thumb of the `Slider` control.
///
/// It allows customization of the thumb's background color, font size, size, and border width.
public struct ThumbConfiguration {
    
    /// The background color of the thumb.
    ///
    /// This color is used as the fill color for the thumb's background. The default value is `.white`.
    public var backgroundColor: UIColor
    
    /// The font size of the thumb's label.
    ///
    /// This property determines the size of the text inside the thumb. Default value is `14`.
    public var fontSize: CGFloat
    
    /// The size of the thumb.
    ///
    /// Defines the width and height of the thumb. The default size is `(width: 60, height: 36)`.
    public var size: CGSize
    
    /// The border width of the thumb.
    ///
    /// Specifies the width of the thumb's border. The default value is `4`.
    public var borderWidth: CGFloat
    
    /// Initializes a `ThumbConfiguration` instance with specified background color, font size, size, and border width.
    /// - Parameters:
    ///   - backgroundColor: The background color of the thumb. Default is `.white`.
    ///   - fontSize: The font size for the thumb's label. Default is `14`.
    ///   - size: The size of the thumb. Default is `(width: 60, height: 36)`.
    ///   - borderWidth: The border width of the thumb. Default is `4`.
    public init(backgroundColor: UIColor = .white,
                fontSize: CGFloat = 14,
                size: CGSize = CGSize(width: 60, height: 36),
                borderWidth: CGFloat = 4) {
        self.backgroundColor = backgroundColor
        self.fontSize = fontSize
        self.size = size
        self.borderWidth = borderWidth
    }
}

