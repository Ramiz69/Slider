# CHANGELOG

## [0.3.0] - 2026-09-05

### Added
- iOS 26 Liquid Glass appearance via the new `GlassConfiguration`. The material is used
  automatically on iOS 26 and later, and the slider silently keeps its flat look on earlier
  systems, so no availability checks are needed at the call site.
- `async` API: `setValue(_:animated:)` resumes once the animation finishes, `valueStream`
  exposes the value as an `AsyncStream`, and `prepareHaptics()` warms up the haptic engine.
- VoiceOver support: the slider is an adjustable accessibility element and reports its value.
- `allowsTapToSeek` moves the thumb to a tapped position on the track (off by default).
- `ThumbConfiguration.textColor` to override the automatically chosen label color.
- Right-to-left support. Horizontal directions follow the interface layout direction the way
  `UISlider` does; `resolvedDirection` reports the direction actually used, and
  `respectsLayoutDirection` opts out. Vertical directions are never mirrored.
- A test suite covering value clamping, geometry, memory, control events, right-to-left layout
  and the glass configuration, running inside the example app so control events are dispatched
  for real.

### Fixed
- `addTarget(_:action:for:)`, `removeTarget(_:action:for:)`, `addAction(_:for:)` and
  `removeAction(_:for:)` were overridden with empty bodies, so every registration was silently
  dropped and `.valueChanged` never reached its target. The overrides are gone.
- `delegate` was a strong reference and kept its owner alive; it is now `weak`.
- The haptic engine's `resetHandler` captured `self` strongly, so `HapticManager` and its
  `CHHapticEngine` were never released.
- The continuous-haptic timer captured `self` as `unowned` and was only cancelled when `step`
  was greater than zero, which crashed or vibrated forever after tracking ended.
- A `step` of `0` divided by zero during tracking and drove the value — and the layer
  geometry — to `NaN`.
- An empty range (`minimum == maximum`) produced `NaN` positions and could trip
  `CALayerInvalidGeometry`.
- Tracking that was cancelled by the system never released its display link or timer.
- `usableTrackingLength` used the wrong thumb dimension on the vertical axis, so values were
  off by the difference between the thumb's width and height.
- `continuous` was ignored: `.valueChanged` was sent on every move even when it was `false`.
- The delegate's `didContinueTracking(_:)` was declared but never called.
- Setting `delegate` measured the thumb's new width but applied the old size.
- Dynamic colors are now resolved against the current trait collection and refreshed when the
  interface style changes, so dark mode no longer keeps the light appearance.
- The thumb no longer plays a haptic while the slider is being created.
- The filled part of the track picked up an implicit Core Animation action and visibly trailed
  behind the thumb during fast drags.
- `UIScreen.main` is no longer used to resolve the content scale.
- Tap-to-seek only reacts to touches on the track, instead of anywhere in a slider that Auto
  Layout stretched beyond it.

### Removed
- CocoaPods support. The library is distributed through the Swift Package Manager only, so
  `RKSlider.podspec` and the vendored spec repository are gone. Consumers still on the
  `RKSlider` pod should stay on `0.2.1` or move to SPM.
- Objective-C support. The `Slider.h` umbrella header and the hand-written `Info.plist` are
  gone; the framework is Swift only.
- The pre-built DocC archives that were committed to the repository. The `Deploy DocC` workflow
  builds and publishes the documentation on every push to `master`.

### Changed
- The minimum deployment target is now iOS 18.0, which removes the compatibility branches the
  library carried for iOS 14 through 16.
- Assigning a value outside `minimum...maximum` now clamps it instead of stretching the range.
- The thumb has a minimum 44pt touch target.
- `previousTouchPoint` and `usableTrackingLength` are read-only from outside the module.
- `SliderDelegate` no longer requires conformers to be `Sendable`.
- The haptic engine is only rebuilt when its parameters change, not on every configuration
  assignment.


## [0.2.1] - 2025-01-06

### Added
- Support Swift 6.0

### Changed
- Rewrite Haptic Feedback from UIFeedbackGenerator to CoreHaptic 

## [0.2.0] - 2024-04-06

### Added
- Added vertical direction support (`bottomToTop`, `topToBottom`) for the slider, complementing the existing horizontal orientation.
- Implemented new `TrackConfiguration` and `ThumbConfiguration` structures to allow detailed customization of the slider's appearance and behavior.
- Developed and documented the `SliderDelegate` protocol and associated methods for handling slider events.
- Implemented a documentation system using DocC, providing detailed guides and usage examples for the `Slider` class.
- Added Swift-style documentation comments for all new and updated slider components.

### Changed
- Updated methods to enhance performance and reduce code duplication in the `Slider` class.
- Modified the animation mechanism for smoother thumb movement on value changes.
- Improved the system for updating and displaying the slider's visual components when its properties change.

### Fixed
- Fixed potential compatibility issues when changing the slider's direction.
- Addressed minor visual display issues in the slider identified during testing.

### Documentation
- Created and published comprehensive documentation covering all aspects of using, configuring, and integrating the slider into an application.

## [0.1.1] - 2024-03-17

### Changed
- Updated changelog

## [0.1.0] - 2024-03-17

### Added
- Added new configurations for direction-specific animations
- Refined animation transitions when changing directions for a more fluid user experience
- SliderDelegate now supports Swift Concurrency for asynchronous event handling

### Changed
- Rendering of changes is now synchronized with the GPU using CADisplayLink for smoother visual updates.
- Removed support for Interface Builder to streamline codebase and improve programmability.

## [0.0.9] - 2024-03-14

### Fixed
- Fixed podspec and SPM dependencies;

## [0.0.8] - 2024-03-14

### Added
- Added SPM support;

## [0.0.7] - 2024-03-14

### Added
- Added changelog.md

### Changed
- Removed IBDesignable support
- Replaced CAShapeLayer with CALayer for better rendering optimization

## [0.0.6] - 2022-09-29

### Changed
- Update podspec.

## [0.0.5] - 2022-09-29

### Added
- Added haptic generator

### Fixed
- Fixed the track layer
- Fixed iPad UI bugs

## [0.0.4] - 2021-01-15

### Added
- Added callbacks which allow you to listen to the slider's tracking events

## [0.0.3] - 2020-12-08

### Added
- Added examples.gif;

## [0.0.2] - 2020-03-31

### Added
- Added more examples;
- Added customization Slider;

### Changed
- Fold is removed when slider is dragging from minimum value to other value;

## [0.0.1] - 2020-01-05

### Added
- First stable release of the Slider
- Implemented functionality for a bidirectional Slider
