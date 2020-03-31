//
//  CodeViewController.swift
//  Slider_Example
//
//  Created by Рамиз Кичибеков on 31.03.2020.
//  Copyright © 2020 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import Slider

final class CodeViewController: UIViewController {
    
    // MARK: - Properties
    
    private lazy var slider: Slider = {
        let offset: CGFloat = 16
        let frame = CGRect(x: offset,
                           y: view.safeAreaInsets.top + offset,
                           width: view.frame.width - offset * 2,
                           height: offset * 2)
        let slider = Slider(frame: frame)
        slider.cornerRadius = 16
//        slider.delegate = self
        slider.direction = .rightToLeft
        slider.maximum = 200
        slider.minimum = .zero
        slider.value = .zero
        slider.step = 5
        slider.thumbTextColor = .red
        slider.thumbBackgroundColor = .white
        slider.thumbWidth = 100
        
        return slider
    }()
    
    // MARK: - Life cycle
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(slider)
    }
    
}
