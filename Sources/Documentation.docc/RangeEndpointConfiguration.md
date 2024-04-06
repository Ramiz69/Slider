# ``Slider/RangeEndpointsConfiguration``

## Overview

`RangeEndpointsConfiguration` defines the appearance and positioning of the text labels at the minimum and maximum ends of the `Slider`. It allows customization of the anchor point, text color, font size, and text alignment.

## Topics

### Initialization

- ``init(anchorPoint:foregroundColor:fontSize:aligmentMode:)``

### Configuration Options

- ``anchorPoint``
  The anchor point for the text layer of the endpoint label. Defaults to the center of the layer.
- ``foregroundColor``
  The color used for the endpoint text. Defaults to white.
- ``fontSize``
  The font size of the endpoint text. Defaults to `12`.
- ``aligmentMode``
  The alignment of the text within the text layer. Defaults to `.center`.

## Example Usage

```swift
let endpointsConfig = RangeEndpointsConfiguration(
    anchorPoint: CGPoint(x: 0.5, y: 0.5),
    foregroundColor: UIColor.white.cgColor,
    fontSize: 14,
    aligmentMode: .left
)
let slider = Slider()
slider.minimumEndpointConfiguration = endpointsConfig
slider.maximumEndpointConfiguration = endpointsConfig
```
