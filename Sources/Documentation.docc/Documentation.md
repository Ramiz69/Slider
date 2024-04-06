# ``Slider``

@Metadata {
    @DisplayName("Slider")
    @SupportedLanguage(swift)
    @Available(iOS, introduced: "14.0")
    @Available(iPadOS, introduced: "14.0")
    @Available(MacCatalyst, introduced: "14.0")
    @Available("Slider", introduced: "0.2.0")
    @PageColor(green)
}

## Overview

`Slider` is a customizable slider control for iOS, implemented in Swift. It supports horizontal and vertical orientations and offers a range of customization options to change its appearance and behavior.

## Features

- Supports horizontal (`leftToRight`, `rightToLeft`) and vertical (`bottomToTop`, `topToBottom`) orientations.
- Customizable thumb and track appearance.
- Optional minimum and maximum value labels.
- Haptic feedback support.
- Customizable step intervals.
- Continuous and discrete value changes.

## Topics

### Initialization

- ``Slider/init(frame:)``
  Initializes and returns a newly allocated slider object with the specified frame rectangle and `leftToRight` direction.
- ``Slider/init(direction:frame:)``
  Initializes and returns a newly allocated slider object with the specified direction.

### Configuring the Slider's Appearance

- ``Slider/TrackConfiguration``
  Configures the appearance of the slider's track.
- ``Slider/ThumbConfiguration``
  Configures the appearance of the slider's thumb.
- ``Slider/RangeEndpointsConfiguration``
  Configures the appearance of the label displayed at the maximum value end of the slider.
- ``Slider/RangeEndpointsConfiguration``
  Configures the appearance of the label displayed at the minimum value end of the slider.

### Managing the Slider's Value

- ``Slider/value``
  The current value of the slider.
- ``Slider/minimum``
  The minimum value of the slider.
- ``Slider/maximum``
  The maximum value of the slider.
- ``Slider/step``
  The step value of the slider.

### Responding to Slider Value Changes

- Implement `SliderDelegate` to respond to changes in the slider's value.

### Customizing Behavior and Appearance

- ``Slider/direction``
  Sets the slider's orientation to horizontal or vertical.
- ``Slider/animationStyle``
  Configures the animation style used when the slider value changes.
- ``Slider/cornerRadius``
  Sets the corner radius for the slider's track and thumb.

### Haptic Feedback

- ``Slider/HapticConfiguration``
  Configures the haptic feedback for the slider.

## Requirements

- iOS 14.0+
- Swift 5.10+

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Slider as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/Ramiz69/Slider.git", .upToNextMajor(from: "0.1.0"))
]
```

Normally you'll want to depend on the `Slider` target:

```swift
.product(name: "Slider", package: "Slider")
```

### CocoaPods

[CocoaPods](https://cocoapods.org) is a dependency manager for Cocoa projects. For usage and installation instructions, visit their website. To integrate Slider into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'RKSlider'
```

### Manually
copy `Slider.swift` to your project

## Author

ramiz69, ramiz161@icloud.com [Github](https://github.com/ramiz69)

## License

`Slider` is available under the MIT license. [See LICENSE](https://github.com/Ramiz69/Slider/blob/master/LICENSE) for details.
