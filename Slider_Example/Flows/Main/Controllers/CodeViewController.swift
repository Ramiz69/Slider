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
    
    // MARK: - Outlets
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var reachSwitch: UISwitch!
    @IBOutlet weak var valueSwitch: UISwitch!
    @IBOutlet weak var directionSwitch: UISwitch!
    
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
        slider.direction = DirectionEnum(withValue: segmentControl.selectedSegmentIndex)
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
