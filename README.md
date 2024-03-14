# Slider

[![Build Status](https://github.com/Ramiz69/Slider/workflows/Slider%20CI/badge.svg?branch=master)](https://github.com/Ramiz69/Slider/actions)
[![Version](https://img.shields.io/cocoapods/v/RKSlider.svg?style=flat)](https://cocoapods.org/pods/RKSlider)
[![License](https://img.shields.io/cocoapods/l/RKSlider.svg?style=flat)](https://cocoapods.org/pods/RKSlider)
[![Platform](https://img.shields.io/cocoapods/p/RKSlider.svg?style=flat)](https://cocoapods.org/pods/RKSlider)

- [Installation](#installation)
- [Author](#author)
- [License](#license)

## Requirements

- iOS 14.0+
- Xcode 11.3+
- Swift 5+

## Preview
<img src="https://github.com/Ramiz69/Slider/blob/master/example.gif" width="200" height="400">

## Installation

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding Slider as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift` or the Package list in Xcode.

```swift
dependencies: [
    .package(url: "https://github.com/Ramiz69/Slider.git", .upToNextMajor(from: "0.0.9"))
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

### Usage

#### code
- init Slider with frame or use Auto Layout
- add a view to your superview

## Author

ramiz69, ramiz161@icloud.com

## License

Slider is available under the MIT license. [See LICENSE](https://github.com/Ramiz69/Slider/blob/master/LICENSE) for details.
