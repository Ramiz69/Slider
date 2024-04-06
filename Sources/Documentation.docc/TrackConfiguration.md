# ``Slider/TrackConfiguration``

## Overview

`TrackConfiguration` defines the appearance settings for the track of the `Slider` control. It allows customization of the track's colors, height, and inset.

## Properties

- `maxColor`: The color used for the track's background. Default value is a light gray color.
- `minColor`: The color used for the portion of the track that represents values less than the slider's current value. Default value is the system blue color.
- `reverseMinColor`: The color used for the portion of the track that represents values greater than the slider's current value when the slider's direction is reversed. Default value is a red color.
- `height`: The height of the track. Default value is `36`.
- `inset`: The inset of the track within the slider's bounds. Default value is `0`, which means the track will extend the full width/height of the slider.

## Initialization

### ``init(maxColor:minColor:reverseMinColor:height:inset:)``

Initializes a `TrackConfiguration` instance with specified colors, height, and inset.

- Parameters:
  - `maxColor`: The color for the track's background.
  - `minColor`: The color for the track segment representing values below the slider's current value.
  - `reverseMinColor`: The color for the track segment representing values above the slider's current value in a reversed direction.
  - `height`: The height of the track.
  - `inset`: The inset for the track within the slider's bounds.

## Example Usage

```swift
let trackConfig = TrackConfiguration(maxColor: UIColor.lightGray,
                                     minColor: UIColor.blue,
                                     reverseMinColor: UIColor.red,
                                     height: 20,
                                     inset: 2)
let slider = Slider()
slider.trackConfiguration = trackConfig
```
