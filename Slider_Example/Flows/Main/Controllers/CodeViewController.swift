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
    private let valueLabel = UILabel()
    private(set) var preference = PreferenceManager()
    private(set) var selectedColorPickerType: ColorPickerType!
    private var valueObservation: Task<Void, Never>?
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureController()
        configurePreferenceMenu()
        observeValue()
    }
    
    deinit {
        valueObservation?.cancel()
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
        Task { await slider.prepareHaptics() }
        
        valueLabel.font = .monospacedDigitSystemFont(ofSize: 34, weight: .semibold)
        valueLabel.textAlignment = .center
        valueLabel.textColor = .label
        valueLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(valueLabel)
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        
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
                           view.rightAnchor.constraint(equalTo: slider.rightAnchor, constant: offset),
                           valueLabel.leftAnchor.constraint(equalTo: slider.leftAnchor),
                           valueLabel.rightAnchor.constraint(equalTo: slider.rightAnchor),
                           valueLabel.bottomAnchor.constraint(equalTo: slider.centerYAnchor,
                                                              constant: -offset * 3)]
        NSLayoutConstraint.activate(constraints)
    }
    
    /// Mirrors the slider's value into the label through the async sequence the library exposes.
    private func observeValue() {
        valueObservation = Task { [slider, valueLabel] in
            for await value in slider.valueStream {
                valueLabel.text = String(format: "%.0f", value)
            }
        }
    }
    
    private func configureHaptic() {
        var kind: HapticConfiguration.Kind = [.transient, .continuous]
        if preference.hapticPreference.transient {
            kind.insert(.transient)
        } else {
            kind.remove(.transient)
        }
        if preference.hapticPreference.continuous {
            kind.insert(.continuous)
        } else {
            kind.remove(.continuous)
        }
        slider.hapticConfiguration = HapticConfiguration(kind: kind)
        configurePreferenceMenu()
    }
    
    private func resetSlider() {
        slider.hapticConfiguration = HapticConfiguration()
        slider.thumbConfiguration = ThumbConfiguration()
        slider.maximumEndpointConfiguration = RangeEndpointsConfiguration()
        slider.minimumEndpointConfiguration = RangeEndpointsConfiguration()
        slider.glassConfiguration = GlassConfiguration()
        slider.allowsTapToSeek = false
        slider.respectsLayoutDirection = true
        slider.continuous = true
    }
    
    private func configurePreferenceMenu() {
        let reset = UIAction(title: "Reset") { [unowned self] _ in
            self.preference = PreferenceManager.reset()
            self.resetSlider()
        }
        let animateToRandom = UIAction(title: "Animate to random value",
                                       image: UIImage(systemName: "wand.and.stars")) { [unowned self] _ in
            Task {
                let target = CGFloat.random(in: self.slider.minimum...self.slider.maximum)
                await self.slider.setValue(target, animated: true)
            }
        }
        let menu = UIMenu(title: "Preference",
                          image: UIImage(systemName: "gear"),
                          children: [configureDirectionMenu(),
                                     configureAnimationMenu(),
                                     configureGlassMenu(),
                                     configureBehaviourMenu(),
                                     configureTrackMenu(),
                                     configureHapticMenu(),
                                     configureEndpointMenu(),
                                     configureThumbMenu(),
                                     animateToRandom,
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
    
    private func configureGlassMenu() -> UIMenu {
        let configuration = slider.glassConfiguration
        let modes: [(String, GlassConfiguration.Mode)] = [("Automatic", .automatic),
                                                          ("Disabled", .disabled)]
        let modeActions = modes.map { title, mode in
            UIAction(title: title, state: configuration.mode == mode ? .on : .off) { [unowned self] _ in
                self.slider.glassConfiguration.mode = mode
                self.configurePreferenceMenu()
            }
        }
        let styles: [(String, GlassConfiguration.Style)] = [("Regular", .regular), ("Clear", .clear)]
        let styleActions = styles.map { title, style in
            UIAction(title: title, state: configuration.style == style ? .on : .off) { [unowned self] _ in
                self.slider.glassConfiguration.style = style
                self.configurePreferenceMenu()
            }
        }
        let interactive = UIAction(title: "Interactive",
                                   state: configuration.isInteractive ? .on : .off) { [unowned self] _ in
            self.slider.glassConfiguration.isInteractive.toggle()
            self.configurePreferenceMenu()
        }
        let appliesToTrack = UIAction(title: "Apply to track",
                                      state: configuration.appliesToTrack ? .on : .off) { [unowned self] _ in
            self.slider.glassConfiguration.appliesToTrack.toggle()
            self.configurePreferenceMenu()
        }
        let tintsWithTrack = UIAction(title: "Tint with track color",
                                      state: configuration.tintsThumbWithTrackColor ? .on : .off) { [unowned self] _ in
            self.slider.glassConfiguration.tintsThumbWithTrackColor.toggle()
            self.configurePreferenceMenu()
        }
        let availability = GlassConfiguration.isSupportedByPlatform ? "Liquid Glass"
                                                                    : "Liquid Glass (unavailable)"
        
        return UIMenu(title: availability,
                      children: [UIMenu(title: "Mode", options: .displayInline, children: modeActions),
                                 UIMenu(title: "Style", options: .displayInline, children: styleActions),
                                 UIMenu(title: "Options",
                                        options: .displayInline,
                                        children: [interactive, tintsWithTrack, appliesToTrack])])
    }
    
    private func configureBehaviourMenu() -> UIMenu {
        let tapToSeek = UIAction(title: "Tap to seek",
                                 state: slider.allowsTapToSeek ? .on : .off) { [unowned self] _ in
            self.slider.allowsTapToSeek.toggle()
            self.configurePreferenceMenu()
        }
        let continuous = UIAction(title: "Continuous events",
                                  state: slider.continuous ? .on : .off) { [unowned self] _ in
            self.slider.continuous.toggle()
            self.configurePreferenceMenu()
        }
        let mirrors = UIAction(title: "Mirror in right-to-left",
                               state: slider.respectsLayoutDirection ? .on : .off) { [unowned self] _ in
            self.slider.respectsLayoutDirection.toggle()
            self.configurePreferenceMenu()
        }
        let forceRTL = UIAction(title: "Force right-to-left layout",
                                state: slider.semanticContentAttribute == .forceRightToLeft ? .on : .off) { [unowned self] _ in
            self.slider.semanticContentAttribute = self.slider.semanticContentAttribute == .forceRightToLeft
                ? .unspecified
                : .forceRightToLeft
            self.slider.setNeedsLayout()
            self.configurePreferenceMenu()
        }
        
        return UIMenu(title: "Behaviour", children: [tapToSeek, continuous, mirrors, forceRTL])
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
        let transientAction = UIAction(title: "Transient",
                                         state: hapticPreference.transient ? .on : .off) { [unowned self] _ in
            hapticPreference.transient.toggle()
            self.configureHaptic()
        }
        let continuousAction = UIAction(title: "Continuous",
                                        state: hapticPreference.continuous ? .on : .off) { [unowned self] _ in
            hapticPreference.continuous.toggle()
            self.configureHaptic()
        }

        return UIMenu(title: "Haptic",
                      image: UIImage(systemName: "iphone.gen3.radiowaves.left.and.right"),
                      children: [transientAction, continuousAction])
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

extension CATextLayerAlignmentMode: @retroactive CaseIterable {
    public static var allCases: [CATextLayerAlignmentMode] {
        [.left, .natural, .center, .right, .justified]
    }
}
