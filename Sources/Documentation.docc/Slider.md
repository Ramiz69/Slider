# ``Slider/Slider``

## Overview

An open class that extends `UIControl` to create a customizable slider component. It allows setting various properties to control the appearance and behavior of the slider, including its value range, direction, thumb and track configurations, and haptic feedback for user interactions.

## Topics

### Initialization

- ``init(direction:frame:)``
  Initializes a new slider with the specified direction and frame.
- ``init(frame:)``
  Initializes a new slider with the specified frame.

### Customization Properties

- ``value``
  The current value of the slider. Changing this value updates the slider's visual representation.
- ``minimum``
  The minimum value of the slider. It defaults to `10`.
- ``maximum``
  The maximum value of the slider. It defaults to `800`.
- ``step``
  The step value of the slider. It determines the increments between values.
- ``cornerRadius``
  The corner radius for the slider's track and thumb.
- ``thumbConfiguration``
  Configuration for the slider's thumb, including its size, color, and other properties.
- ``trackConfiguration``
  Configuration for the slider's track, defining its appearance and behavior.
- ``maximumEndpointConfiguration``
  Configuration for the maximum endpoint label of the slider.
- ``minimumEndpointConfiguration``
  Configuration for the minimum endpoint label of the slider.
- ``hapticConfiguration``
  Configuration for haptic feedback during user interactions with the slider.

### Direction and Animation

- ``Direction``
  An enumeration that defines the slider's orientation and direction.
- ``AnimationStyle``
  An enumeration that defines the animation style when the slider value changes.
- ``animationStyle``
  The animation style used when the direction or the value changes.

### Appearance

- ``glassConfiguration``
  Controls the iOS 26 Liquid Glass appearance. Glass is used automatically where the platform
  provides it, and the flat appearance is kept everywhere else.

### Delegate

- ``delegate``
  The delegate for the slider, conforming to `SliderDelegate`, to handle value changes and user
  interactions. The reference is weak.

### User Interaction

- ``continuous``
  Whether `.valueChanged` is sent while dragging, or only once tracking ends.
- ``allowsTapToSeek``
  Whether tapping the track moves the thumb to that position.
- ``previousTouchPoint``
  The last touch location observed during tracking.
- ``usableTrackingLength``
  The length of the track along which the thumb can move.
- ``respectsLayoutDirection``
  Whether horizontal directions are mirrored in a right-to-left interface.
- ``resolvedDirection``
  The direction the slider is actually laid out in, after mirroring.

### Asynchronous API

- ``setValue(_:animated:)``
  Assigns a new value and resumes once the animation has finished.
- ``valueStream``
  An `AsyncStream` of the slider's values.
- ``prepareHaptics()``
  Warms up the haptic engine so the first interaction is not delayed.

## Example Usage

```swift
let slider = Slider()
slider.minimum = .zero
slider.maximum = 1000
slider.value = .zero
slider.step = 10
slider.delegate = self

// Liquid Glass on iOS 26, the flat appearance elsewhere — no availability check needed.
slider.glassConfiguration = GlassConfiguration(style: .regular)

await slider.setValue(500, animated: true)
```
