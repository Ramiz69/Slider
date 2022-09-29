//
//  HapticConfiguration.swift
//
//  Copyright (c) 2022 Ramiz Kichibekov (https://instagram.com/kichibekov69)
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

public struct HapticConfiguration {
    
    private let reachLimitValueHapticEnabled: Bool
    private let changeValueHapticEnabled: Bool
    private let changeDirectionHapticEnabled: Bool
    private var reachImpactGenerator: UIImpactFeedbackGenerator
    private var changeValueImpactGenerator: UIImpactFeedbackGenerator
    private var selectionGenerator: UISelectionFeedbackGenerator
    
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
        changeValueImpactGenerator.prepare()
        reachImpactGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    func reachValueGenerate() {
        if reachLimitValueHapticEnabled {
            reachImpactGenerator.impactOccurred()
        }
    }
    
    func valueGenerate() {
        if changeValueHapticEnabled {
            changeValueImpactGenerator.impactOccurred()
        }
    }
    
    func directionGenerate() {
        if changeDirectionHapticEnabled {
            selectionGenerator.selectionChanged()
        }
    }
    
}
