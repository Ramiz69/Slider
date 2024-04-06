//
//  HapticConfiguration.swift
//
//  Copyright (c) 2022 Ramiz Kichibekov (https://github.com/ramiz69)
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

/// `HapticConfiguration` allows you to configure haptic feedback for various slider interactions.
///
/// This configuration supports enabling or disabling haptic feedback when the slider reaches its limit values,
/// when the value changes, or when the slider's direction changes.
public struct HapticConfiguration {
    
    /// A Boolean value that determines whether haptic feedback is enabled when reaching the slider's limit values.
    private let reachLimitValueHapticEnabled: Bool
    
    /// A Boolean value that determines whether haptic feedback is enabled when the slider's value changes.
    private let changeValueHapticEnabled: Bool
    
    /// A Boolean value that determines whether haptic feedback is enabled when the slider's direction changes.
    private let changeDirectionHapticEnabled: Bool
    
    /// The haptic feedback generator for when the slider reaches its limit values.
    private var reachImpactGenerator: UIImpactFeedbackGenerator
    
    /// The haptic feedback generator for when the slider's value changes.
    private var changeValueImpactGenerator: UIImpactFeedbackGenerator
    
    /// The haptic feedback generator for when the slider's direction changes.
    private var selectionGenerator: UISelectionFeedbackGenerator
    
    /// Initializes a new `HapticConfiguration` with the specified options.
    ///
    /// - Parameters:
    ///   - reachLimitValueHapticEnabled: Specifies whether to enable haptic feedback when reaching limit values.
    ///   - changeValueHapticEnabled: Specifies whether to enable haptic feedback when the value changes.
    ///   - changeDirectionHapticEnabled: Specifies whether to enable haptic feedback when the direction changes.
    ///   - reachImpactGeneratorStyle: The style of haptic feedback for reaching limit values.
    ///   - changeValueImpactGeneratorStyle: The style of haptic feedback for value changes.
    public init(reachLimitValueHapticEnabled: Bool,
                changeValueHapticEnabled: Bool,
                changeDirectionHapticEnabled: Bool,
                reachImpactGeneratorStyle: UIImpactFeedbackGenerator.FeedbackStyle,
                changeValueImpactGeneratorStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        self.reachLimitValueHapticEnabled = reachLimitValueHapticEnabled
        self.changeValueHapticEnabled = changeValueHapticEnabled
        self.changeDirectionHapticEnabled = changeDirectionHapticEnabled
        reachImpactGenerator = UIImpactFeedbackGenerator(style: reachImpactGeneratorStyle)
        changeValueImpactGenerator = UIImpactFeedbackGenerator(style: changeValueImpactGeneratorStyle)
        selectionGenerator = UISelectionFeedbackGenerator()
        reachImpactGenerator.prepare()
        changeValueImpactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    /// Triggers haptic feedback when the slider reaches its minimum or maximum value.
    func reachValueGenerate() {
        if reachLimitValueHapticEnabled {
            reachImpactGenerator.impactOccurred()
        }
    }
    
    /// Triggers haptic feedback when the slider's value changes.
    func valueGenerate() {
        if changeValueHapticEnabled {
            changeValueImpactGenerator.impactOccurred()
        }
    }
    
    /// Triggers haptic feedback when the slider's direction changes.
    func directionGenerate() {
        if changeDirectionHapticEnabled {
            selectionGenerator.selectionChanged()
        }
    }
}

