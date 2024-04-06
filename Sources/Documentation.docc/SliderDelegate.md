# ``Slider/SliderDelegate``

## Overview

`SliderDelegate` defines a set of methods that you can use to respond to various slider events and to customize the text displayed for the slider's value. It's marked with `@MainActor` to ensure that all protocol methods are executed on the main thread, which is crucial for UI updates. The protocol provides default implementations for tracking methods, so you only need to implement `slider(_:displayTextForValue:)` and any tracking methods you're interested in.

## Topics

### Required Methods

- ``slider(_:displayTextForValue:)``
  Asks the delegate for the display text for a specific value of the slider. Implement this method to return a customized text representation of the slider's value.

### Optional Methods

The following methods have default empty implementations, making them optional:

- ``didBeginTracking(_:)``
  Tells the delegate that the user has started interacting with the slider. Override this method to respond to the beginning of the user's tracking action.
- ``didContinueTracking(_:)``
  Informs the delegate that the user is continuing to move the slider. Override this method to track changes as the user drags the slider.
- ``didEndTracking(_:)``
  Notifies the delegate that the user has finished interacting with the slider. Override this method to perform any final actions when the user completes the tracking.

## Example Usage

```swift
extension YourViewController: SliderDelegate {
    public func slider(_ slider: Slider, displayTextForValue value: CGFloat) -> String {
        // Return a string representation of the value
        return String(format: "%.2f", value)
    }

    public func didBeginTracking(_ slider: Slider) {
        // Respond to the start of tracking
        print("Started tracking slider.")
    }

    // No need to override didContinueTracking and didEndTracking unless you need specific behavior.
}
```
