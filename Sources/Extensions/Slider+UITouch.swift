//
//  Slider+UITouch.swift
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

extension Slider {

    /// Notifies the control when a touch event enters the control's bounds.
    public override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        let startsOnThumb = thumbContains(location)
        guard startsOnThumb || allowsTapToSeek else { return false }

        trackTouchPoint(location)
        didBeginTracking()
        let (sharpness, intensity) = sharpnessAndIntensityAt(location: location)
        try? hapticManager.playTransientHaptic(intensity: intensity, sharpness: sharpness)
        if !startsOnThumb {
            // Tap-to-seek jumps straight to the tapped position before the drag continues.
            applyTrackedValue(steppedValue(value(at: location)))
        }
        startTransientTimerIfNeeded()

        return true
    }

    /// Notifies the control when a touch event for the control updates.
    public override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let touchPoint = touch.location(in: self)
        let deltaLocation = switch direction.axis {
        case .x: touchPoint.x - previousTouchPoint.x
        case .y: touchPoint.y - previousTouchPoint.y
        }
        guard usableTrackingLength > .zero else {
            trackTouchPoint(touchPoint)

            return true
        }

        let ratio = deltaLocation / usableTrackingLength
        let deltaValue = (maximum - minimum) * ratio
        let rawValue = direction.isReversed ? value - deltaValue : value + deltaValue
        let currentValue = steppedValue(rawValue).clamped(to: minimum...max(minimum, maximum))
        playEndpointHapticIfNeeded(for: currentValue)
        guard currentValue != value else {
            // The touch is kept as the reference point only once the value actually moves,
            // otherwise sub-step movements would be discarded instead of accumulating.
            return true
        }

        trackTouchPoint(touchPoint)
        applyTrackedValue(currentValue)

        return true
    }

    /// Notifies the control when a touch event associated with the control ends.
    public override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)

        finishTracking()
    }

    /// Notifies the control when a tracking touch is cancelled by the system.
    public override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)

        finishTracking()
    }

    // MARK: Private methods

    private func finishTracking() {
        endTracking()
        value = steppedValue(value)
        delegate?.didEndTracking(self)
        if !continuous {
            sendActions(for: .valueChanged)
        }
    }

    private func startTransientTimerIfNeeded() {
        guard hapticConfiguration.kind.contains(.continuous) else { return }

        cancelTransientTimer()
        let timer = DispatchSource.makeTimerSource(queue: .main)
        timer.schedule(deadline: .now() + .milliseconds(750), repeating: .milliseconds(600))
        // A weak capture is required: an unowned one crashes if the slider is released mid-drag.
        timer.setEventHandler { [weak self] in
            MainActor.assumeIsolated {
                guard let self else { return }

                let (sharpness, intensity) = self.sharpnessAndIntensityAt(location: self.previousTouchPoint)
                try? self.hapticManager.playTransientHaptic(intensity: intensity, sharpness: sharpness)
            }
        }
        transientTimer = timer
        timer.resume()
    }

    private func playEndpointHapticIfNeeded(for candidate: CGFloat) {
        guard candidate != value else { return }

        if candidate == minimum {
            try? hapticManager.playTransientHaptic(intensity: hapticConfiguration.initialIntensity,
                                                   sharpness: hapticConfiguration.initialSharpness)
        } else if candidate == maximum {
            try? hapticManager.playTransientHaptic(intensity: 1, sharpness: 1)
        }
    }
}
