//
//  CodeViewController+UIColorPickerViewControllerDelegate.swift
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

extension CodeViewController: UIColorPickerViewControllerDelegate {
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        let selectedColor = viewController.selectedColor
        switch selectedColorPickerType {
            case .endpoint(let endpoint):
                if endpoint == .minimum {
                    preference.minimumEndpointPreference.foregroundColor = selectedColor.cgColor
                    configureMinimumEndpoint()
                } else {
                    preference.maximumEndpointPreference.foregroundColor = selectedColor.cgColor
                    configureMaximumEndpoint()
                }
            case .thumb:
                preference.thumbPreference.backgroundColor = selectedColor
                configureThumb()
            case .track(let track):
                if track == .max {
                    preference.trackPreference.maxColor = selectedColor
                } else if track == .min {
                    preference.trackPreference.minColor = selectedColor
                } else {
                    preference.trackPreference.reverseMinColor = selectedColor
                }
                configureTrack()
            default: break
        }
    }
    
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        viewController.dismiss(animated: true)
    }
    
}
