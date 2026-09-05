//
//  SliderTests.swift
//  Slider
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import Testing
import UIKit
@testable import Slider

@MainActor
struct SliderValueTests {

    private func makeSlider(direction: Slider.Direction = .leftToRight) -> Slider {
        let slider = Slider(direction: direction,
                            frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.layoutIfNeeded()

        return slider
    }

    @Test("A value above the maximum is clamped instead of stretching the range")
    func clampsValueToMaximum() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100

        slider.value = 500

        #expect(slider.value == 100)
        #expect(slider.maximum == 100)
    }

    @Test("A value below the minimum is clamped")
    func clampsValueToMinimum() {
        let slider = makeSlider()
        slider.minimum = 20
        slider.maximum = 100

        slider.value = -30

        #expect(slider.value == 20)
    }

    @Test("A non-finite value never reaches the layers")
    func rejectsNonFiniteValues() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 50

        slider.value = .nan
        #expect(slider.value == 0)

        slider.value = .infinity
        #expect(slider.value.isFinite)
    }

    @Test("An empty range does not produce NaN geometry")
    func emptyRangeKeepsGeometryFinite() {
        let slider = makeSlider()
        slider.minimum = 50
        slider.maximum = 50

        slider.value = 50
        slider.layoutIfNeeded()

        #expect(slider.value == 50)
        #expect(slider.thumbLayer.position.x.isFinite)
        #expect(slider.thumbLayer.position.y.isFinite)
    }

    @Test("Lowering the maximum below the value pulls the value down")
    func loweringMaximumClampsValue() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 90

        slider.maximum = 50

        #expect(slider.value == 50)
    }

    @Test("Raising the minimum above the value pushes the value up")
    func raisingMinimumClampsValue() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 10

        slider.minimum = 40

        #expect(slider.value == 40)
    }

    @Test("A step of zero makes the slider continuous instead of producing NaN")
    func zeroStepKeepsValuesFinite() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.step = 0

        let stepped = slider.steppedValue(37.4)

        #expect(stepped == 37.4)
        #expect(stepped.isFinite)
    }

    @Test("A negative step is normalized to zero")
    func negativeStepIsNormalized() {
        let slider = makeSlider()
        slider.step = -5

        #expect(slider.step == 0)
    }

    @Test("Values are rounded to the nearest step")
    func roundsToNearestStep() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.step = 10

        #expect(slider.steppedValue(43) == 40)
        #expect(slider.steppedValue(46) == 50)
    }

    @Test("A point on the track maps back to the matching value", arguments: [
        Slider.Direction.leftToRight,
        .rightToLeft,
        .bottomToTop,
        .topToBottom,
    ])
    func mapsPointToValue(direction: Slider.Direction) {
        let slider = Slider(direction: direction,
                            frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        slider.minimum = 0
        slider.maximum = 100
        slider.layoutIfNeeded()

        let mid = CGPoint(x: slider.bounds.midX, y: slider.bounds.midY)
        let value = slider.value(at: mid)

        #expect(value.isFinite)
        #expect(abs(value - 50) < 1)
    }

    @Test("Switching direction keeps the geometry finite")
    func directionChangeKeepsGeometryFinite() {
        let slider = makeSlider()
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 40

        for direction in Slider.Direction.allCases {
            slider.direction = direction
            slider.layoutIfNeeded()

            #expect(slider.thumbLayer.position.x.isFinite)
            #expect(slider.thumbLayer.position.y.isFinite)
        }
    }
}

@MainActor
struct SliderControlEventTests {

    private final class TargetSpy: NSObject {
        private(set) var callCount = 0

        @objc
        func handleValueChanged() {
            callCount += 1
        }
    }

    private final class TrackingSpy: SliderDelegate {
        private(set) var continueCount = 0
        private(set) var endCount = 0

        func slider(_ slider: Slider, displayTextForValue value: CGFloat) -> String {
            "\(Int(value))"
        }

        func didContinueTracking(_ slider: Slider) {
            continueCount += 1
        }

        func didEndTracking(_ slider: Slider) {
            endCount += 1
        }
    }

    private func makeSlider() -> Slider {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.minimum = 0
        slider.maximum = 100
        slider.layoutIfNeeded()

        return slider
    }

    /// The previous implementation overrode `addTarget` with an empty body, so registrations were
    /// silently dropped and the action never fired.
    @Test("addTarget delivers .valueChanged to its target")
    func addTargetDeliversValueChanged() {
        let slider = makeSlider()
        let spy = TargetSpy()

        slider.addTarget(spy, action: #selector(TargetSpy.handleValueChanged), for: .valueChanged)
        #expect(slider.allTargets.contains(spy))

        slider.applyTrackedValue(30)
        #expect(spy.callCount == 1)

        slider.removeTarget(spy, action: #selector(TargetSpy.handleValueChanged), for: .valueChanged)
        #expect(slider.allTargets.isEmpty)

        slider.applyTrackedValue(40)
        #expect(spy.callCount == 1)
    }

    @Test("A non-continuous slider defers .valueChanged until tracking ends")
    func nonContinuousSliderDefersDelivery() {
        let slider = makeSlider()
        slider.continuous = false
        let spy = TargetSpy()
        slider.addTarget(spy, action: #selector(TargetSpy.handleValueChanged), for: .valueChanged)

        slider.applyTrackedValue(30)

        #expect(spy.callCount == 0)
    }

    @Test("addAction delivers .valueChanged to its handler")
    func addActionDeliversValueChanged() {
        let slider = makeSlider()
        var handled = 0
        let action = UIAction { _ in handled += 1 }

        slider.addAction(action, for: .valueChanged)
        slider.applyTrackedValue(30)

        #expect(handled == 1)

        slider.removeAction(action, for: .valueChanged)
        slider.applyTrackedValue(40)

        #expect(handled == 1)
    }

    @Test("The delegate is told about every tracked change")
    func delegateReceivesTrackingUpdates() {
        let slider = makeSlider()
        let spy = TrackingSpy()
        slider.delegate = spy

        slider.applyTrackedValue(30)
        slider.applyTrackedValue(40)
        // A repeated value must not be reported twice.
        slider.applyTrackedValue(40)

        #expect(spy.continueCount == 2)
    }

    @Test("Accessibility adjustments move the value by one step")
    func accessibilityAdjustmentsUseStep() {
        let slider = makeSlider()
        slider.step = 10
        slider.value = 50

        slider.accessibilityIncrement()
        #expect(slider.value == 60)

        slider.accessibilityDecrement()
        #expect(slider.value == 50)

        #expect(slider.accessibilityTraits.contains(.adjustable))
        #expect(slider.accessibilityValue == "50")
    }
}

@MainActor
struct SliderMemoryTests {

    private final class DelegateSpy: SliderDelegate {
        func slider(_ slider: Slider, displayTextForValue value: CGFloat) -> String {
            "\(Int(value))"
        }
    }

    @Test("The delegate is held weakly")
    func delegateIsWeak() {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        weak var weakDelegate: DelegateSpy?

        do {
            let delegate = DelegateSpy()
            weakDelegate = delegate
            slider.delegate = delegate
            #expect(weakDelegate != nil)
        }

        #expect(weakDelegate == nil)
        #expect(slider.delegate == nil)
    }

    @Test("The slider itself is released once the last reference goes away")
    func sliderIsReleased() {
        weak var weakSlider: Slider?

        do {
            let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
            slider.layoutIfNeeded()
            slider.value = 40
            weakSlider = slider
            #expect(weakSlider != nil)
        }

        #expect(weakSlider == nil)
    }

    @Test("The haptic manager is released with its owner")
    func hapticManagerIsReleased() {
        weak var weakManager: HapticManager?

        do {
            let manager = HapticManager()
            weakManager = manager
            try? manager.playTransientHaptic(intensity: 1, sharpness: 1)
            #expect(weakManager != nil)
        }

        #expect(weakManager == nil)
    }
}

@MainActor
struct SliderAsyncTests {

    @Test("The async setter resumes after the value is applied")
    func asyncSetValueResumes() async {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.minimum = 0
        slider.maximum = 100
        slider.layoutIfNeeded()

        await slider.setValue(70, animated: false)

        #expect(slider.value == 70)
    }

    @Test("The value stream emits the current value and every change")
    func valueStreamEmitsChanges() async {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 10
        slider.layoutIfNeeded()

        var received: [CGFloat] = []
        let stream = slider.valueStream
        let task = Task { @MainActor in
            for await value in stream {
                received.append(value)
                if received.count == 3 {
                    break
                }
            }

            return received
        }

        slider.value = 20
        slider.value = 30
        let values = await task.value

        #expect(values == [10, 20, 30])
    }
}

@MainActor
struct SliderLayoutDirectionTests {

    private func makeSlider(direction: Slider.Direction,
                            layoutDirection: UISemanticContentAttribute) -> Slider {
        let slider = Slider(direction: direction,
                            frame: CGRect(x: 0, y: 0, width: 320, height: 320))
        slider.semanticContentAttribute = layoutDirection
        slider.minimum = 0
        slider.maximum = 100
        slider.layoutIfNeeded()

        return slider
    }

    @Test("Horizontal directions mirror in a right-to-left interface")
    func horizontalDirectionsMirror() {
        let slider = makeSlider(direction: .leftToRight, layoutDirection: .forceRightToLeft)

        #expect(slider.resolvedDirection == .rightToLeft)

        let mirrored = makeSlider(direction: .rightToLeft, layoutDirection: .forceRightToLeft)

        #expect(mirrored.resolvedDirection == .leftToRight)
    }

    @Test("A left-to-right interface leaves the direction alone")
    func leftToRightIsUnchanged() {
        let slider = makeSlider(direction: .leftToRight, layoutDirection: .forceLeftToRight)

        #expect(slider.resolvedDirection == .leftToRight)
    }

    @Test("Vertical directions are never mirrored", arguments: [
        Slider.Direction.bottomToTop,
        .topToBottom,
    ])
    func verticalDirectionsAreNotMirrored(direction: Slider.Direction) {
        let slider = makeSlider(direction: direction, layoutDirection: .forceRightToLeft)

        #expect(slider.resolvedDirection == direction)
    }

    @Test("Opting out pins the slider to the assigned direction")
    func optingOutPinsDirection() {
        let slider = makeSlider(direction: .leftToRight, layoutDirection: .forceRightToLeft)
        slider.respectsLayoutDirection = false

        #expect(slider.resolvedDirection == .leftToRight)
    }

    @Test("The thumb sits on the opposite side in a right-to-left interface")
    func thumbPositionIsMirrored() {
        let ltr = makeSlider(direction: .leftToRight, layoutDirection: .forceLeftToRight)
        let rtl = makeSlider(direction: .leftToRight, layoutDirection: .forceRightToLeft)
        ltr.value = 25
        rtl.value = 25
        ltr.layoutIfNeeded()
        rtl.layoutIfNeeded()

        let ltrX = ltr.thumbCenterForTesting.x
        let rtlX = rtl.thumbCenterForTesting.x

        #expect(ltrX < ltr.bounds.midX)
        #expect(rtlX > rtl.bounds.midX)
        // The two are reflections of each other around the centre of the track.
        #expect(abs((ltrX + rtlX) - ltr.bounds.width) < 0.5)
    }

    @Test("A tapped point maps to the mirrored value in a right-to-left interface")
    func tapToSeekIsMirrored() {
        let slider = makeSlider(direction: .leftToRight, layoutDirection: .forceRightToLeft)

        let nearLeftEdge = CGPoint(x: slider.thumbCenterForTesting.x * 0 + 40, y: slider.bounds.midY)
        let value = slider.value(at: nearLeftEdge)

        // The left edge is the maximum once the slider is mirrored.
        #expect(value > 50)
    }
}

@MainActor
struct SliderGlassTests {

    @Test("Glass is active on iOS 26 and inert on earlier systems")
    func glassMatchesPlatform() {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.layoutIfNeeded()

        #expect(slider.glassConfiguration.isEffective == GlassConfiguration.isSupportedByPlatform)
    }

    @Test("Disabling glass restores the flat thumb")
    func disablingGlassRestoresFlatThumb() {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.glassConfiguration = GlassConfiguration(mode: .disabled)
        slider.layoutIfNeeded()

        #expect(!slider.glassConfiguration.isEffective)
        #expect(slider.thumbLayer.superlayer === slider.layer)
    }

    @Test("Toggling glass keeps the thumb geometry finite")
    func togglingGlassKeepsGeometryFinite() {
        let slider = Slider(frame: CGRect(x: 0, y: 0, width: 320, height: 36))
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 25
        slider.layoutIfNeeded()

        slider.glassConfiguration = GlassConfiguration(mode: .disabled)
        slider.layoutIfNeeded()
        #expect(slider.thumbLayer.position.x.isFinite)

        slider.glassConfiguration = GlassConfiguration(mode: .automatic)
        slider.layoutIfNeeded()
        #expect(slider.thumbLayer.position.x.isFinite)
        #expect(slider.value == 25)
    }
}
