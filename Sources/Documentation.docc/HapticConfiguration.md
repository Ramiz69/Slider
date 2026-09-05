# ``Slider/HapticConfiguration``

## Overview

`HapticConfiguration` allows you to configure haptic feedback for various slider interactions. You can enable or disable haptic feedback when the slider reaches its limit values, when the value changes, or when the slider's direction changes.

## Topics

### Initialization

- ``init(reachLimitValueHapticEnabled:changeValueHapticEnabled:changeDirectionHapticEnabled:reachImpactGeneratorStyle:changeValueImpactGeneratorStyle:)``

### Haptic Feedback Generation

- ``reachValueGenerate()``
  Triggers haptic feedback when the slider reaches its minimum or maximum value.
- ``valueGenerate()``
  Triggers haptic feedback when the slider's value changes.
- ``directionGenerate()``
  Triggers haptic feedback when the slider's direction changes.

### Configuration Properties

- ``reachLimitValueHapticEnabled``
  A Boolean value that determines whether haptic feedback is enabled when reaching the slider's limit values.
- ``changeValueHapticEnabled``
  A Boolean value that determines whether haptic feedback is enabled when the slider's value changes.
- ``changeDirectionHapticEnabled``
  A Boolean value that determines whether haptic feedback is enabled when the slider's direction changes.

### Feedback Styles

- ``reachImpactGeneratorStyle``
  The style of haptic feedback generated when the slider reaches its limit values.
- ``changeValueImpactGeneratorStyle``
  The style of haptic feedback generated when the slider's value changes.

## Example Usage

```swift
let hapticConfig = HapticConfiguration(
    reachLimitValueHapticEnabled: true,
    changeValueHapticEnabled: true,
    changeDirectionHapticEnabled: true,
    reachImpactGeneratorStyle: .medium,
    changeValueImpactGeneratorStyle: .light
)
let slider = Slider()
slider.hapticConfiguration = hapticConfig
```
