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

    /// The previous implementation overrode `addTarget` with an empty body, so registrations
    /// were silently dropped. `UIApplication` does not dispatch actions in a host-less test
    /// bundle, so the registration itself is what this asserts.
    @Test("addTarget registers the target instead of dropping it")
    func addTargetRegistersTarget() {
        let slider = makeSlider()
        let spy = TargetSpy()

        slider.addTarget(spy, action: #selector(TargetSpy.handleValueChanged), for: .valueChanged)

        #expect(slider.allTargets.contains(spy))
        #expect(slider.actions(forTarget: spy, forControlEvent: .valueChanged) == ["handleValueChanged"])

        slider.removeTarget(spy, action: #selector(TargetSpy.handleValueChanged), for: .valueChanged)
        #expect(slider.allTargets.isEmpty)
    }

    @Test("addAction registers the action instead of dropping it")
    func addActionRegistersAction() {
        let slider = makeSlider()
        let action = UIAction { _ in }

        slider.addAction(action, for: .valueChanged)

        var registered: [UIAction] = []
        slider.enumerateEventHandlers { handledAction, _, event, _ in
            if let handledAction, event.contains(.valueChanged) {
                registered.append(handledAction)
            }
        }

        #expect(registered.count == 1)
        #expect(registered.first?.identifier == action.identifier)
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
