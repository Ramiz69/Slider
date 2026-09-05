# ``Slider/GlassConfiguration``

## Overview

Describes how the slider adopts the iOS 26 Liquid Glass material. On earlier systems the
configuration is inert and the slider keeps its classic flat appearance, so the same
configuration can be shipped to every deployment target without availability checks.

The thumb is rendered with `UIGlassEffect` inside a `UIGlassContainerEffect`, which lets it
refract the track underneath and merge with neighbouring glass as it approaches the ends.

## Topics

### Initialization

- ``init(mode:style:isInteractive:tintsThumbWithTrackColor:tintColor:appliesToTrack:containerSpacing:)``

### Configuration

- ``Mode``
  Whether the glass material is used at all.
- ``Style``
  The material style: `regular` or `clear`.
- ``mode``
- ``style``
- ``isInteractive``
  Whether the thumb animates the material while it is dragged.
- ``tintsThumbWithTrackColor``
  Whether the thumb inherits the current track fill color.
- ``tintColor``
  An explicit tint that overrides ``tintsThumbWithTrackColor``.
- ``appliesToTrack``
  Whether the track background also becomes glass. The filled part stays opaque so the value
  remains readable.
- ``containerSpacing``
  The distance at which neighbouring glass elements start to merge.

### Availability

- ``isSupportedByPlatform``
  Whether the running system provides the material.
- ``isEffective``
  Whether this configuration results in a glass appearance right now.

## Example Usage

```swift
let slider = Slider()

// Glass on iOS 26+, the flat appearance on older systems.
slider.glassConfiguration = GlassConfiguration(style: .clear,
                                               isInteractive: true,
                                               appliesToTrack: true)

// Opt out entirely.
slider.glassConfiguration = GlassConfiguration(mode: .disabled)
```
