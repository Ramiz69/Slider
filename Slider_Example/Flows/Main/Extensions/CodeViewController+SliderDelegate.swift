//
//  CodeViewController+SliderDelegate.swift
//  Slider_Example
//
//  Created by Рамиз Кичибеков on 31.03.2020.
//  Copyright © 2020 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import Slider

extension CodeViewController: SliderDelegate {
    
    func slider(_ slider: Slider, displayTextForValue value: CGFloat) -> String {
        print(value)
        return "\(value)"
    }
    
}
