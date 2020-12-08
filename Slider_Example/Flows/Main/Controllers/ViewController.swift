//
//  ViewController.swift
//  Slider_Example
//
//  Created by Рамиз Кичибеков on 05.01.2020.
//  Copyright © 2020 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import Slider

final class ViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var slider: Slider!
    
    // MARK: - Custom methods
    // MARK: - Actions
    
    @IBAction private func didChangeSegment(_ sender: UISegmentedControl) {
        slider.direction = DirectionEnum(withValue: sender.selectedSegmentIndex)
    }
    
}
