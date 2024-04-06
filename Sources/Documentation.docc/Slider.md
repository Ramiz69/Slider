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

### Delegate

- ``delegate``
  The delegate for the slider, conforming to `SliderDelegate`, to handle value changes and user interactions.

### User Interaction

- ``didBeginTracking()``
  Called when the user starts interacting with the slider.
- ``endTracking()``
  Called when the user finishes interacting with the slider.

### Visual Updates

- ``updateVisualComponents()``
  Updates the visual components of the slider, like the track and thumb, when certain properties change.
- ``setNeedsLayersDisplay()``
  Requests the layers to update their display based on the current slider properties.

### Layout and Positioning

- ``layoutSubviews()``
  Lays out subviews and updates the layout of the slider's components based on its current state and properties.
- ``position(forValue:)``
  Determines the position of the thumb based on the current slider value.

### Handling User Interactions

- ``updateSlider()``
  Updates the slider's value and visual appearance in response to user interactions.

## Example Usage

```swift
let slider = Slider()
slider.minimum = .zero
slider.maximum = 1000
slider.value = .zero
slider.step = 10
slider.delegate = self
```
