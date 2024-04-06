//
//  CodeViewController.swift
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
import Slider

final class CodeViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet var preferenceBarButton: UIBarButtonItem!
    
    // MARK: - Properties
    
    enum ColorPickerType {
        case thumb
        case track(Track)
        case endpoint(Endpoint)
        
        enum Endpoint {
            case minimum
            case maximum
        }
        
        enum Track {
            case min
            case max
            case reverseMin
        }
    }
    
    private let slider = Slider()
    //    private let slider = Slider(direction: .bottomToTop)
    private(set) var preference = PreferenceManager()
    private(set) var selectedColorPickerType: ColorPickerType!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureController()
        configurePreferenceMenu()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        /// Horizontal
        //        let offset: CGFloat = 16
        //        slider.frame = CGRect(x: offset,
        //                              y: view.safeAreaInsets.top,
        //                              width: view.bounds.width - 2 * offset,
        //                              height: slider.trackHeight)
        /// Vertical
        //        let offset: CGFloat = 16
        //        slider.frame = CGRect(x: offset,
        //                              y: view.safeAreaInsets.top,
        //                              width: slider.trackHeight,
        //                              height: view.bounds.height - view.safeAreaInsets.top - 2 * offset)
    }
    
    // MARK: Public methods
    
    func configureMinimumEndpoint() {
        slider.minimumEndpointConfiguration = .init(foregroundColor: preference.minimumEndpointPreference.foregroundColor,
                                                    aligmentMode: preference.minimumEndpointPreference.aligmentMode)
        configurePreferenceMenu()
    }
    
    func configureMaximumEndpoint() {
        slider.maximumEndpointConfiguration = .init(foregroundColor: preference.maximumEndpointPreference.foregroundColor,
                                                    aligmentMode: preference.maximumEndpointPreference.aligmentMode)
        configurePreferenceMenu()
    }
    
    func configureThumb() {
        slider.thumbConfiguration = .init(backgroundColor: preference.thumbPreference.backgroundColor)
        configurePreferenceMenu()
    }
    
    func configureTrack() {
        slider.trackConfiguration = .init(maxColor: preference.trackPreference.maxColor,
                                          minColor: preference.trackPreference.minColor,
                                          reverseMinColor: preference.trackPreference.reverseMinColor)
        configurePreferenceMenu()
    }
    
    // MARK: Private methods
    
    private func configureController() {
        //        slider.delegate = self
        slider.maximum = 1500
        slider.minimum = .zero
        slider.value = .zero
        slider.animationStyle = .default
        view.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        let layoutMarginsGuide = view.layoutMarginsGuide
        let offset: CGFloat = 16
        /// Vertical
        //        let constraints = [slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: offset),
        //                           slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset),
        //                           layoutMarginsGuide.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: offset)]
        /// Horizontal
        let constraints = [slider.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor, constant: offset),
                           slider.leftAnchor.constraint(equalTo: view.leftAnchor, constant: offset),
                           layoutMarginsGuide.bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: offset),
                           view.rightAnchor.constraint(equalTo: slider.rightAnchor, constant: offset)]
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureHaptic() {
        slider.hapticConfiguration = .init(reachLimitValueHapticEnabled: preference.hapticPreference.reachMinMaxValues,
                                           changeValueHapticEnabled: preference.hapticPreference.valueChanges,
                                           changeDirectionHapticEnabled: preference.hapticPreference.directionChanges,
                                           reachImpactGeneratorStyle: .medium,
                                           changeValueImpactGeneratorStyle: .light)
        configurePreferenceMenu()
    }
    
    private func resetSlider() {
        slider.hapticConfiguration = .init(reachLimitValueHapticEnabled: preference.hapticPreference.reachMinMaxValues,
                                           changeValueHapticEnabled: preference.hapticPreference.valueChanges,
                                           changeDirectionHapticEnabled: preference.hapticPreference.directionChanges,
                                           reachImpactGeneratorStyle: .medium,
                                           changeValueImpactGeneratorStyle: .light)
        slider.thumbConfiguration = .init()
        slider.maximumEndpointConfiguration = .init()
        slider.minimumEndpointConfiguration = .init()
    }
    
    private func configurePreferenceMenu() {
        let reset = UIAction(title: "Reset") { [unowned self] _ in
            self.preference = PreferenceManager.reset()
            self.resetSlider()
        }
        let menu = UIMenu(title: "Preference",
                          image: UIImage(systemName: "gear"),
                          children: [configureDirectionMenu(),
                                     configureAnimationMenu(),
                                     configureTrackMenu(),
                                     configureHapticMenu(),
                                     configureEndpointMenu(),
                                     configureThumbMenu(),
                                     reset])
        
        preferenceBarButton.menu = menu
    }
    
    private func configureDirectionMenu() -> UIMenu {
        let directions = Slider.Direction.allCases
        var actions = [UIAction]()
        directions.forEach { direction in
            let action = UIAction(title: "\(direction)", state: direction == slider.direction ? .on : .off) { [unowned self] _ in
                self.slider.direction = direction
                self.configurePreferenceMenu()
            }
            actions.append(action)
        }
        
        return UIMenu(title: "Slider direction", children: actions)
    }
    
    private func configureAnimationMenu() -> UIMenu {
        let styles: [Slider.AnimationStyle] = [.none, .default]
        var animations = [UIAction]()
        styles.forEach { style in
            let action = UIAction(title: "\(style)", state: style == slider.animationStyle ? .on : .off) { [unowned self] _ in
                self.slider.animationStyle = style
                self.configurePreferenceMenu()
            }
            animations.append(action)
        }
        
        return UIMenu(title: "Animation Direction Change", children: animations)
    }
    
    private func configureTrackMenu() -> UIMenu {
        let minColorAction = UIAction(title: "Minimum Color") { [unowned self] _ in
            self.selectedColorPickerType = .track(.min)
            self.presentColorPicker()
        }
        let maxColorAction = UIAction(title: "Maximum Color") { [unowned self] _ in
            self.selectedColorPickerType = .track(.max)
            self.presentColorPicker()
        }
        let reverseMinColorAction = UIAction(title: "Reverse Minimum Color") { [unowned self] _ in
            self.selectedColorPickerType = .track(.reverseMin)
            self.presentColorPicker()
        }
        return UIMenu(title: "Track", children: [minColorAction, maxColorAction, reverseMinColorAction])
    }
    
    private func configureThumbMenu() -> UIMenu {
        let backgroundColor = UIAction(title: "Background") { [unowned self] _ in
            self.selectedColorPickerType = .thumb
            self.presentColorPicker()
        }
        
        return UIMenu(title: "Thumb", children: [backgroundColor])
    }
    
    private func configureHapticMenu() -> UIMenu {
        let hapticPreference = preference.hapticPreference
        let reachAction = UIAction(title: "Reach Min/Max values",
                                   state: hapticPreference.reachMinMaxValues ? .on : .off) { [unowned self] _ in
            hapticPreference.reachMinMaxValues.toggle()
            self.configureHaptic()
        }
        let valueChangeAction = UIAction(title: "Value changes",
                                         state: hapticPreference.valueChanges ? .on : .off) { [unowned self] _ in
            hapticPreference.valueChanges.toggle()
            self.configureHaptic()
        }
        let directionChangeAction = UIAction(title: "Direction changes",
                                             state: hapticPreference.directionChanges ? .on : .off) { [unowned self] _ in
            hapticPreference.directionChanges.toggle()
            self.configureHaptic()
        }
        
        return UIMenu(title: "Haptic",
                      image: UIImage(systemName: "iphone.gen3.radiowaves.left.and.right"),
                      children: [reachAction, valueChangeAction, directionChangeAction])
    }
    
    private func configureEndpointMenu() -> UIMenu {
        let maximumEndpointPreference = preference.maximumEndpointPreference
        let maximumTextColorAction = UIAction(title: "Change color") { [unowned self] _ in
            self.selectedColorPickerType = .endpoint(.maximum)
            self.presentColorPicker()
        }
        
        let minimumEndpointPreference = preference.minimumEndpointPreference
        let minimumTextColorAction = UIAction(title: "Change color") { [unowned self] _ in
            self.selectedColorPickerType = .endpoint(.minimum)
            self.presentColorPicker()
        }
        
        
        let minimumAligmentMenu = UIMenu(title: "Aligment",
                                         image: UIImage(systemName: "text.alignleft"),
                                         children: configureAligmentActions(for: minimumEndpointPreference))
        let maximumAligmentMenu = UIMenu(title: "Aligment",
                                         image: UIImage(systemName: "text.alignright"),
                                         children: configureAligmentActions(for: maximumEndpointPreference))
        
        let minimumEndpointMenu = UIMenu(title: "Minimum", children: [minimumTextColorAction, minimumAligmentMenu])
        let maximumEndpointMenu = UIMenu(title: "Maximum", children: [maximumTextColorAction, maximumAligmentMenu])
        
        return UIMenu(title: "Endpoint",
                      image: UIImage(systemName: "filemenu.and.selection"),
                      children: [minimumEndpointMenu, maximumEndpointMenu])
    }
    
    private func configureAligmentActions(for endpoint: EndpointPreference) -> [UIAction] {
        var aligmentActions = [UIAction]()
        let aligments = CATextLayerAlignmentMode.allCases
        aligments.forEach { aligment in
            let action = UIAction(title: aligment.rawValue,
                                  state: aligment.rawValue == endpoint.aligmentMode.rawValue ? .on : .off) { [unowned self] _ in
                endpoint.aligmentMode = aligment
                self.configureMinimumEndpoint()
            }
            aligmentActions.append(action)
        }
        
        return aligmentActions
    }
    
    private func presentColorPicker() {
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
    }
}

extension CATextLayerAlignmentMode: CaseIterable {
    public static var allCases: [CATextLayerAlignmentMode] {
        [.left, .natural, .center, .right, .justified]
    }
}
