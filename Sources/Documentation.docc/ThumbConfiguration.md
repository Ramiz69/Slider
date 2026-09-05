# ``Slider/ThumbConfiguration``

## Overview

Use `ThumbConfiguration` to define the appearance of the slider's thumb. This structure provides customization options for the thumb's background color, font size, physical size, and border width.

## Topics

### Initialization

- ``init(backgroundColor:fontSize:size:borderWidth:textColor:)``

### Customization Options

- ``backgroundColor``
  The background color of the thumb. Defaults to `.white`.
- ``fontSize``
  The font size used for any text within the thumb. Defaults to `14`.
- ``size``
  The size of the thumb, specified as a `CGSize`. Defaults to `(width: 60, height: 36)`.
- ``borderWidth``
  The width of the thumb's border. Defaults to `4`.
- ``textColor``
  The label color. When `nil` the slider picks one itself: the track fill color for the flat
  appearance, and a color with enough contrast against the material for Liquid Glass.

## Example Usage

```swift
let thumbConfig = ThumbConfiguration(backgroundColor: .lightGray,
                                     fontSize: 12,
                                     size: CGSize(width: 50, height: 30),
                                     borderWidth: 2)
let slider = Slider()
slider.thumbConfiguration = thumbConfig
```
