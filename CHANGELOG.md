# CHANGELOG

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
