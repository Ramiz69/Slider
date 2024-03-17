//
//  PreferenceManager.swift
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
import QuartzCore

final class PreferenceManager {
    
    let thumbPreference: ThumbPreference
    let trackPreference: TrackPreference
    let minimumEndpointPreference: EndpointPreference
    let maximumEndpointPreference: EndpointPreference
    let hapticPreference: HapticPreference
    
    init(thumbPreference: ThumbPreference = ThumbPreference(),
         trackPreference: TrackPreference = TrackPreference(),
         minimumEndpointPreference: EndpointPreference = EndpointPreference(),
         maximumEndpointPreference: EndpointPreference = EndpointPreference(),
         hapticPreference: HapticPreference = HapticPreference()) {
        self.thumbPreference = thumbPreference
        self.trackPreference = trackPreference
        self.minimumEndpointPreference = minimumEndpointPreference
        self.maximumEndpointPreference = maximumEndpointPreference
        self.hapticPreference = hapticPreference
    }
    
    class func reset() -> PreferenceManager {
        .init()
    }
    
}

final class HapticPreference {
    
    var reachMinMaxValues = true
    var valueChanges = true
    var directionChanges = true
    
    init(reachMinMaxValues: Bool = true,
         valueChanges: Bool = true,
         directionChanges: Bool = true) {
        self.reachMinMaxValues = reachMinMaxValues
        self.valueChanges = valueChanges
        self.directionChanges = directionChanges
    }
    
}

final class EndpointPreference {
    var foregroundColor: CGColor
    var aligmentMode: CATextLayerAlignmentMode
    
    init(foregroundColor: CGColor = CGColor(red: 1, green: 1, blue: 1, alpha: 1),
         aligmentMode: CATextLayerAlignmentMode = .center) {
        self.foregroundColor = foregroundColor
        self.aligmentMode = aligmentMode
    }
}

final class TrackPreference {
    var maxColor: UIColor
    var minColor: UIColor
    var reverseMinColor: UIColor
    
    init(maxColor: UIColor = UIColor(red: 191 / 255,
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
                                            alpha: 1)) {
        self.maxColor = maxColor
        self.minColor = minColor
        self.reverseMinColor = reverseMinColor
    }
}

final class ThumbPreference {
    var backgroundColor: UIColor = .white
    var textColor: UIColor = UIColor(red: .zero,
                                     green: 74 / 255,
                                     blue: 150 / 255,
                                     alpha: 1)
    
    init(backgroundColor: UIColor = .white,
         textColor: UIColor = UIColor(red: .zero,
                                      green: 74 / 255,
                                      blue: 150 / 255,
                                      alpha: 1)) {
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }
}
