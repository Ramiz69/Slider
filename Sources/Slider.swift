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

open class Slider: UIControl {
    
    public var delegate: SliderDelegate? {
        didSet {
            if let maxText: String = delegate?.slider(self, displayTextForValue: maximum),
               !maxText.isEmpty
            {
                let thumbSize = thumbConfiguration.size
                let newWidth = maxText.size(withConstrainedWidth: thumbSize.height,
                                            font: UIFont.boldSystemFont(ofSize: thumbConfiguration.fontSize)).width
                thumbConfiguration.size.width = CGFloat(max(newWidth, thumbSize.width))
                thumbLayer.bounds = CGRect(origin: .zero, size: thumbSize)
                thumbLayer.position = positionForValue(value: minimum)
                thumbLayer.cornerRadius = thumbSize.height / 2
                thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                                     cornerRadius: thumbLayer.cornerRadius).cgPath
            }
            updateThumbLayersText()
        }
    }
    
    // MARK: Customization properties
    
    final public var value: CGFloat = 10 {
        didSet {
            if value > maximum {
                maximum = value
            }
            if value < minimum {
                value = minimum
            }
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    
    final public var minimum: CGFloat = 10 {
        didSet {
            if minimum > maximum {
                maximum = minimum
            }
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    
    final public var maximum: CGFloat = 800 {
        didSet {
            if maximum < minimum {
                minimum = maximum
            }
            if value > maximum {
                value = maximum
            }
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    
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
    
    final public var cornerRadius: CGFloat = 16 {
        didSet {
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    
    public var thumbConfiguration = ThumbConfiguration() {
        didSet {
            updateThumbLayersText()
            setNeedsLayersDisplay()
        }
    }
    
    public var trackConfiguration = TrackConfiguration() {
        didSet {
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    
    public var maximumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            initEndpointLayer(.maximum)
        }
    }
    
    public var minimumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            initEndpointLayer(.minimum)
        }
    }
    
    public var hapticConfiguration: HapticConfiguration = .init(reachLimitValueHapticEnabled: true,
                                                                changeValueHapticEnabled: false,
                                                                changeDirectionHapticEnabled: true,
                                                                reachImpactGeneratorStyle: .medium,
                                                                changeValueImpactGeneratorStyle: .light)
    
    // MARK: Properties
    
    open override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: trackConfiguration.height)
    }
    
    final public var direction: Direction = .leftToRight {
        didSet {
            hapticConfiguration.directionGenerate()
            redrawLayers()
            reinitComponentValues()
            setNeedsLayersDisplay()
        }
    }
    final public var previousTouchPoint: CGPoint = .zero
    final public var usableTrackingLength: CGFloat = .zero
    final public var animationStyle: AnimationStyle = .none
    final public var continuous: Bool = true
    
    let thumbLayer = ThumbLayer()
    private let trackLayer = SliderTrackLayer()
    private let minimumLayer = TextLayer()
    private let maximumLayer = TextLayer()
    
    private var displayLink: CADisplayLink?
    private var isDirectionChangeAnimationInProgress = false
    
    private enum Endpoint: CaseIterable {
        case minimum, maximum
    }
    
    // MARK: Initial methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialControl()
        initLayers()
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycle
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        if !isDirectionChangeAnimationInProgress {
            usableTrackingLength = bounds.width - thumbConfiguration.size.width
            trackLayer.frame = trackRectForBounds()
            minimumLayer.position = positionForValue(value: minimum)
            maximumLayer.position = positionForValue(value: maximum)
            updateSlider()
        }
    }
    
    // MARK: Public methods
    
    func didBeginTracking() {
        displayLink = CADisplayLink(target: self, selector: #selector(updateSlider))
        displayLink?.add(to: .current, forMode: .common)
    }
    
    func endTracking() {
        displayLink?.invalidate()
        displayLink = nil
    }
    
    // MARK: Private methods
    
    private func initialControl() {
        backgroundColor = .clear
        layer.addSublayer(trackLayer)
        layer.addSublayer(minimumLayer)
        layer.addSublayer(maximumLayer)
        layer.addSublayer(thumbLayer)
    }
    
    private func initLayers() {
        trackLayer.contentsScale = getScallingFactor()
        trackLayer.frame = trackRectForBounds()
        reinitComponentValues()
        initThumbLayer()
        let endpoints = Endpoint.allCases
        endpoints.forEach { initEndpointLayer($0) }
        updateThumbLayersText()
    }
    
    private func initThumbLayer() {
        thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumbLayer.bounds = CGRect(origin: .zero, size: thumbConfiguration.size)
        thumbLayer.position = positionForValue(value: minimum)
        thumbLayer.foregroundColor = trackConfiguration.minColor.cgColor
        thumbLayer.cornerRadius = thumbConfiguration.size.height / 2
        thumbLayer.font = UIFont.systemFont(ofSize: thumbConfiguration.fontSize, weight: .black)
        thumbLayer.fontSize = thumbConfiguration.fontSize
        thumbLayer.alignmentMode = .center
        thumbLayer.contentsScale = getScallingFactor()
        
        thumbLayer.masksToBounds = false
        thumbLayer.shadowOffset = CGSize(width: .zero, height: 0.5)
        thumbLayer.shadowColor = UIColor.black.cgColor
        thumbLayer.shadowRadius = 2
        thumbLayer.shadowOpacity = 0.125
        thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                             cornerRadius: thumbLayer.cornerRadius).cgPath
    }
    
    private func initEndpointLayer(_ endpoint: Endpoint) {
        let layerFrame = CGRect(origin: .zero, size: thumbConfiguration.size)
        let scale = getScallingFactor()
        switch endpoint {
            case .minimum:
                minimumLayer.anchorPoint = minimumEndpointConfiguration.anchorPoint
                minimumLayer.bounds = layerFrame
                minimumLayer.position = positionForValue(value: minimum)
                minimumLayer.foregroundColor = minimumEndpointConfiguration.foregroundColor
                minimumLayer.fontSize = minimumEndpointConfiguration.fontSize
                minimumLayer.alignmentMode = minimumEndpointConfiguration.aligmentMode
                minimumLayer.contentsScale = scale
            case .maximum:
                maximumLayer.anchorPoint = maximumEndpointConfiguration.anchorPoint
                maximumLayer.bounds = layerFrame
                maximumLayer.position = positionForValue(value: maximum)
                maximumLayer.foregroundColor = maximumEndpointConfiguration.foregroundColor
                maximumLayer.fontSize = maximumEndpointConfiguration.fontSize
                maximumLayer.alignmentMode = maximumEndpointConfiguration.aligmentMode
                maximumLayer.contentsScale = scale
        }
    }
    
    private func getScallingFactor() -> CGFloat {
        window?.screen.scale ?? UIScreen.main.scale
    }
    
    // MARK: Update methods
    
    private func reinitComponentValues() {
        trackLayer.trackBackgroundColor = trackConfiguration.maxColor.cgColor
        trackLayer.fillColor = direction == .leftToRight ? trackConfiguration.minColor.cgColor : trackConfiguration.reverseMinColor.cgColor
        trackLayer.cornerRadius = cornerRadius
        updateThumbLayersText()
    }
    
    private func redrawLayers() {
        isDirectionChangeAnimationInProgress = true
        animateThumbLayer {
            self.isDirectionChangeAnimationInProgress = false
        }
        trackLayer.displayIfNeeded()
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(.zero)
        minimumLayer.position = positionForValue(value: minimum)
        maximumLayer.position = positionForValue(value: maximum)
        CATransaction.commit()
    }
    
    private func animateThumbLayer(_ completionBlock: (() -> Void)? = nil) {
        let thumbSize = thumbConfiguration.size
        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)
        CATransaction.setAnimationDuration(animationStyle.animationDuration)
        CATransaction.setAnimationTimingFunction(CATransaction.animationTimingFunction())
        thumbLayer.position = positionForValue(value: value)
        trackLayer.updateFillLayerForAnimation(CGRect(origin: CGPoint(x: thumbLayer.position.x, y: .zero),
                                                      size: CGSize(width: thumbSize.width / 2, height: thumbSize.height)))
        updateSlider()
        CATransaction.commit()
    }
    
    private func setNeedsLayersDisplay() {
        trackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
    }
    
    private func updateThumbLayersText() {
        thumbLayer.foregroundColor = direction == .leftToRight ? trackConfiguration.minColor.cgColor : trackConfiguration.reverseMinColor.cgColor
        thumbLayer.backgroundColor = thumbConfiguration.backgroundColor.cgColor
        thumbLayer.string = textForValue(value)
        minimumLayer.string = textForValue(minimum)
        maximumLayer.string = textForValue(maximum)
    }
    
    @objc
    private func updateSlider() {
        let valueRatio = (value - minimum) / (maximum - minimum)
        let thumbSize = thumbConfiguration.size
        let thumbPositionX = valueRatio * (bounds.width - thumbSize.width) + (value == minimum ? thumbSize.width : thumbSize.width / 2)
        let fillFrame: CGRect
        switch direction {
            case .leftToRight:
                fillFrame = CGRect(x: .zero,
                                   y: .zero,
                                   width: thumbPositionX,
                                   height: bounds.height)
            case .rightToLeft:
                fillFrame = CGRect(x: bounds.width - thumbPositionX,
                                   y: .zero,
                                   width: thumbPositionX,
                                   height: bounds.height)
                
        }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(.zero)
        thumbLayer.position = positionForValue(value: value)
        trackLayer.fillFrame = fillFrame
        CATransaction.commit()
        setNeedsLayersDisplay()
    }
    
    private func positionForValue(value: CGFloat) -> CGPoint {
        let thumbWidth = thumbConfiguration.size.width
        let yPosition = bounds.height / 2
        if minimum == maximum {
            return CGPoint(x: thumbWidth / 2, y: yPosition)
        }
        let xPosition: CGFloat
        switch direction {
            case .leftToRight:
                xPosition = usableTrackingLength * (value - minimum) / (maximum - minimum) + thumbWidth / 2
            case .rightToLeft:
                xPosition = bounds.width - (usableTrackingLength * (value - minimum) / (maximum - minimum) + thumbWidth / 2)
        }
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private func trackRectForBounds() -> CGRect {
        CGRect(x: trackConfiguration.inset,
               y: (bounds.height - trackConfiguration.height) / 2,
               width: bounds.width - 2 * trackConfiguration.inset,
               height: trackConfiguration.height)
    }
    
    private func textForValue(_ value: CGFloat) -> String {
        guard let delegate else {
            return String(format: "%.0f", value)
        }
        
        return delegate.slider(self, displayTextForValue: value)
    }
    
}
