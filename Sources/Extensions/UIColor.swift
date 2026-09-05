//
//  UIColor.swift
//  Slider
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import UIKit

extension UIColor {

    /// Whether the color is light enough that dark text reads better on top of it.
    ///
    /// Uses the perceived luminance of the sRGB components rather than raw brightness, so
    /// saturated blues and reds are correctly treated as dark backgrounds.
    func isLight(for traitCollection: UITraitCollection) -> Bool {
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        guard resolvedColor(with: traitCollection).getRed(&red,
                                                          green: &green,
                                                          blue: &blue,
                                                          alpha: &alpha) else { return true }

        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue

        return luminance > 0.6
    }
}
