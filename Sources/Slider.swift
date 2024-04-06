//
//  Slider.swift
//
//  Copyright (c) 2020 Ramiz Kichibekov (https://github.com/ramiz69)
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
import QuartzCore

/// An open class that extends `UIControl` to create a customizable slider component.
///
/// It supports various configurations to control the appearance and behavior of the slider,
/// including its value range, direction, thumb and track configurations, and haptic feedback settings.
open class Slider: UIControl {
    
    /// Enumerates the possible directions of the slider.
    public enum Direction: CaseIterable {
        case leftToRight, rightToLeft
        case bottomToTop, topToBottom
        
        /// Determines the axis of the slider based on its direction.
        var axis: Axis {
            switch self {
                case .leftToRight, .rightToLeft:
                    return .x
                case .bottomToTop, .topToBottom:
                    return .y
            }
        }
        
        /// Enumerates the possible axes of the slider.
        enum Axis {
            case x
            case y
        }
    }
    
    /// Enumerates the possible animation styles for the slider's value change.
    public enum AnimationStyle {
        case none
        case `default`
        
        /// Determines the animation duration based on the animation style.
        var animationDuration: TimeInterval {
            switch self {
                case .none: return .zero
                case .default: return CATransaction.animationDuration()
            }
        }
    }
    
    /// The delegate for the slider, conforming to `SliderDelegate`.
    /// It handles user interactions and value changes.
    public var delegate: SliderDelegate? {
        didSet {
            // When the delegate is set, it might update the visual appearance based on the maximum value's text.
            if let maxText: String = delegate?.slider(self, displayTextForValue: maximum),
               !maxText.isEmpty
            {
                let thumbSize = thumbConfiguration.size
                let newWidth = maxText.size(withConstrainedWidth: thumbSize.height,
                                            font: UIFont.boldSystemFont(ofSize: thumbConfiguration.fontSize)).width
                thumbConfiguration.size.width = CGFloat(max(newWidth, thumbSize.width))
                thumbLayer.bounds = CGRect(origin: .zero, size: thumbSize)
                thumbLayer.position = position(forValue: minimum)
                thumbLayer.cornerRadius = thumbSize.height / 2
                thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                                     cornerRadius: thumbLayer.cornerRadius).cgPath
            }
            updateThumbLayersText()
        }
    }
    
    // MARK: Customization properties
    
    /// The current value of the slider.
    final public var value: CGFloat = 10 {
        didSet {
            // Ensures the minimum value is not greater than the maximum and updates the visual components.
            if value > maximum {
                maximum = value
            }
            if value < minimum {
                value = minimum
            }
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    
    /// The minimum value of the slider.
    final public var minimum: CGFloat = 10 {
        didSet {
            // Ensures the maximum value is not less than the minimum and updates the visual components.
            if minimum > maximum {
                maximum = minimum
            }
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    
    /// The maximum value of the slider.
    final public var maximum: CGFloat = 800 {
        didSet {
            // Ensures the maximum value is not less than the minimum and updates the visual components.
            if maximum < minimum {
                minimum = maximum
            }
            if value > maximum {
                value = maximum
            }
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    
    /// The step value of the slider, determining the increments between values.
    final public var step: CGFloat = 10 {
        didSet {
            if step < .zero {
                step = .zero
            }
            if step > (maximum - minimum) {
                maximum = minimum + step
            }
        }
    }
    
    /// The corner radius for the slider's track and thumb.
    final public var cornerRadius: CGFloat = 16 {
        didSet {
            // Updates the visual components when the corner radius changes.
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    
    /// The configuration for the slider's thumb.
    public var thumbConfiguration = ThumbConfiguration() {
        didSet {
            updateThumbLayersText()
            setNeedsLayersDisplay()
        }
    }
    
    /// The configuration for the slider's track.
    public var trackConfiguration = TrackConfiguration() {
        didSet {
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    
    /// The configuration for the slider's maximum endpoint label.
    public var maximumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            configureEndpointLayer(.maximum)
        }
    }
    
    /// The configuration for the slider's minimum endpoint label.
    public var minimumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            configureEndpointLayer(.minimum)
        }
    }
    
    /// The configuration for haptic feedback during user interactions with the slider.
    public var hapticConfiguration: HapticConfiguration = .init(reachLimitValueHapticEnabled: true,
                                                                changeValueHapticEnabled: false,
                                                                changeDirectionHapticEnabled: true,
                                                                reachImpactGeneratorStyle: .medium,
                                                                changeValueImpactGeneratorStyle: .light)
    
    // MARK: Properties
    
    /// The intrinsic content size of the slider, depending on its direction.
    open override var intrinsicContentSize: CGSize {
        switch direction.axis {
            case .x:
                return CGSize(width: UIView.noIntrinsicMetric, height: trackConfiguration.height)
            case .y:
                return CGSize(width: trackConfiguration.height, height: UIView.noIntrinsicMetric)
        }
    }
    
    /// The direction of the slider, determining its layout and behavior.
    final public var direction: Direction = .leftToRight {
        didSet {
            isDirectionChanged = direction.axis != oldValue.axis
            hapticConfiguration.directionGenerate()
            redrawLayers()
            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }
    /// Used for tracking the user's touch location during interaction.
    final public var previousTouchPoint: CGPoint = .zero
    
    /// The length of the track that is usable for moving the thumb, excluding the thumb width.
    final public var usableTrackingLength: CGFloat = .zero
    
    /// The animation style for the slider's value change.
    final public var animationStyle: AnimationStyle = .none
    
    /// Indicates if the value change events are continuous during user interaction.
    final public var continuous: Bool = true
    
    let thumbLayer = ThumbLayer()
    private var isDirectionChanged = false {
        didSet {
            assertionFailure("Attempt to improperly change the value of isDirectionChanged.")
        }
    }
    private let trackLayer = SliderTrackLayer()
    private let minimumLayer = TextLayer()
    private let maximumLayer = TextLayer()
    
    private var displayLink: CADisplayLink?
    private var isDirectionChangeAnimationInProgress = false
    
    private enum Endpoint: CaseIterable {
        case minimum, maximum
    }
    
    // MARK: Initial methods
    
    /// Creates a control with the specified frame and direction
    public init(direction: Direction, frame: CGRect = .zero) {
        super.init(frame: frame)
        
        self.direction = direction
        configureControl()
        configureTrackLayer()
        setupEndpoints()
        setupThumbLayer()
        configureThumbLayer()
    }
    
    /// Creates a control with the specified frame
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureControl()
        configureTrackLayer()
        setupEndpoints()
        setupThumbLayer()
        configureThumbLayer()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    /// Lays out the slider's subviews and updates the layout based on the current state and properties.
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isDirectionChangeAnimationInProgress {
            switch direction.axis {
                case .x:
                    usableTrackingLength = bounds.width - thumbConfiguration.size.width
                case .y:
                    usableTrackingLength = bounds.height - thumbConfiguration.size.height
            }
            trackLayer.frame = trackRectForBounds()
            minimumLayer.position = position(forValue: minimum)
            maximumLayer.position = position(forValue: maximum)
            updateSlider()
        }
    }
    
    /// Associates a target object and action method with the control.
    open override func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {}
    
    /// Stops the delivery of events to the specified target object.
    open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControl.Event) {}
    
    open override func addAction(_ action: UIAction, for controlEvents: UIControl.Event) {}
    
    open override func removeAction(_ action: UIAction, for controlEvents: UIControl.Event) {}
    
    // MARK: Internal methods
    
    func didBeginTracking() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateSlider))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func endTracking() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: Private methods
    
    /// Configures the initial state and sublayers of the slider control.
    private func configureControl() {
        backgroundColor = .clear
        layer.addSublayer(trackLayer)
        layer.addSublayer(minimumLayer)
        layer.addSublayer(maximumLayer)
        layer.addSublayer(thumbLayer)
    }
    
    /// Configures the track layer of the slider, setting its initial appearance based on the track configuration.
    private func configureTrackLayer() {
        trackLayer.contentsScale = getScreenScale()
        trackLayer.frame = trackRectForBounds()
        
        trackLayer.trackBackgroundColor = trackConfiguration.maxColor.cgColor
        trackLayer.fillColor = (direction == .leftToRight || direction == .bottomToTop) ? trackConfiguration.minColor.cgColor : trackConfiguration.reverseMinColor.cgColor
        trackLayer.cornerRadius = cornerRadius
    }
    
    /// Sets up endpoint layers for the slider, configuring them based on their respective configurations.
    private func setupEndpoints() {
        let endpoints = Endpoint.allCases
        endpoints.forEach { configureEndpointLayer($0) }
    }
    
    private func configureThumbLayer() {
        thumbLayer.foregroundColor = fillColorForDirection()
        thumbLayer.backgroundColor = thumbConfiguration.backgroundColor.cgColor
        thumbLayer.string = text(forValue: value)
        minimumLayer.string = text(forValue: minimum)
        maximumLayer.string = text(forValue: maximum)
    }
    
    /// Configures the thumb layer of the slider, setting its initial appearance based on the thumb configuration.
    private func setupThumbLayer() {
        thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumbLayer.bounds = boundsForDirection()
        thumbLayer.position = position(forValue: minimum)
        thumbLayer.foregroundColor = trackConfiguration.minColor.cgColor
        thumbLayer.cornerRadius = thumbConfiguration.size.height / 2
        thumbLayer.font = UIFont.systemFont(ofSize: thumbConfiguration.fontSize, weight: .black)
        thumbLayer.fontSize = thumbConfiguration.fontSize
        thumbLayer.alignmentMode = .center
        thumbLayer.borderWidth = thumbConfiguration.borderWidth
        thumbLayer.contentsScale = getScreenScale()
        thumbLayer.masksToBounds = false
        thumbLayer.shadowOffset = shadowOffsetForDirection()
        thumbLayer.shadowColor = UIColor.black.cgColor
        thumbLayer.shadowRadius = 2
        thumbLayer.shadowOpacity = 0.125
        thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                             cornerRadius: thumbLayer.cornerRadius).cgPath
    }
    
    private func configureEndpointLayer(_ endpoint: Endpoint) {
        let layerFrame = CGRect(origin: .zero, size: thumbConfiguration.size)
        let scale = getScreenScale()
        switch endpoint {
            case .minimum:
                minimumLayer.anchorPoint = minimumEndpointConfiguration.anchorPoint
                minimumLayer.bounds = layerFrame
                minimumLayer.position = position(forValue: minimum)
                minimumLayer.foregroundColor = minimumEndpointConfiguration.foregroundColor
                minimumLayer.fontSize = minimumEndpointConfiguration.fontSize
                minimumLayer.alignmentMode = minimumEndpointConfiguration.aligmentMode
                minimumLayer.contentsScale = scale
            case .maximum:
                maximumLayer.anchorPoint = maximumEndpointConfiguration.anchorPoint
                maximumLayer.bounds = layerFrame
                maximumLayer.position = position(forValue: maximum)
                maximumLayer.foregroundColor = maximumEndpointConfiguration.foregroundColor
                maximumLayer.fontSize = maximumEndpointConfiguration.fontSize
                maximumLayer.alignmentMode = maximumEndpointConfiguration.aligmentMode
                maximumLayer.contentsScale = scale
        }
    }
    
    private func getScreenScale() -> CGFloat {
        return window?.screen.scale ?? UIScreen.main.scale
    }
    
    /// Determines the correct fill color for the slider's direction.
    ///
    /// - Returns: The CGColor representing the fill color.
    private func fillColorForDirection() -> CGColor {
        return (direction == .leftToRight || direction == .bottomToTop) ? trackConfiguration.minColor.cgColor : trackConfiguration.reverseMinColor.cgColor
    }
    
    /// Calculates the bounds for the thumb layer based on the slider's direction.
    ///
    /// - Returns: A CGRect representing the bounds for the thumb layer.
    private func boundsForDirection() -> CGRect {
        switch direction.axis {
            case .x:
                return CGRect(origin: .zero, size: thumbConfiguration.size)
            case .y:
                return CGRect(origin: .zero, size: CGSize(width: thumbConfiguration.size.height,
                                                          height: thumbConfiguration.size.width))
        }
    }
    
    /// Determines the appropriate shadow offset for the thumb layer based on the slider's direction.
    ///
    /// - Returns: The CGSize representing the shadow offset.
    private func shadowOffsetForDirection() -> CGSize {
        return direction.axis == .x ? CGSize(width: .zero, height: 0.5) : CGSize(width: 0.5, height: .zero)
    }
    
    // MARK: Update methods
    
    /// Updates the visual components of the slider when certain properties change.
    private func updateVisualComponents() {
        trackLayer.trackBackgroundColor = trackConfiguration.maxColor.cgColor
        trackLayer.fillColor = fillColorForDirection()
        trackLayer.cornerRadius = cornerRadius
        updateThumbLayersText()
    }
    
    /// Redraws layers when the slider's direction changes, ensuring the visual transition is smooth.
    private func redrawLayers() {
        isDirectionChangeAnimationInProgress = true
        animateThumbLayer { [weak self] in
            guard let self else { return }
            
            self.isDirectionChangeAnimationInProgress = false
            if self.animationStyle == .default {
                self.layoutSubviews()
            }
        }
        trackLayer.displayIfNeeded()
        updateEndpointPositions()
        if animationStyle != .default {
            isDirectionChangeAnimationInProgress = false
            layoutSubviews()
        }
    }
    
    private func updateEndpointPositions() {
        CATransaction.begin()
        CATransaction.setAnimationDuration(.zero)
        minimumLayer.position = position(forValue: minimum)
        maximumLayer.position = position(forValue: maximum)
        CATransaction.commit()
    }
    
    /// Animates the thumb layer to reflect the change in value or direction.
    private func animateThumbLayer(_ completionBlock: (() -> Void)? = nil) {
        let thumbSize = thumbConfiguration.size
        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)
        CATransaction.setAnimationDuration(animationStyle.animationDuration)
        CATransaction.setAnimationTimingFunction(CATransaction.animationTimingFunction())
        thumbLayer.position = position(forValue: value)
        let trackSize: CGSize
        switch direction {
            case .leftToRight, .rightToLeft:
                trackSize = CGSize(width: thumbSize.width / 2, height: thumbSize.height)
            case .bottomToTop, .topToBottom:
                trackSize = CGSize(width: thumbSize.height, height: thumbSize.width / 2)
        }
        trackLayer.updateFillLayerForAnimation(CGRect(origin: CGPoint(x: thumbLayer.position.x, y: .zero),
                                                      size: trackSize))
        updateSlider()
        CATransaction.commit()
    }
    
    /// Requests the layers to update their display. This is typically called after a property change that requires visual updates.
    private func setNeedsLayersDisplay() {
        trackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
    }
    
    /// Updates the slider's thumb layer text and other properties when the slider's value changes.
    private func updateThumbLayersText() {
        thumbLayer.foregroundColor = fillColorForDirection()
        thumbLayer.backgroundColor = thumbConfiguration.backgroundColor.cgColor
        thumbLayer.string = text(forValue: value)
        minimumLayer.string = text(forValue: minimum)
        maximumLayer.string = text(forValue: maximum)
    }
    
    /// Updates the slider based on the user interaction, adjusting the thumb position and fill layer.
    @objc
    private func updateSlider() {
        let valueRatio = (value - minimum) / (maximum - minimum)
        let thumbSize = thumbConfiguration.size
        let fillFrame: CGRect
        switch direction {
            case .leftToRight:
                let thumbPositionX = valueRatio * usableTrackingLength + thumbSize.width / 2
                fillFrame = CGRect(x: .zero,
                                   y: .zero,
                                   width: thumbPositionX, height: bounds.height)
            case .rightToLeft:
                let thumbPositionX = bounds.width - (valueRatio * usableTrackingLength + thumbSize.width / 2)
                fillFrame = CGRect(x: thumbPositionX,
                                   y: .zero,
                                   width: bounds.width - thumbPositionX,
                                   height: bounds.height)
            case .bottomToTop:
                let thumbPositionY = bounds.height - (valueRatio * usableTrackingLength + thumbSize.height / 2)
                fillFrame = CGRect(x: .zero,
                                   y: thumbPositionY,
                                   width: bounds.width,
                                   height: bounds.height - thumbPositionY)
            case .topToBottom:
                let thumbPositionY = valueRatio * usableTrackingLength + thumbSize.height / 2
                fillFrame = CGRect(x: .zero,
                                   y: .zero,
                                   width: bounds.width,
                                   height: thumbPositionY)
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        thumbLayer.position = position(forValue: value)
        trackLayer.fillFrame = fillFrame
        CATransaction.commit()
    }
    
    /// Calculates the thumb's position based on the current value.
    ///
    /// - Parameter value: The value for which to calculate the thumb position.
    /// - Returns: The point representing the position of the thumb.
    private func position(forValue value: CGFloat) -> CGPoint {
        let thumbSize = thumbConfiguration.size
        let position: CGPoint
        switch direction {
            case .leftToRight:
                position = CGPoint(x: (usableTrackingLength * (value - minimum) / (maximum - minimum)) + thumbSize.width / 2,
                                   y: bounds.height / 2)
            case .rightToLeft:
                position = CGPoint(x: bounds.width - (usableTrackingLength * (value - minimum) / (maximum - minimum)) - thumbSize.width / 2,
                                   y: bounds.height / 2)
            case .bottomToTop:
                position = CGPoint(x: bounds.width / 2,
                                   y: bounds.height - (usableTrackingLength * (value - minimum) / (maximum - minimum)) - thumbSize.height / 2)
            case .topToBottom:
                position = CGPoint(x: bounds.width / 2, y: (usableTrackingLength * (value - minimum) / (maximum - minimum)) + thumbSize.height / 2)
        }
        
        return position
    }
    
    private func trackRectForBounds() -> CGRect {
        switch direction.axis {
            case .x:
                return CGRect(x: trackConfiguration.inset,
                              y: (bounds.height - trackConfiguration.height) / 2,
                              width: bounds.width - 2 * trackConfiguration.inset,
                              height: trackConfiguration.height)
            case .y:
                return CGRect(x: (bounds.width - trackConfiguration.height) / 2,
                              y: trackConfiguration.inset,
                              width: trackConfiguration.height,
                              height: bounds.height - 2 * trackConfiguration.inset)
        }
    }
    
    private func text(forValue value: CGFloat) -> String {
        guard let delegate else {
            return String(format: "%.0f", value)
        }
        
        return delegate.slider(self, displayTextForValue: value)
    }
}
