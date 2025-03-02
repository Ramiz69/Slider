//
//  HapticConfiguration.swift
//  Slider
//
//  Created by Рамиз Кичибеков on 06.01.2025.
//  Copyright © 2025 Ramiz Kichibekov. All rights reserved.
//

import Foundation

/// A structure describing the configuration for haptic feedback.
public struct HapticConfiguration {

    // MARK: Properties

    /// An option set that defines the type(s) of haptic feedback.
    ///
    /// **Available cases:**
    /// - `transient`: A short, impulse-like haptic.
    /// - `continuous`: A continuous haptic.
    public struct Kind: OptionSet, Sendable {
        public typealias RawValue = UInt8

        public var rawValue: UInt8

        nonisolated public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let transient = Kind(rawValue: 1 << 0)
        public static let continuous = Kind(rawValue: 1 << 1)
    }
    /// The type(s) of haptic feedback (see `Kind`).
    let kind: Kind

    /// The initial intensity of the haptic feedback, in the range [0, 1].
    let initialIntensity: Float

    /// The initial sharpness of the haptic feedback, in the range [0, 1].
    let initialSharpness: Float

    /// A relative time (such as a delay) before the haptic feedback begins.
    let relativeTime: TimeInterval

    /// The total duration of the haptic feedback, relevant for continuous types.
    let duration: TimeInterval

    // MARK: Initial methods

    /**
     Creates a new `HapticConfiguration`.

     - Parameters:
      - kind: The type(s) of haptic feedback. Defaults to `[.transient, .continuous]`.
      - initialIntensity: The initial intensity of the haptic (0 to 1). Defaults to `1`.
      - initialSharpness: The initial sharpness of the haptic (0 to 1). Defaults to `0.5`.
      - relativeTime: The relative time or delay before the haptic feedback starts. Defaults to `.zero`.
      - duration: The duration of the haptic feedback, mainly for continuous types. Defaults to `100`.
     */
    public init(
        kind: Kind = [.transient, .continuous],
        initialIntensity: Float = 1,
        initialSharpness: Float = 0.5,
        relativeTime: TimeInterval = .zero,
        duration: TimeInterval = 100
    ) {
        self.kind = kind
        self.initialIntensity = initialIntensity
        self.initialSharpness = initialSharpness
        self.relativeTime = relativeTime
        self.duration = duration
    }
}
