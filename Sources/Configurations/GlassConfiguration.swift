//
//  GlassConfiguration.swift
//  Slider
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import UIKit

/// Describes how the slider adopts the iOS 26 Liquid Glass material.
///
/// On systems older than iOS 26 the configuration is inert and the slider keeps its classic
/// flat appearance, so the same configuration can be shipped to every deployment target.
public struct GlassConfiguration: Sendable, Equatable {

    /// Controls when the glass material is used.
    public enum Mode: Sendable, Equatable {
        /// Use Liquid Glass when the platform provides it, otherwise fall back to the flat appearance.
        case automatic
        /// Never use Liquid Glass, even on iOS 26 and later.
        case disabled
    }

    /// Mirrors `UIGlassEffect.Style` without requiring the iOS 26 SDK at the call site.
    public enum Style: Sendable, Equatable {
        /// The standard material, legible over arbitrary content.
        case regular
        /// A clearer material that lets more of the underlying content through.
        case clear
    }

    /// Whether the glass material should be used. Defaults to `.automatic`.
    public var mode: Mode

    /// The material style applied to the thumb. Defaults to `.regular`.
    public var style: Style

    /// Whether the thumb reacts to touches with the interactive glass animation. Defaults to `true`.
    public var isInteractive: Bool

    /// Tints the glass thumb with the current track fill color so the control keeps its identity.
    ///
    /// Set to `false` to leave the material untinted, or use ``tintColor`` for a custom tint.
    public var tintsThumbWithTrackColor: Bool

    /// An explicit tint for the glass thumb. When `nil`, ``tintsThumbWithTrackColor`` decides the tint.
    public var tintColor: UIColor?

    /// Applies the glass material to the track background as well as the thumb. Defaults to `false`.
    ///
    /// The filled part of the track always stays opaque so the current value remains readable.
    public var appliesToTrack: Bool

    /// The distance at which neighbouring glass elements start to merge, in points. Defaults to `12`.
    public var containerSpacing: CGFloat

    /// Whether the glass material is available on the running system.
    public static var isSupportedByPlatform: Bool {
        if #available(iOS 26.0, *) {
            return true
        } else {
            return false
        }
    }

    /// Whether this configuration results in a glass appearance on the running system.
    public var isEffective: Bool {
        mode == .automatic && Self.isSupportedByPlatform
    }

    /// Creates a Liquid Glass configuration.
    /// - Parameters:
    ///   - mode: When the glass material is used. Defaults to `.automatic`.
    ///   - style: The material style. Defaults to `.regular`.
    ///   - isInteractive: Whether the thumb animates the material while dragged. Defaults to `true`.
    ///   - tintsThumbWithTrackColor: Whether the thumb inherits the track fill color. Defaults to `true`.
    ///   - tintColor: An explicit tint that overrides `tintsThumbWithTrackColor`. Defaults to `nil`.
    ///   - appliesToTrack: Whether the track background also becomes glass. Defaults to `false`.
    ///   - containerSpacing: Merge distance between glass elements. Defaults to `12`.
    public init(mode: Mode = .automatic,
                style: Style = .regular,
                isInteractive: Bool = true,
                tintsThumbWithTrackColor: Bool = true,
                tintColor: UIColor? = nil,
                appliesToTrack: Bool = false,
                containerSpacing: CGFloat = 12) {
        self.mode = mode
        self.style = style
        self.isInteractive = isInteractive
        self.tintsThumbWithTrackColor = tintsThumbWithTrackColor
        self.tintColor = tintColor
        self.appliesToTrack = appliesToTrack
        self.containerSpacing = containerSpacing
    }
}

@available(iOS 26.0, *)
extension GlassConfiguration.Style {
    var uiGlassStyle: UIGlassEffect.Style {
        switch self {
        case .regular: .regular
        case .clear: .clear
        }
    }
}
