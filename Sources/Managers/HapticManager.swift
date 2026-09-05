//
//  HapticManager.swift
//  Slider
//
//  Created by Рамиз Кичибеков on 06.01.2025.
//  Copyright © 2025 Ramiz Kichibekov. All rights reserved.
//

import CoreHaptics
import OSLog

/// Wraps `CHHapticEngine` and keeps its lifecycle attached to the main actor.
///
/// The engine is created lazily on the first request so that a `Slider` that is never touched
/// never pays for the engine, and it is stopped in `deinit` to release the audio session.
@MainActor
final class HapticManager {

    // MARK: Properties

    let initialIntensity: Float
    let initialSharpness: Float
    let relativeTime: TimeInterval
    let duration: TimeInterval

    /// Whether the current hardware is able to play haptics at all.
    let supportsHaptics: Bool

    private var engine: CHHapticEngine?
    private var isEngineRunning = false

    // MARK: Initial methods

    init(
        initialIntensity: Float = 1,
        initialSharpness: Float = 0.5,
        relativeTime: TimeInterval = .zero,
        duration: TimeInterval = 100
    ) {
        self.initialIntensity = initialIntensity.clamped(to: 0...1)
        self.initialSharpness = initialSharpness.clamped(to: 0...1)
        self.relativeTime = relativeTime
        self.duration = duration
        self.supportsHaptics = CHHapticEngine.capabilitiesForHardware().supportsHaptics
        if !supportsHaptics {
            Logger.haptic.info("Haptics are not supported on this device")
        }
    }

    deinit {
        // `engine` is main-actor isolated, but stopping it from `deinit` is safe:
        // `CHHapticEngine` tears its own resources down when it is released.
        MainActor.assumeIsolated {
            engine?.stop(completionHandler: nil)
            engine = nil
        }
    }

    // MARK: Internal methods

    /// Creates and starts the engine ahead of the first haptic so the first tap is not delayed.
    func prepare() async {
        guard supportsHaptics else { return }

        do {
            try await start()
        } catch {
            Logger.haptic.error("Failed to prepare haptic engine: \(error.localizedDescription)")
        }
    }

    func start() async throws {
        guard supportsHaptics else { return }

        let engine = try resolveEngine()
        guard !isEngineRunning else { return }

        try await engine.start()
        isEngineRunning = true
    }

    func stop() async throws {
        guard supportsHaptics, let engine, isEngineRunning else { return }

        try await engine.stop()
        isEngineRunning = false
    }

    /// Plays a one-shot haptic. Starting the engine is retried once if the system stopped it in the background.
    func playTransientHaptic(intensity: Float, sharpness: Float) throws {
        guard supportsHaptics else { return }

        let engine = try resolveEngine()
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                        value: intensity.clamped(to: 0...1))
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                        value: sharpness.clamped(to: 0...1))
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensityParameter, sharpnessParameter],
                                  relativeTime: .zero)
        let pattern = try CHHapticPattern(events: [event], parameters: [])
        let player = try engine.makePlayer(with: pattern)
        if !isEngineRunning {
            try engine.start()
            isEngineRunning = true
        }
        try player.start(atTime: CHHapticTimeImmediate)
    }

    // MARK: Private methods

    private func resolveEngine() throws -> CHHapticEngine {
        if let engine {
            return engine
        }

        let engine = try CHHapticEngine()
        engine.playsHapticsOnly = true
        engine.isAutoShutdownEnabled = true
        // `resetHandler` and `stoppedHandler` are retained by the engine, which this object owns:
        // capturing `self` strongly here would create a cycle that keeps the engine alive forever.
        engine.resetHandler = { [weak self] in
            MainActor.assumeIsolated {
                guard let self else { return }

                self.isEngineRunning = false
                do {
                    try self.engine?.start()
                    self.isEngineRunning = true
                } catch {
                    Logger.haptic.error("Failed to restart haptic engine: \(error.localizedDescription)")
                }
            }
        }
        engine.stoppedHandler = { [weak self] reason in
            MainActor.assumeIsolated {
                Logger.haptic.info("Haptic engine stopped, reason: \(reason.rawValue)")
                self?.isEngineRunning = false
            }
        }
        self.engine = engine

        return engine
    }
}
