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
    
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var reachSwitch: UISwitch!
    @IBOutlet var valueSwitch: UISwitch!
    @IBOutlet var directionSwitch: UISwitch!
    @IBOutlet var configView: UIStackView!
    
    // MARK: - Properties
    
    private let slider = Slider()
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureController()
    }
    
    // MARK: Private methods
    
    private func configureController() {
        //        slider.delegate = self
        slider.direction = .leftToRight
        slider.maximum = 1500
        slider.minimum = .zero
        slider.value = .zero
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        let layoutMarginsGuide = view.layoutMarginsGuide
        let offset: CGFloat = 16
        let constraints = [
            slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: offset),
            slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset),
            view.rightAnchor.constraint(equalTo: slider.rightAnchor, constant: offset),
//            configView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: offset)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureHaptic() {
        slider.hapticConfiguration = .init(reachLimitValueHapticEnabled: reachSwitch.isOn,
                                           changeValueHapticEnabled: valueSwitch.isOn,
                                           changeDirectionHapticEnabled: directionSwitch.isOn,
                                           reachImpactGeneratorStyle: .medium,
                                           changeValueImpactGeneratorStyle: .light)
    }
    
    // MARK: - Actions
    
    @IBAction private func didChangeSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 1:
                slider.direction = .rightToLeft
            case 2:
                slider.direction = .bottomToTop
            case 3:
                slider.direction = .topToBottom
            default:
                slider.direction = .leftToRight
        }
    }
    
    @IBAction private func didChangeReachValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
    @IBAction private func didChangeValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
    @IBAction private func didChangeDirectionValue(_ sender: UISwitch) {
        configureHaptic()
    }
    
}
