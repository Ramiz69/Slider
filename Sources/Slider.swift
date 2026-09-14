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

public import UIKit
import QuartzCore

/// An open class that extends `UIControl` to create a customizable slider component.
///
/// It supports various configurations to control the appearance and behavior of the slider,
/// including its value range, direction, thumb and track configurations, and haptic feedback settings.
open class Slider: UIControl {

    /// Enumerates the possible directions of the slider.
    public enum Direction: CaseIterable, Sendable {
        case leftToRight, rightToLeft
        case bottomToTop, topToBottom

        /// Determines the axis of the slider based on its direction.
        var axis: Axis {
            switch self {
            case .leftToRight, .rightToLeft:
                    .x
            case .bottomToTop, .topToBottom:
                    .y
            }
        }

        /// Whether the value grows along the natural direction of the axis.
        var isReversed: Bool {
            switch self {
            case .leftToRight, .topToBottom: false
            case .rightToLeft, .bottomToTop: true
            }
        }

        /// Enumerates the possible axes of the slider.
        enum Axis {
            case x
            case y
        }
    }

    /// Enumerates the possible animation styles for the slider's value change.
    public enum AnimationStyle: Sendable {
        case none
        case `default`

        /// Determines the animation duration based on the animation style.
        var animationDuration: TimeInterval {
            switch self {
            case .none: .zero
            case .default: CATransaction.animationDuration()
            }
        }
    }

    /// The delegate for the slider, conforming to `SliderDelegate`.
    ///
    /// The reference is weak: the object owning the slider is usually the delegate as well,
    /// and a strong reference here would keep that object alive forever.
    public weak var delegate: (any SliderDelegate)? {
        didSet {
            adjustThumbWidthForDelegateText()
            updateThumbLayersText()
            updateAccessibility()
        }
    }

    // MARK: Customization properties

    /// The current value of the slider, clamped to `minimum...maximum`.
    final public var value: CGFloat {
        get { storedValue }
        set { updateValue(newValue, notifiesObservers: true) }
    }

    /// The minimum value of the slider.
    ///
    /// Raising it above ``maximum`` pushes the maximum up, mirroring the previous behaviour.
    final public var minimum: CGFloat {
        get { storedMinimum }
        set {
            guard newValue.isFinite, newValue != storedMinimum else { return }

            storedMinimum = newValue
            if storedMaximum < storedMinimum {
                storedMaximum = storedMinimum
            }
            clampStepToRange()
            updateValue(storedValue, notifiesObservers: false)
            refreshAfterBoundsChange()
        }
    }

    /// The maximum value of the slider.
    ///
    /// Lowering it below ``minimum`` pulls the minimum down, mirroring the previous behaviour.
    final public var maximum: CGFloat {
        get { storedMaximum }
        set {
            guard newValue.isFinite, newValue != storedMaximum else { return }

            storedMaximum = newValue
            if storedMaximum < storedMinimum {
                storedMinimum = storedMaximum
            }
            clampStepToRange()
            updateValue(storedValue, notifiesObservers: false)
            refreshAfterBoundsChange()
        }
    }

    /// The step value of the slider, determining the increments between values.
    ///
    /// A step of `0` makes the slider continuous. Negative and non-finite values are ignored.
    final public var step: CGFloat {
        get { storedStep }
        set {
            guard newValue.isFinite else { return }

            storedStep = max(newValue, .zero)
            let range = storedMaximum - storedMinimum
            if storedStep > range {
                storedMaximum = storedMinimum + storedStep
                updateValue(storedValue, notifiesObservers: false)
                refreshAfterBoundsChange()
            }
            updateAccessibility()
        }
    }

    /// The corner radius for the slider's track and thumb.
    final public var cornerRadius: CGFloat = 16 {
        didSet {
            guard cornerRadius != oldValue else { return }

            updateVisualComponents()
            setNeedsLayersDisplay()
        }
    }

    /// The configuration for the slider's thumb.
    public var thumbConfiguration = ThumbConfiguration() {
        didSet {
            // `adjustThumbWidthForDelegateText` writes back into this property, so the
            // observer is short-circuited to keep that write from re-entering here.
            guard !isAdjustingThumbWidth, thumbConfiguration != oldValue else { return }

            adjustThumbWidthForDelegateText()
            applyThumbConfiguration()
            updateThumbLayersText()
            setNeedsLayout()
            setNeedsLayersDisplay()
        }
    }

    /// The configuration for the slider's track.
    public var trackConfiguration = TrackConfiguration() {
        didSet {
            guard trackConfiguration != oldValue else { return }

            invalidateIntrinsicContentSize()
            updateVisualComponents()
            setNeedsLayout()
            setNeedsLayersDisplay()
        }
    }

    /// The configuration for the slider's maximum endpoint label.
    public var maximumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            guard maximumEndpointConfiguration != oldValue else { return }

            configureEndpointLayer(.maximum)
        }
    }

    /// The configuration for the slider's minimum endpoint label.
    public var minimumEndpointConfiguration = RangeEndpointsConfiguration() {
        didSet {
            guard minimumEndpointConfiguration != oldValue else { return }

            configureEndpointLayer(.minimum)
        }
    }

    /// The configuration for haptic feedback during user interactions with the slider.
    ///
    /// Assigning a configuration that only differs in ``HapticConfiguration/kind`` reuses the
    /// existing engine; the expensive `CHHapticEngine` is only rebuilt when its parameters change.
    public var hapticConfiguration = HapticConfiguration() {
        didSet {
            guard hapticConfiguration.requiresNewEngine(comparedTo: oldValue) else { return }

            hapticManager = HapticManager(
                initialIntensity: hapticConfiguration.initialIntensity,
                initialSharpness: hapticConfiguration.initialSharpness,
                relativeTime: hapticConfiguration.relativeTime,
                duration: hapticConfiguration.duration
            )
        }
    }

    /// The configuration for the iOS 26 Liquid Glass appearance.
    ///
    /// Defaults to ``GlassConfiguration/Mode/automatic``, which renders glass on iOS 26 and later
    /// and keeps the classic flat appearance on earlier systems.
    public var glassConfiguration = GlassConfiguration() {
        didSet {
            guard glassConfiguration != oldValue else { return }

            applyGlassConfiguration()
        }
    }

    // MARK: Properties

    /// The intrinsic content size of the slider, depending on its direction.
    open override var intrinsicContentSize: CGSize {
        let thickness = max(trackConfiguration.height, thumbConfiguration.size.height)
        return switch direction.axis {
        case .x:
            CGSize(width: UIView.noIntrinsicMetric, height: thickness)
        case .y:
            CGSize(width: thickness, height: UIView.noIntrinsicMetric)
        }
    }

    /// The direction of the slider, determining its layout and behavior.
    final public var direction: Direction = .leftToRight {
        didSet {
            guard direction != oldValue else { return }

            applyDirectionChange(playsHaptic: true)
        }
    }

    /// The last touch location observed during tracking.
    final public private(set) var previousTouchPoint: CGPoint = .zero

    /// The length of the track that is usable for moving the thumb, excluding the thumb width.
    final public private(set) var usableTrackingLength: CGFloat = .zero

    /// The animation style for the slider's value change.
    final public var animationStyle: AnimationStyle = .none

    /// Indicates if the value change events are continuous during user interaction.
    ///
    /// When `false`, `.valueChanged` is only sent once tracking ends.
    final public var continuous = true

    /// Whether a tap anywhere on the track moves the thumb to that position. Defaults to `false`
    /// so the historical "drag the thumb only" behaviour is preserved.
    final public var allowsTapToSeek = false

    /// Whether the horizontal directions follow the interface layout direction.
    ///
    /// In a right-to-left interface ``Direction/leftToRight`` is rendered right-to-left and vice
    /// versa, the way `UISlider` behaves. Vertical directions are never mirrored. Set this to
    /// `false` to pin the slider to the direction you assigned, whatever the locale.
    final public var respectsLayoutDirection = true {
        didSet {
            guard respectsLayoutDirection != oldValue else { return }

            setNeedsLayout()
            updateSlider()
        }
    }

    /// The direction the slider is actually laid out in, after mirroring for a right-to-left
    /// interface. All geometry is derived from this rather than from ``direction``.
    final public var resolvedDirection: Direction {
        guard respectsLayoutDirection,
              direction.axis == .x,
              effectiveUserInterfaceLayoutDirection == .rightToLeft else { return direction }

        return direction == .leftToRight ? .rightToLeft : .leftToRight
    }

    let thumbLayer = ThumbLayer()
    var hapticManager = HapticManager()
    var transientTimer: (any DispatchSourceTimer)?

    private let trackLayer = SliderTrackLayer()
    private let minimumLayer = TextLayer()
    private let maximumLayer = TextLayer()
    private let glassSurface = SliderGlassSurface()
    private var isDirectionChangeAnimationInProgress = false
    private var isPerformingExplicitAnimation = false
    private var isAdjustingThumbWidth = false
    /// Where the current drag started, and the value the slider had at that moment.
    private var trackingAnchor: (point: CGPoint, value: CGFloat)?
    private var valueContinuations: [UUID: AsyncStream<CGFloat>.Continuation] = [:]

    private var storedValue: CGFloat = 10
    private var storedMinimum: CGFloat = 10
    private var storedMaximum: CGFloat = 800
    private var storedStep: CGFloat = 10

    /// The normalized position of the current value, guarded against an empty range.
    private var valueRatio: CGFloat {
        let range = storedMaximum - storedMinimum
        guard range > .zero else { return .zero }

        return ((storedValue - storedMinimum) / range).clamped(to: 0...1)
    }

    private enum Endpoint: CaseIterable {
        case minimum, maximum
    }

    // MARK: Initial methods

    /// Creates a control with the specified frame and direction
    public init(direction: Direction, frame: CGRect = .zero) {
        super.init(frame: frame)

        // The stored property is set directly so the observer does not run configuration
        // routines against layers that have not been created yet.
        self.direction = direction
        commonInit()
    }

    /// Creates a control with the specified frame
    public override init(frame: CGRect) {
        super.init(frame: frame)

        commonInit()
    }

    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        transientTimer?.cancel()
        transientTimer = nil
        for continuation in valueContinuations.values {
            continuation.finish()
        }
    }

    // MARK: Life cycle

    /// Lays out the slider's subviews and updates the layout based on the current state and properties.
    public override func layoutSubviews() {
        super.layoutSubviews()

        glassSurface.frame = bounds
        guard !isDirectionChangeAnimationInProgress else { return }

        let thumbSize = thumbSizeForDirection()
        switch direction.axis {
        case .x:
            usableTrackingLength = max(bounds.width - thumbSize.width, .zero)
        case .y:
            usableTrackingLength = max(bounds.height - thumbSize.height, .zero)
        }
        trackLayer.frame = trackRectForBounds()
        updateEndpointPositions()
        updateSlider()
    }

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        guard window != nil else { return }

        let scale = getScreenScale()
        trackLayer.contentsScale = scale
        thumbLayer.contentsScale = scale
        minimumLayer.contentsScale = scale
        maximumLayer.contentsScale = scale
    }

    // MARK: Public methods

    /// Assigns a new value, optionally animating the thumb, and resumes once the animation completes.
    ///
    /// - Parameters:
    ///   - newValue: The value to assign. It is clamped to `minimum...maximum`.
    ///   - animated: Whether the change is animated. Defaults to `true`.
    public func setValue(_ newValue: CGFloat, animated: Bool = true) async {
        guard animated else {
            value = newValue

            return
        }

        await withCheckedContinuation { continuation in
            guard glassSurface.isActive else {
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    continuation.resume()
                }
                CATransaction.setAnimationDuration(AnimationStyle.default.animationDuration)
                isPerformingExplicitAnimation = true
                value = newValue
                isPerformingExplicitAnimation = false
                CATransaction.commit()

                return
            }

            // The glass material follows a spring rather than a Core Animation timing curve,
            // so the thumb keeps its fluid deformation while the value changes.
            glassSurface.animate({ [weak self] in
                guard let self else { return }

                self.isPerformingExplicitAnimation = true
                self.value = newValue
                self.isPerformingExplicitAnimation = false
            }, completion: {
                continuation.resume()
            })
        }
    }

    /// An asynchronous sequence of the slider's values, emitting on every change.
    ///
    /// Each call returns an independent stream; iterating it keeps the slider alive only for as
    /// long as the stream itself lives, and cancelling the iteration unregisters the observer.
    public var valueStream: AsyncStream<CGFloat> {
        AsyncStream { continuation in
            let identifier = UUID()
            valueContinuations[identifier] = continuation
            continuation.yield(storedValue)
            continuation.onTermination = { [weak self] _ in
                Task { @MainActor [weak self] in
                    self?.valueContinuations[identifier] = nil
                }
            }
        }
    }

    /// Warms up the haptic engine so the first interaction is not delayed.
    public func prepareHaptics() async {
        await hapticManager.prepare()
    }

    // MARK: Internal methods

    func didBeginTracking() {
        delegate?.didBeginTracking(self)
    }

    func endTracking() {
        cancelTransientTimer()
    }

    func cancelTransientTimer() {
        transientTimer?.cancel()
        transientTimer = nil
    }

    /// Applies a value coming from user interaction and emits the matching control events.
    func applyTrackedValue(_ newValue: CGFloat) {
        let previous = storedValue
        updateValue(newValue, notifiesObservers: true)
        guard storedValue != previous else { return }

        delegate?.didContinueTracking(self)
        if continuous {
            sendActions(for: .valueChanged)
        }
    }

    /// Whether the given point, in the slider's coordinate space, lies on the thumb.
    func thumbContains(_ point: CGPoint) -> Bool {
        thumbFrame.insetBy(dx: -thumbHitSlop, dy: -thumbHitSlop).contains(point)
    }

    /// Whether the given point lies on the track.
    ///
    /// A slider stretched beyond its track — a common Auto Layout setup — would otherwise let a
    /// tap anywhere in that area seek, far away from anything the user can see.
    func trackContains(_ point: CGPoint) -> Bool {
        let thumbSize = thumbSizeForDirection()
        let track = trackRectForBounds()
        let inset = switch direction.axis {
        case .x: CGSize(width: .zero, height: max(thumbSize.height - track.height, .zero) / 2)
        case .y: CGSize(width: max(thumbSize.width - track.width, .zero) / 2, height: .zero)
        }

        return track.insetBy(dx: -inset.width, dy: -inset.height).contains(point)
    }

    /// The value represented by a point in the slider's coordinate space.
    func value(at point: CGPoint) -> CGFloat {
        guard usableTrackingLength > .zero else { return storedValue }

        let thumbSize = thumbSizeForDirection()
        let offset: CGFloat = switch direction.axis {
        case .x: point.x - thumbSize.width / 2
        case .y: point.y - thumbSize.height / 2
        }
        var ratio = (offset / usableTrackingLength).clamped(to: 0...1)
        if resolvedDirection.isReversed {
            ratio = 1 - ratio
        }

        return storedMinimum + ratio * (storedMaximum - storedMinimum)
    }

    /// Rounds a value to the nearest step, tolerating a step of zero.
    func steppedValue(_ rawValue: CGFloat) -> CGFloat {
        guard storedStep > .zero, rawValue.isFinite else { return rawValue }

        return (rawValue / storedStep).rounded(.toNearestOrEven) * storedStep
    }

    /// Records where a drag starts so every later position is measured from that point.
    func beginTrackingAnchor(at point: CGPoint) {
        trackingAnchor = (point, storedValue)
        previousTouchPoint = point
    }

    func clearTrackingAnchor() {
        trackingAnchor = nil
    }

    /// The value for the current finger position during a drag.
    ///
    /// The value is derived from the total distance travelled since the drag began rather than
    /// accumulated event by event. Accumulating rounded per-event deltas turned a half-step
    /// movement into a whole step each time, so the thumb ran ahead of the finger — by more than
    /// 1.5× on a vertical slider — and past the ends it detached from the finger entirely.
    func trackedValue(for point: CGPoint) -> CGFloat {
        guard let trackingAnchor, usableTrackingLength > .zero else { return storedValue }

        let distance = switch direction.axis {
        case .x: point.x - trackingAnchor.point.x
        case .y: point.y - trackingAnchor.point.y
        }
        let delta = (storedMaximum - storedMinimum) * distance / usableTrackingLength
        let rawValue = resolvedDirection.isReversed ? trackingAnchor.value - delta
                                                    : trackingAnchor.value + delta

        return steppedValue(rawValue).clamped(to: storedMinimum...max(storedMinimum, storedMaximum))
    }

    func trackTouchPoint(_ point: CGPoint) {
        previousTouchPoint = point
    }

    func sharpnessAndIntensityAt(location: CGPoint) -> (sharpness: Float, intensity: Float) {
        let clippedLocation = clipLocation(location)
        let normalizedLocation = normalizeCoordinates(clippedLocation)

        let eventIntensity = 1 - Float(normalizedLocation.y)
        let eventSharpness = Float(normalizedLocation.x)

        return (eventSharpness, eventIntensity)
    }

    // MARK: Private methods

    private func commonInit() {
        configureControl()
        configureTrackLayer()
        setupThumbLayer()
        setupEndpoints()
        applyGlassConfiguration()
        configureAccessibility()
        registerForAppearanceChanges()
        setNeedsLayout()
    }

    /// Configures the initial state and sublayers of the slider control.
    private func configureControl() {
        backgroundColor = .clear
        layer.addSublayer(trackLayer)
        layer.addSublayer(minimumLayer)
        layer.addSublayer(maximumLayer)
        layer.addSublayer(thumbLayer)
        glassSurface.frame = bounds
        glassSurface.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(glassSurface)
    }

    /// Configures the track layer of the slider, setting its initial appearance based on the track configuration.
    private func configureTrackLayer() {
        trackLayer.contentsScale = getScreenScale()
        trackLayer.frame = trackRectForBounds()
        trackLayer.trackBackgroundColor = resolvedColor(trackConfiguration.maxColor)
        trackLayer.fillColor = fillColorForDirection()
        trackLayer.cornerRadius = cornerRadius
    }

    /// Sets up endpoint layers for the slider, configuring them based on their respective configurations.
    private func setupEndpoints() {
        Endpoint.allCases.forEach { configureEndpointLayer($0) }
    }

    /// Configures the thumb layer of the slider, setting its initial appearance based on the thumb configuration.
    private func setupThumbLayer() {
        thumbLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        thumbLayer.bounds = CGRect(origin: .zero, size: thumbSizeForDirection())
        thumbLayer.position = position(forValue: storedValue)
        thumbLayer.alignmentMode = .center
        thumbLayer.contentsScale = getScreenScale()
        thumbLayer.masksToBounds = false
        applyThumbConfiguration()
        updateThumbLayersText()
    }

    private func applyThumbConfiguration() {
        let isGlass = glassSurface.isActive
        thumbLayer.font = UIFont.systemFont(ofSize: thumbConfiguration.fontSize, weight: .black)
        thumbLayer.fontSize = thumbConfiguration.fontSize
        thumbLayer.borderWidth = isGlass ? .zero : thumbConfiguration.borderWidth
        thumbLayer.backgroundColor = isGlass ? UIColor.clear.cgColor
                                             : resolvedColor(thumbConfiguration.backgroundColor)
        thumbLayer.cornerRadius = isGlass ? .zero : thumbSizeForDirection().height / 2
        // The glass material renders its own shadow; a second one would double up.
        thumbLayer.shadowOpacity = isGlass ? .zero : 0.125
        thumbLayer.shadowOffset = shadowOffsetForDirection()
        thumbLayer.shadowColor = UIColor.black.cgColor
        thumbLayer.shadowRadius = 2
        updateThumbShadowPath()
    }

    private func updateThumbShadowPath() {
        guard !glassSurface.isActive else {
            thumbLayer.shadowPath = nil

            return
        }

        thumbLayer.shadowPath = UIBezierPath(roundedRect: thumbLayer.bounds,
                                             cornerRadius: thumbLayer.cornerRadius).cgPath
    }

    private func configureEndpointLayer(_ endpoint: Endpoint) {
        let layerFrame = CGRect(origin: .zero, size: thumbSizeForDirection())
        let scale = getScreenScale()
        switch endpoint {
        case .minimum:
            minimumLayer.anchorPoint = minimumEndpointConfiguration.anchorPoint
            minimumLayer.bounds = layerFrame
            minimumLayer.position = position(forValue: storedMinimum)
            minimumLayer.foregroundColor = minimumEndpointConfiguration.foregroundColor
            minimumLayer.fontSize = minimumEndpointConfiguration.fontSize
            minimumLayer.alignmentMode = minimumEndpointConfiguration.aligmentMode
            minimumLayer.contentsScale = scale
        case .maximum:
            maximumLayer.anchorPoint = maximumEndpointConfiguration.anchorPoint
            maximumLayer.bounds = layerFrame
            maximumLayer.position = position(forValue: storedMaximum)
            maximumLayer.foregroundColor = maximumEndpointConfiguration.foregroundColor
            maximumLayer.fontSize = maximumEndpointConfiguration.fontSize
            maximumLayer.alignmentMode = maximumEndpointConfiguration.aligmentMode
            maximumLayer.contentsScale = scale
        }
    }

    /// The scale of the screen the slider is shown on, falling back to the main scene's screen.
    private func getScreenScale() -> CGFloat {
        if let scale = window?.screen.scale {
            return scale
        }

        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive } ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first

        return scene?.screen.scale ?? 1
    }

    /// Resolves a dynamic color against the slider's current trait collection.
    private func resolvedColor(_ color: UIColor) -> CGColor {
        color.resolvedColor(with: traitCollection).cgColor
    }

    /// Determines the correct fill color for the slider's direction.
    private func fillColorForDirection() -> CGColor {
        resolvedColor(direction.isReversed ? trackConfiguration.reverseMinColor
                                           : trackConfiguration.minColor)
    }

    /// The thumb size for the slider's direction, with width and height swapped on the vertical axis.
    private func thumbSizeForDirection() -> CGSize {
        switch direction.axis {
        case .x:
            thumbConfiguration.size
        case .y:
            CGSize(width: thumbConfiguration.size.height, height: thumbConfiguration.size.width)
        }
    }

    /// The thumb's frame in the slider's coordinate space, regardless of who hosts the layer.
    private var thumbFrame: CGRect {
        let size = thumbSizeForDirection()
        let center = position(forValue: storedValue)

        return CGRect(x: center.x - size.width / 2,
                      y: center.y - size.height / 2,
                      width: size.width,
                      height: size.height)
    }

    /// The thumb's centre in the slider's coordinate space, used by the test suite.
    var thumbCenterForTesting: CGPoint { position(forValue: storedValue) }

    /// Extra touch area around the thumb so small thumbs stay reachable.
    private var thumbHitSlop: CGFloat {
        let size = thumbSizeForDirection()

        return max(.zero, (44 - min(size.width, size.height)) / 2)
    }

    /// Determines the appropriate shadow offset for the thumb layer based on the slider's direction.
    private func shadowOffsetForDirection() -> CGSize {
        direction.axis == .x ? CGSize(width: .zero, height: 0.5) : CGSize(width: 0.5, height: .zero)
    }

    /// Widens the thumb so the delegate's longest text fits.
    private func adjustThumbWidthForDelegateText() {
        guard let maxText = delegate?.slider(self, displayTextForValue: storedMaximum),
              !maxText.isEmpty else { return }

        let font = UIFont.boldSystemFont(ofSize: thumbConfiguration.fontSize)
        let textWidth = maxText.width(with: font)
        let padding = thumbConfiguration.borderWidth * 2 + 8
        let newWidth = max(textWidth + padding, thumbConfiguration.size.width)
        guard newWidth != thumbConfiguration.size.width else { return }

        isAdjustingThumbWidth = true
        thumbConfiguration.size.width = newWidth
        isAdjustingThumbWidth = false
        thumbLayer.bounds = CGRect(origin: .zero, size: thumbSizeForDirection())
        thumbLayer.cornerRadius = glassSurface.isActive ? .zero : thumbSizeForDirection().height / 2
        updateThumbShadowPath()
        setNeedsLayout()
    }

    /**
     Clamps the given point so that it does not lie outside the view's bounds.

     - Parameter point: The original point.
     - Returns: A point that is guaranteed to be within the boundaries of the control.
     */
    private func clipLocation(_ point: CGPoint) -> CGPoint {
        CGPoint(x: point.x.clamped(to: 0...max(bounds.width, .zero)),
                y: point.y.clamped(to: 0...max(bounds.height, .zero)))
    }

    /**
     Normalizes the given point's coordinates according to the view's dimensions,
     translating them into the [0, 1] range on each axis.

     - Parameter point: The original point.
     - Returns: A point whose coordinates lie within the [0, 1] range.
     */
    private func normalizeCoordinates(_ point: CGPoint) -> CGPoint {
        let width = bounds.width
        let height = bounds.height
        guard width > .zero, height > .zero else { return .zero }

        return CGPoint(x: point.x / width, y: point.y / height)
    }

    // MARK: Update methods

    /// The single place that mutates the backing value, keeping clamping and notifications together.
    private func updateValue(_ newValue: CGFloat, notifiesObservers: Bool) {
        let sanitized = newValue.isFinite ? newValue : storedMinimum
        let clamped = sanitized.clamped(to: storedMinimum...max(storedMinimum, storedMaximum))
        guard clamped != storedValue else { return }

        storedValue = clamped
        updateVisualComponents()
        setNeedsLayersDisplay()
        updateSlider()
        updateAccessibility()
        if notifiesObservers {
            for continuation in valueContinuations.values {
                continuation.yield(clamped)
            }
        }
    }

    private func clampStepToRange() {
        let range = storedMaximum - storedMinimum
        if storedStep > range {
            storedStep = range
        }
    }

    private func refreshAfterBoundsChange() {
        updateVisualComponents()
        setNeedsLayersDisplay()
        setNeedsLayout()
        updateEndpointPositions()
        updateSlider()
        updateAccessibility()
    }

    /// Updates the visual components of the slider when certain properties change.
    private func updateVisualComponents() {
        trackLayer.trackBackgroundColor = resolvedColor(trackConfiguration.maxColor)
        trackLayer.fillColor = fillColorForDirection()
        trackLayer.cornerRadius = cornerRadius
        updateThumbLayersText()
    }

    private func applyDirectionChange(playsHaptic: Bool) {
        invalidateIntrinsicContentSize()
        if playsHaptic {
            try? hapticManager.playTransientHaptic(intensity: 1, sharpness: 0.33)
        }
        thumbLayer.bounds = CGRect(origin: .zero, size: thumbSizeForDirection())
        applyThumbConfiguration()
        Endpoint.allCases.forEach { configureEndpointLayer($0) }
        redrawLayers()
        updateVisualComponents()
        setNeedsLayersDisplay()
    }

    /// Redraws layers when the slider's direction changes, ensuring the visual transition is smooth.
    private func redrawLayers() {
        guard animationStyle == .default else {
            isDirectionChangeAnimationInProgress = false
            updateEndpointPositions()
            setNeedsLayout()
            layoutIfNeeded()

            return
        }

        isDirectionChangeAnimationInProgress = true
        animateThumbLayer { [weak self] in
            guard let self else { return }

            self.isDirectionChangeAnimationInProgress = false
            self.setNeedsLayout()
        }
        updateEndpointPositions()
    }

    private func updateEndpointPositions() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        minimumLayer.position = position(forValue: storedMinimum)
        maximumLayer.position = position(forValue: storedMaximum)
        CATransaction.commit()
    }

    /// Animates the thumb layer to reflect the change in value or direction.
    private func animateThumbLayer(_ completionBlock: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)
        CATransaction.setAnimationDuration(animationStyle.animationDuration)
        CATransaction.setAnimationTimingFunction(CATransaction.animationTimingFunction())
        isPerformingExplicitAnimation = true
        updateSlider()
        isPerformingExplicitAnimation = false
        CATransaction.commit()
    }

    /// Requests the layers to update their display. This is typically called after a property change that requires visual updates.
    private func setNeedsLayersDisplay() {
        trackLayer.setNeedsDisplay()
        thumbLayer.setNeedsDisplay()
        minimumLayer.setNeedsDisplay()
        maximumLayer.setNeedsDisplay()
    }

    /// The tint applied to the glass thumb, if any.
    private var resolvedGlassTint: UIColor? {
        guard glassSurface.isActive else { return nil }

        if let explicit = glassConfiguration.tintColor {
            return explicit
        }

        return glassConfiguration.tintsThumbWithTrackColor
            ? (direction.isReversed ? trackConfiguration.reverseMinColor : trackConfiguration.minColor)
            : nil
    }

    /// The label color for the thumb.
    ///
    /// Over Liquid Glass the label sits on top of a translucent tint, so the color is chosen for
    /// contrast against that tint unless the caller pinned one via ``ThumbConfiguration/textColor``.
    private func thumbTextColor() -> CGColor {
        if let explicit = thumbConfiguration.textColor {
            return resolvedColor(explicit)
        }

        guard glassSurface.isActive else {
            return fillColorForDirection()
        }

        guard let tint = resolvedGlassTint else {
            return resolvedColor(.label)
        }

        return resolvedColor(tint.isLight(for: traitCollection) ? .black : .white)
    }

    /// Updates the slider's thumb layer text and other properties when the slider's value changes.
    private func updateThumbLayersText() {
        thumbLayer.foregroundColor = thumbTextColor()
        thumbLayer.backgroundColor = glassSurface.isActive ? UIColor.clear.cgColor
                                                           : resolvedColor(thumbConfiguration.backgroundColor)
        thumbLayer.string = text(forValue: storedValue)
        minimumLayer.string = text(forValue: storedMinimum)
        maximumLayer.string = text(forValue: storedMaximum)
        glassSurface.updateThumbTint(resolvedGlassTint)
    }

    /// Updates the slider geometry: the thumb position and the filled part of the track.
    ///
    /// Unless an explicit animation is running, implicit Core Animation actions are disabled:
    /// the thumb is a view during Liquid Glass and moves instantly, so an animated fill layer
    /// would visibly trail behind it while dragging.
    private func updateSlider() {
        guard isPerformingExplicitAnimation else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            applySliderGeometry()
            CATransaction.commit()

            return
        }

        applySliderGeometry()
    }

    private func applySliderGeometry() {
        let thumbSize = thumbSizeForDirection()
        let ratio = valueRatio
        let fillFrame: CGRect
        switch resolvedDirection {
        case .leftToRight:
            let edge = ratio * usableTrackingLength + thumbSize.width / 2
            fillFrame = CGRect(x: .zero, y: .zero, width: edge, height: trackLayer.bounds.height)
        case .rightToLeft:
            let edge = trackLayer.bounds.width - (ratio * usableTrackingLength + thumbSize.width / 2)
            fillFrame = CGRect(x: edge,
                               y: .zero,
                               width: trackLayer.bounds.width - edge,
                               height: trackLayer.bounds.height)
        case .bottomToTop:
            let edge = trackLayer.bounds.height - (ratio * usableTrackingLength + thumbSize.height / 2)
            fillFrame = CGRect(x: .zero,
                               y: edge,
                               width: trackLayer.bounds.width,
                               height: trackLayer.bounds.height - edge)
        case .topToBottom:
            let edge = ratio * usableTrackingLength + thumbSize.height / 2
            fillFrame = CGRect(x: .zero, y: .zero, width: trackLayer.bounds.width, height: edge)
        }

        let thumbCenter = position(forValue: storedValue)
        trackLayer.fillFrame = fillFrame
        if glassSurface.isActive {
            glassSurface.updateThumb(center: thumbCenter,
                                     size: thumbSize,
                                     cornerRadius: min(cornerRadius, thumbSize.height / 2))
            thumbLayer.bounds = CGRect(origin: .zero, size: thumbSize)
            thumbLayer.position = CGPoint(x: thumbSize.width / 2, y: thumbSize.height / 2)
        } else {
            thumbLayer.position = thumbCenter
        }
    }

    /// Calculates the thumb's position based on the given value.
    ///
    /// - Parameter value: The value for which to calculate the thumb position.
    /// - Returns: The point representing the position of the thumb.
    private func position(forValue value: CGFloat) -> CGPoint {
        let thumbSize = thumbSizeForDirection()
        let range = storedMaximum - storedMinimum
        let ratio = range > .zero ? ((value - storedMinimum) / range).clamped(to: 0...1) : .zero
        let offset = usableTrackingLength * ratio

        return switch resolvedDirection {
        case .leftToRight:
            CGPoint(x: offset + thumbSize.width / 2, y: bounds.height / 2)
        case .rightToLeft:
            CGPoint(x: bounds.width - offset - thumbSize.width / 2, y: bounds.height / 2)
        case .bottomToTop:
            CGPoint(x: bounds.width / 2, y: bounds.height - offset - thumbSize.height / 2)
        case .topToBottom:
            CGPoint(x: bounds.width / 2, y: offset + thumbSize.height / 2)
        }
    }

    private func trackRectForBounds() -> CGRect {
        switch direction.axis {
        case .x:
            CGRect(x: trackConfiguration.inset,
                   y: (bounds.height - trackConfiguration.height) / 2,
                   width: max(bounds.width - 2 * trackConfiguration.inset, .zero),
                   height: trackConfiguration.height)
        case .y:
            CGRect(x: (bounds.width - trackConfiguration.height) / 2,
                   y: trackConfiguration.inset,
                   width: trackConfiguration.height,
                   height: max(bounds.height - 2 * trackConfiguration.inset, .zero))
        }
    }

    private func text(forValue value: CGFloat) -> String {
        guard let delegate else {
            return String(format: "%.0f", value)
        }

        return delegate.slider(self, displayTextForValue: value)
    }

    // MARK: Liquid Glass

    private func applyGlassConfiguration() {
        let didChangeActivation = glassSurface.apply(glassConfiguration)
        if didChangeActivation {
            reparentThumbLayer()
        }
        applyThumbConfiguration()
        updateThumbLayersText()
        setNeedsLayout()
    }

    /// Moves the thumb's text layer between the control's own layer and the glass material.
    private func reparentThumbLayer() {
        thumbLayer.removeFromSuperlayer()
        if glassSurface.isActive, let host = glassSurface.thumbContentLayer {
            host.addSublayer(thumbLayer)
        } else {
            layer.addSublayer(thumbLayer)
        }
    }

    // MARK: Appearance

    private func registerForAppearanceChanges() {
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (slider: Slider, _) in
            slider.updateVisualComponents()
            slider.setNeedsLayersDisplay()
        }
        // A right-to-left interface mirrors the horizontal directions, so the geometry has to
        // be recomputed when the layout direction changes underneath the slider.
        registerForTraitChanges([UITraitLayoutDirection.self]) { (slider: Slider, _) in
            slider.setNeedsLayout()
            slider.updateSlider()
        }
    }

    // MARK: Accessibility

    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityTraits.insert(.adjustable)
        updateAccessibility()
    }

    private func updateAccessibility() {
        accessibilityValue = text(forValue: storedValue)
    }

    open override func accessibilityIncrement() {
        adjustValueForAccessibility(increasing: true)
    }

    open override func accessibilityDecrement() {
        adjustValueForAccessibility(increasing: false)
    }

    private func adjustValueForAccessibility(increasing: Bool) {
        let increment = storedStep > .zero ? storedStep : (storedMaximum - storedMinimum) / 100
        guard increment > .zero else { return }

        let previous = storedValue
        updateValue(storedValue + (increasing ? increment : -increment), notifiesObservers: true)
        guard storedValue != previous else { return }

        sendActions(for: .valueChanged)
        delegate?.didEndTracking(self)
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        min(max(self, limits.lowerBound), limits.upperBound)
    }
}
