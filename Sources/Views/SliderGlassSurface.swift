//
//  SliderGlassSurface.swift
//  Slider
//
//  Copyright © 2026 Ramiz Kichibekov. All rights reserved.
//

import UIKit

/// Hosts the iOS 26 Liquid Glass materials used by ``Slider``.
///
/// The surface is always installed but stays completely inert on systems that do not provide
/// `UIGlassEffect`, which keeps the call sites in ``Slider`` free of availability branches.
/// Hit testing is disabled so the surface never intercepts touches meant for the control.
@MainActor
final class SliderGlassSurface: UIView {

    // MARK: Properties

    /// Whether the surface is currently rendering glass.
    private(set) var isActive = false

    /// The layer that hosts the thumb's text while the glass material is active.
    var thumbContentLayer: CALayer? { thumbEffectView?.contentView.layer }

    private var containerEffectView: UIVisualEffectView?
    private var thumbEffectView: UIVisualEffectView?
    private var trackEffectView: UIVisualEffectView?
    private var configuration = GlassConfiguration()

    // MARK: Initial methods

    init() {
        super.init(frame: .zero)

        isUserInteractionEnabled = false
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()

        containerEffectView?.frame = bounds
    }

    /// The surface is purely decorative; touches always fall through to the control.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { nil }

    // MARK: Internal methods

    /// Installs or removes the glass materials to match `configuration`.
    /// - Returns: `true` when the active state changed and the caller has to re-parent the thumb layer.
    @discardableResult
    func apply(_ configuration: GlassConfiguration) -> Bool {
        self.configuration = configuration
        let shouldBeActive = configuration.isEffective
        guard shouldBeActive != isActive else {
            if isActive {
                refreshEffects()
            }

            return false
        }

        isActive = shouldBeActive
        if shouldBeActive {
            installEffects()
        } else {
            removeEffects()
        }

        return true
    }

    /// Re-applies style, tint and interactivity without rebuilding the views.
    func refreshEffects() {
        guard #available(iOS 26.0, *), isActive else { return }

        if let containerEffect = containerEffectView?.effect as? UIGlassContainerEffect {
            containerEffect.spacing = configuration.containerSpacing
            containerEffectView?.effect = containerEffect
        }
        if let thumbEffectView {
            let effect = UIGlassEffect(style: configuration.style.uiGlassStyle)
            effect.isInteractive = configuration.isInteractive
            effect.tintColor = configuration.tintColor
            thumbEffectView.effect = effect
        }
        updateTrackEffectPresence()
    }

    /// Applies the resolved tint for the thumb material.
    func updateThumbTint(_ color: UIColor?) {
        guard #available(iOS 26.0, *), isActive, let thumbEffectView else { return }

        let effect = UIGlassEffect(style: configuration.style.uiGlassStyle)
        effect.isInteractive = configuration.isInteractive
        effect.tintColor = configuration.tintColor ?? color
        thumbEffectView.effect = effect
    }

    /// Moves and resizes the glass thumb.
    func updateThumb(center: CGPoint, size: CGSize, cornerRadius: CGFloat) {
        guard isActive, let thumbEffectView else { return }

        thumbEffectView.bounds = CGRect(origin: .zero, size: size)
        thumbEffectView.center = center
        applyCornerRadius(cornerRadius, to: thumbEffectView, size: size)
    }

    /// Moves and resizes the optional glass track backing.
    func updateTrack(frame: CGRect, cornerRadius: CGFloat) {
        guard isActive, let trackEffectView else { return }

        trackEffectView.frame = frame
        applyCornerRadius(cornerRadius, to: trackEffectView, size: frame.size)
    }

    /// Runs `body` inside the interactive glass animation when one is available.
    func animate(_ body: @escaping () -> Void, completion: (() -> Void)? = nil) {
        guard #available(iOS 26.0, *), isActive else {
            body()
            completion?()

            return
        }

        UIView.animate(springDuration: 0.4,
                       bounce: 0.15,
                       animations: body,
                       completion: { _ in completion?() })
    }

    // MARK: Private methods

    private func installEffects() {
        guard #available(iOS 26.0, *) else { return }

        let containerEffect = UIGlassContainerEffect()
        containerEffect.spacing = configuration.containerSpacing
        let container = UIVisualEffectView(effect: containerEffect)
        container.frame = bounds
        container.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(container)
        containerEffectView = container

        let thumbEffect = UIGlassEffect(style: configuration.style.uiGlassStyle)
        thumbEffect.isInteractive = configuration.isInteractive
        thumbEffect.tintColor = configuration.tintColor
        let thumb = UIVisualEffectView(effect: thumbEffect)
        container.contentView.addSubview(thumb)
        thumbEffectView = thumb

        updateTrackEffectPresence()
    }

    private func updateTrackEffectPresence() {
        guard #available(iOS 26.0, *), let containerEffectView else { return }

        if configuration.appliesToTrack {
            guard trackEffectView == nil else { return }

            let effect = UIGlassEffect(style: .clear)
            effect.isInteractive = false
            let track = UIVisualEffectView(effect: effect)
            // The track sits below the thumb so the thumb keeps merging over it.
            containerEffectView.contentView.insertSubview(track, at: .zero)
            trackEffectView = track
        } else {
            trackEffectView?.removeFromSuperview()
            trackEffectView = nil
        }
    }

    private func removeEffects() {
        trackEffectView?.removeFromSuperview()
        trackEffectView = nil
        thumbEffectView?.removeFromSuperview()
        thumbEffectView = nil
        containerEffectView?.removeFromSuperview()
        containerEffectView = nil
    }

    private func applyCornerRadius(_ radius: CGFloat, to view: UIView, size: CGSize) {
        guard #available(iOS 26.0, *) else { return }

        // A capsule keeps the material concentric with the track while the thumb resizes.
        if radius >= min(size.width, size.height) / 2 {
            view.cornerConfiguration = .capsule()
        } else {
            view.cornerConfiguration = .corners(radius: .fixed(radius))
        }
    }
}
