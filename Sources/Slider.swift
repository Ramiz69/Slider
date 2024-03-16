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

open class Slider: UIControl {
    
    public var delegate: SliderDelegate? {
        didSet {
            if let maxText: String = delegate?.slider(self, displayTextForValue: maximum),
               !maxText.isEmpty
            {
                let newWidth = maxText.size(withConstrainedWidth: thumbHeight,
                                            font: UIFont.boldSystemFont(ofSize: fontSize)).width
                thumbWidth = CGFloat(max(newWidth, thumbWidth))
                thumbLayer.bounds = CGRect(origin: .zero,
                                           size: CGSize(width: thumbWidth,
                                                        height: thumbHeight))
                thumbLayer.position = positionForValue(value: minimum)
                thumbLayer.cornerRadius = thumbHeight / 2
                thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                                     cornerRadius: thumbHeight / 2).cgPath
            }
            updateThumbLayersText()
        }
    }
    
    // MARK: - Customization properties
    
    final public var value: CGFloat = 10 {
        didSet {
            if value > maximum {
                maximum = value
            }
            if value < minimum {
                value = minimum
            }
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    final public var minimum: CGFloat = 10 {
        didSet {
            if minimum > maximum {
                maximum = minimum
            }
            reinitComponentValues()
            redrawLayers()
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
            redrawLayers()
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
            redrawLayers()
        }
    }
    
    final public var thumbBackgroundColor: UIColor = UIColor.white {
        didSet {
            thumbLayer.backgroundColor = thumbBackgroundColor.cgColor
            redrawLayers()
        }
    }
    
    final public var thumbTextColor: UIColor = UIColor(red: .zero,
                                                       green: 74 / 255,
                                                       blue: 150 / 255,
                                                       alpha: 1) {
        didSet {
            thumbLayer.foregroundColor = thumbTextColor.cgColor
            redrawLayers()
        }
    }
    
    final public var continuous: Bool = true
    
    final public var fontSize: CGFloat = 14 {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    final public var trackHeight: CGFloat = 36 {
        didSet {
            layoutSubviews()
        }
    }
    
    final public var trackInset: CGFloat = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    final public var thumbHeight: CGFloat = 36 {
        didSet {
            initThumbLayer()
            layoutSubviews()
            redrawLayers()
        }
    }
    
    final public var thumbWidth: CGFloat = 60 {
        didSet {
            initThumbLayer()
            layoutSubviews()
            redrawLayers()
        }
    }
    
    open var trackMaxColor: UIColor = UIColor(red: 191 / 255,
                                              green: 194 / 255,
                                              blue: 209 / 255,
                                              alpha: 1) {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    open var trackMinColor: UIColor = UIColor(red: .zero,
                                              green: 122 / 255,
                                              blue: 1,
                                              alpha: 1) {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    open var reverseTrackMinColor: UIColor = UIColor(red: 247 / 255,
                                                     green: 73 / 255,
                                                     blue: 2 / 255,
                                                     alpha: 1) {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    // MARK: - Properties
    
    final public var direction: Direction = .leftToRight {
        didSet {
            hapticConfiguration.directionGenerate()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationDuration(.zero)
            let affineTransform = CATransform3DMakeAffineTransform(direction.transform)
            transform = direction.transform
            thumbLayer.transform = CATransform3DMakeAffineTransform(direction.thumbTransform)
            minimumLayer.transform = affineTransform
            maximumLayer.transform = affineTransform
            CATransaction.commit()
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    public var hapticConfiguration: HapticConfiguration = .init(reachLimitValueHapticEnabled: true,
                                                                changeValueHapticEnabled: false,
                                                                changeDirectionHapticEnabled: true,
                                                                reachImpactGeneratorStyle: .medium,
                                                                changeValueImpactGeneratorStyle: .light)
    public let trackLayer = SliderTrackLayer()
    public let thumbLayer = SliderTextLayer()
    public let minimumLayer = SliderMinimumTextLayer()
    public let maximumLayer = SliderMaximumTextLayer()
    final public var previousTouchPoint: CGPoint = .zero
    final public var usableTrackingLength: CGFloat = .zero
    
    open override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: trackHeight)
    }
    
    private let trackMaskLayer = CALayer()
    
    // MARK: - Initial methods
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialControl()
        initLayers()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Life cycle
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = trackRectForBounds()
        trackMaskLayer.frame = trackRectForBounds()
        usableTrackingLength = bounds.width - thumbWidth
        updateThumbLayersPosition()
    }
    
    // MARK: - Private methods
    
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
        trackLayer.setNeedsDisplay()
        trackMaskLayer.masksToBounds = true
        trackMaskLayer.frame = trackRectForBounds()
        trackMaskLayer.cornerRadius = cornerRadius
        layer.insertSublayer(trackMaskLayer, at: .zero)
        reinitComponentValues()
        initThumbLayer()
        initMinimumLayer()
        initMaximumLayer()
        updateThumbLayersText()
    }
    
    private func initThumbLayer() {
        thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumbLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        thumbLayer.position = positionForValue(value: minimum)
        thumbLayer.foregroundColor = trackMinColor.cgColor
        thumbLayer.cornerRadius = thumbHeight / 2
        thumbLayer.font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        thumbLayer.fontSize = fontSize
        thumbLayer.backgroundColor = thumbBackgroundColor.cgColor
        thumbLayer.alignmentMode = .center
        thumbLayer.contentsScale = getScallingFactor()
        
        thumbLayer.masksToBounds = false
        thumbLayer.shadowOffset = CGSize(width: .zero, height: 0.5)
        thumbLayer.shadowColor = UIColor.black.cgColor
        thumbLayer.shadowRadius = 2
        thumbLayer.shadowOpacity = 0.125
        thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                             cornerRadius: thumbHeight / 2).cgPath
    }
    
    private func initMinimumLayer() {
        minimumLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        minimumLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        minimumLayer.position = positionForValue(value: minimum)
        minimumLayer.foregroundColor = UIColor.white.cgColor
        minimumLayer.fontSize = 12
        minimumLayer.alignmentMode = .center
        minimumLayer.contentsScale = getScallingFactor()
    }
    
    private func initMaximumLayer() {
        maximumLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        maximumLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        maximumLayer.position = positionForValue(value: maximum)
        maximumLayer.foregroundColor = UIColor.white.cgColor
        maximumLayer.fontSize = 12
        maximumLayer.alignmentMode = .center
        maximumLayer.contentsScale = getScallingFactor()
    }
    
    private func getScallingFactor() -> CGFloat {
        window?.screen.scale ?? UIScreen.main.scale
    }
    
    // MARK: Update methods
    
    private func reinitComponentValues() {
        trackLayer.minimumValue = minimum
        trackLayer.maximumValue = maximum
        trackLayer.trackMaxColor = trackMaxColor
        trackLayer.trackMinColor = direction == .leftToRight ? trackMinColor : reverseTrackMinColor
        trackLayer.thumbWidth = thumbWidth
        trackLayer.value = value
        trackLayer.cornerRadius = cornerRadius
        
        updateThumbLayersText()
        updateThumbLayersPosition()
    }
    
    private func redrawLayers() {
        trackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
        trackMaskLayer.setNeedsDisplay()
    }
    
    private func updateThumbLayersText() {
        thumbLayer.trackMinColor = direction == .leftToRight ? trackMinColor : reverseTrackMinColor
        thumbLayer.trackMaxColor = trackMaxColor
        thumbLayer.string = textForValue(value)
        minimumLayer.string = textForValue(minimum)
        maximumLayer.string = textForValue(maximum)
    }
    
    private func updateThumbLayersPosition() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setAnimationDuration(.zero)
        
        thumbLayer.position = positionForValue(value: value)
        maximumLayer.position = positionForValue(value: maximum)
        minimumLayer.position = positionForValue(value: minimum)
        CATransaction.commit()
    }
    
    private func updateLayersValue() {
        updateThumbLayersText()
        trackLayer.value = value
    }
    
    private func positionForValue(value: CGFloat) -> CGPoint {
        let yPosition = bounds.height / 2
        if minimum == maximum {
            return CGPoint(x: thumbWidth / 2, y: yPosition)
        }
        
        let xPosition = usableTrackingLength * (value - minimum) / (maximum - minimum) + thumbWidth / 2
        
        return CGPoint(x: xPosition, y: yPosition)
    }
    
    private func trackRectForBounds() -> CGRect {
        CGRect(x: trackInset,
               y: (bounds.height - trackHeight) / 2,
               width: bounds.width - 2 * trackInset,
               height: trackHeight)
    }
    
    private func textForValue(_ value: CGFloat) -> String {
        guard let delegate else {
            return String(format: "%.0f", value)
        }
        
        return delegate.slider(self, displayTextForValue: value)
    }
    
}
