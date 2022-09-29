//
//  Slider.swift
//
//  Copyright (c) 2020 Ramiz Kichibekov (https://instagram.com/kichibekov69)
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

@IBDesignable
open class Slider: UIControl {
    
    @IBOutlet weak public var delegate: SliderDelegate? {
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
                thumbLayer.position = CGPoint(x: positionForValue(value: minimum),
                                              y: bounds.size.height / 2)
                thumbLayer.cornerRadius = thumbHeight / 2
                thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                                     cornerRadius: thumbHeight / 2).cgPath
            }
            updateThumbLayersText()
        }
    }
    
    // MARK: - Customization properties
    
    @IBInspectable
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
    
    @IBInspectable
    final public var minimum: CGFloat = 10 {
        didSet {
            if minimum > maximum {
                maximum = minimum
            }
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    @IBInspectable
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
    
    @IBInspectable
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
    
    @IBInspectable
    final public var cornerRadius: CGFloat = 16 {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    @IBInspectable
    final public var thumbBackgroundColor: UIColor = UIColor.white {
        didSet {
            thumbLayer.backgroundColor = thumbBackgroundColor.cgColor
            redrawLayers()
        }
    }
    
    @IBInspectable
    final public var thumbTextColor: UIColor = UIColor(red: .zero,
                                                       green: 74 / 255,
                                                       blue: 150 / 255,
                                                       alpha: 1) {
        didSet {
            thumbLayer.foregroundColor = thumbTextColor.cgColor
            redrawLayers()
        }
    }
    
    @IBInspectable
    final public var continuous: Bool = true
    
    @IBInspectable
    final public var fontSize: CGFloat = 14 {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable
    final public var trackHeight: CGFloat = 36 {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    final public var trackInset: CGFloat = .zero {
        didSet {
            layoutSubviews()
        }
    }
    
    @IBInspectable
    final public var thumbHeight: CGFloat = 36 {
        didSet {
            initThumbLayer()
            layoutSubviews()
            redrawLayers()
        }
    }
    
    @IBInspectable
    final public var thumbWidth: CGFloat = 60 {
        didSet {
            initThumbLayer()
            layoutSubviews()
            redrawLayers()
        }
    }
    
    @IBInspectable
    open var trackMaxColor: UIColor = UIColor(red: 191 / 255,
                                              green: 194 / 255,
                                              blue: 209 / 255,
                                              alpha: 1) {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    @IBInspectable
    open var trackMinColor: UIColor = UIColor(red: .zero,
                                              green: 122 / 255,
                                              blue: 1,
                                              alpha: 1) {
        didSet {
            reinitComponentValues()
            redrawLayers()
        }
    }
    
    @IBInspectable
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
    
    final public var direction: DirectionEnum = .leftToRight {
        didSet {
            hapticConfiguration.directionGenerate()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationDuration(.zero)
            let affineTransform = CATransform3DMakeAffineTransform(direction == .leftToRight ? .identity : CGAffineTransform.identity.rotated(by: .pi))
            transform = direction == .leftToRight ? .identity : CGAffineTransform.identity.rotated(by: .pi)
            thumbLayer.transform = affineTransform
            minimumLayer.transform = affineTransform
            maximumLayer.transform = affineTransform
            CATransaction.commit()
            reinitComponentValues()
            redrawLayers()
        }
    }
    open var animator: UIViewPropertyAnimator?
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
    private let trackMaskLayer = CAShapeLayer()
    
    // MARK: - Life cycle
    
    required public override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialControl()
        initLayers()
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialControl()
        initLayers()
        commonInit()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        trackLayer.frame = trackRectForBound(bounds)
        trackMaskLayer.path = UIBezierPath(roundedRect: trackRectForBound(bounds),
                                      cornerRadius: cornerRadius).cgPath
        commonInit()
        updateThumbLayersPosition()
        redrawLayers()
    }
    
    public override func prepareForInterfaceBuilder() {
        trackLayer.frame = trackRectForBound(bounds)
        commonInit()
        updateThumbLayersPosition()
        redrawLayers()
    }
    
    // MARK: - Custom methods
    // MARK: - Private methods
    
    private func initialControl() {
        backgroundColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        layer.addSublayer(trackLayer)
        layer.addSublayer(minimumLayer)
        layer.addSublayer(maximumLayer)
        layer.addSublayer(thumbLayer)
    }
    
    private func initLayers() {
        trackLayer.contentsScale = UIScreen.main.scale
        trackLayer.frame = trackRectForBound(bounds)
        trackLayer.setNeedsDisplay()
        trackMaskLayer.path = UIBezierPath(roundedRect: trackRectForBound(bounds),
                                      cornerRadius: cornerRadius).cgPath
        trackMaskLayer.fillRule = .evenOdd
        layer.mask = trackMaskLayer
        reinitComponentValues()
        initThumbLayer()
        initMinimumLayer()
        initMaximumLayer()
        updateThumbLayersText()
    }
    
    private func initThumbLayer() {
        thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumbLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        let xPosition = positionForValue(value: minimum)
        thumbLayer.position = CGPoint(x: xPosition, y: bounds.size.height / 2)
        thumbLayer.foregroundColor = trackMinColor.cgColor
        thumbLayer.cornerRadius = thumbHeight / 2
        thumbLayer.font = UIFont.systemFont(ofSize: fontSize, weight: .black)
        thumbLayer.fontSize = fontSize
        thumbLayer.backgroundColor = thumbBackgroundColor.cgColor
        thumbLayer.alignmentMode = .center
        thumbLayer.contentsScale = UIScreen.main.scale
        
        thumbLayer.masksToBounds = false
        thumbLayer.shadowOffset = CGSize(width: 0, height: 0.5)
        thumbLayer.shadowColor = UIColor.black.cgColor
        thumbLayer.shadowRadius = 2
        thumbLayer.shadowOpacity = 0.125
        thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                             cornerRadius: thumbHeight / 2).cgPath
    }
    
    private func initMinimumLayer() {
        minimumLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        minimumLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        let xPosition = positionForValue(value: minimum)
        minimumLayer.position = CGPoint(x: xPosition, y: bounds.size.height / 2)
        minimumLayer.foregroundColor = UIColor.white.cgColor
        minimumLayer.fontSize = 12
        minimumLayer.alignmentMode = .center
        minimumLayer.contentsScale = UIScreen.main.scale
    }
    
    private func initMaximumLayer() {
        maximumLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        maximumLayer.bounds = CGRect(x: .zero, y: .zero, width: thumbWidth, height: thumbHeight)
        let xPosition = positionForValue(value: maximum)
        maximumLayer.position = CGPoint(x: xPosition, y: bounds.size.height / 2)
        maximumLayer.foregroundColor = UIColor.white.cgColor
        maximumLayer.fontSize = 12
        maximumLayer.alignmentMode = .center
        maximumLayer.contentsScale = UIScreen.main.scale
    }
    
    private func commonInit() {
        usableTrackingLength = bounds.size.width - thumbWidth
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Update methods
    
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
        
        let thumbCenterX = positionForValue(value: value)
        thumbLayer.position = CGPoint(x: thumbCenterX,
                                      y: bounds.size.height / 2)
        let maximumXPosition = positionForValue(value: maximum)
        maximumLayer.position = CGPoint(x: maximumXPosition,
                                        y: bounds.size.height / 2)
        let minimumXPosition = positionForValue(value: minimum)
        minimumLayer.position = CGPoint(x: minimumXPosition,
                                        y: bounds.size.height / 2)
        CATransaction.commit()
    }
    
    private func updateLayersValue() {
        updateThumbLayersText()
        trackLayer.value = value
    }
    
    private func positionForValue(value: CGFloat) -> CGFloat {
        if minimum == maximum {
            return thumbWidth / 2
        }
        
        return usableTrackingLength * (value - minimum) / (maximum - minimum) + thumbWidth / 2
    }
    
    private func trackRectForBound(_ bound: CGRect) -> CGRect {
        return CGRect(x: trackInset,
                      y: (bound.size.height - trackHeight) / 2,
                      width: bound.size.width - 2 * trackInset,
                      height: trackHeight)
    }
    
    private func textForValue(_ value: CGFloat) -> String {
        guard let delegate = delegate else {
            return String(format: "%.0f", value)
        }
        
        return delegate.slider(self, displayTextForValue: value)
    }
    
}
