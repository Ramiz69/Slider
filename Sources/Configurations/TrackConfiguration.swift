//
//  TrackConfiguration.swift
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

/// `TrackConfiguration` defines the appearance settings for the track of the `Slider` control.
///
/// It provides properties to customize the track's colors, height, and inset.
public struct TrackConfiguration {
    
    /// The color used for the track's background.
    ///
    /// This is the color displayed for the maximum value part of the track. The default value is `rgba(191, 194, 209, 1)`
    public var maxColor: UIColor
    
    /// The color used for the portion of the track representing values less than the slider's current value.
    ///
    /// The default value is `rgba(0, 122, 255, 1)`.
    public var minColor: UIColor
    
    /// The color used for the portion of the track that represents values greater than the slider's current value when the slider's direction is reversed.
    ///
    /// The default value is `rgba(247, 73, 2, 1)`.
    public var reverseMinColor: UIColor
    
    /// The height of the track.
    ///
    /// Default value is `36`.
    public var height: CGFloat
    
    /// The inset of the track within the slider's bounds.
    ///
    /// This value is used to inset the track from the edges of the slider's bounds. The default value is `0`.
    public var inset: CGFloat
    
    /// Initializes a `TrackConfiguration` instance with specified colors, height, and inset.
    /// - Parameters:
    ///   - maxColor: The color for the track's background. Default is `rgba(191, 194, 209, 1)`.
    ///   - minColor: The color for the track segment representing values below the slider's current value. Default is `rgba(0, 122, 255, 1)`.
    ///   - reverseMinColor: The color for the track segment representing values above the slider's current value in a reversed direction. Default is `rgba(247, 73, 2, 1)`.
    ///   - height: The height of the track. Default is `36`.
    ///   - inset: The inset for the track within the slider's bounds. Default is `0`.
    public init(maxColor: UIColor = UIColor(red: 191 / 255,
                                            green: 194 / 255,
                                            blue: 209 / 255,
                                            alpha: 1),
                minColor: UIColor = UIColor(red: .zero,
                                            green: 122 / 255,
                                            blue: 1,
                                            alpha: 1),
                reverseMinColor: UIColor = UIColor(red: 247 / 255,
                                                   green: 73 / 255,
                                                   blue: 2 / 255,
                                                   alpha: 1),
                height: CGFloat = 36,
                inset: CGFloat = .zero) {
        self.maxColor = maxColor
        self.minColor = minColor
        self.reverseMinColor = reverseMinColor
        self.height = height
        self.inset = inset
    }
}

