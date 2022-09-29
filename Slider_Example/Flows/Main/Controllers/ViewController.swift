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
    @IBOutlet weak var reachSwitch: UISwitch!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var directionSwitch: UISwitch!
    
    // MARK: - Custom methods
    // MARK: Private methods
    
    private func configureHaptic() {
        slider.hapticConfiguration = .init(reachLimitValueHapticEnabled: reachSwitch.isOn,
                                           changeValueHapticEnabled: valueSwitch.isOn,
                                           changeDirectionHapticEnabled: directionSwitch.isOn,
                                           reachImpactGeneratorStyle: .medium,
                                           changeValueImpactGeneratorStyle: .light)
    }
    
    // MARK: - Actions
    
    @IBAction private func didChangeSegment(_ sender: UISegmentedControl) {
        slider.direction = DirectionEnum(withValue: sender.selectedSegmentIndex)
    }
    
    @IBAction func didChangeReachValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
    @IBAction func didChangeValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
    @IBAction func didChangeDirectionValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
}
