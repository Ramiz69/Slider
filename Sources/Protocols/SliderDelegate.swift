//
//  SliderDelegate.swift
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
import CoreFoundation

/// A protocol that defines methods to respond to slider value changes and tracking events.
///
/// This protocol should be implemented by classes that manage or display a `Slider` to customize
/// the text representation of slider values and to respond to user interactions.
@MainActor
public protocol SliderDelegate: AnyObject {
    /// Asks the delegate for the display text for a specific value of the slider.
    ///
    /// Implement this method to return a string that represents the given value in a way suitable for your app.
    /// - Parameters:
    ///   - slider: The `Slider` instance requesting the display text.
    ///   - value: The value for which to provide display text.
    /// - Returns: A string representation of the value.
    func slider(_ slider: Slider, displayTextForValue value: CGFloat) -> String
    
    /// Tells the delegate that the user has started interacting with the slider.
    ///
    /// You can override this method to respond when the user starts moving the slider thumb.
    /// The default implementation does nothing.
    /// - Parameter slider: The `Slider` instance that started tracking.
    func didBeginTracking(_ slider: Slider)
    
    /// Informs the delegate that the user is continuing to move the slider.
    ///
    /// You can override this method to track the slider's value as the user moves the thumb.
    /// The default implementation does nothing.
    /// - Parameter slider: The `Slider` instance that is being tracked.
    func didContinueTracking(_ slider: Slider)
    
    /// Notifies the delegate that the user has finished interacting with the slider.
    ///
    /// You can override this method to perform any final actions when the user ends tracking.
    /// The default implementation does nothing.
    /// - Parameter slider: The `Slider` instance that stopped tracking.
    func didEndTracking(_ slider: Slider)
}

/// Default implementation for `SliderDelegate` methods, making them optional.
public extension SliderDelegate {
    func didBeginTracking(_ slider: Slider) {
        // Default implementation does nothing.
    }
    
    func didContinueTracking(_ slider: Slider) {
        // Default implementation does nothing.
    }
    
    func didEndTracking(_ slider: Slider) {
        // Default implementation does nothing.
    }
}
