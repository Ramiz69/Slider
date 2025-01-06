//
//  HapticManager.swift
//  Slider
//
//  Created by Рамиз Кичибеков on 06.01.2025.
//  Copyright © 2025 Ramiz Kichibekov. All rights reserved.
//

import UIKit
import CoreHaptics
import OSLog

final class HapticManager: @unchecked Sendable {

    // MARK: Properties

    private let initialIntensity: Float
    private let initialSharpness: Float
    private let relativeTime: TimeInterval
    private let duration: TimeInterval
    private var engine: CHHapticEngine!
    private let supportsHaptics: Bool

    // MARK: Initial methods

    init(
        initialIntensity: Float = 1,
        initialSharpness: Float = 0.5,
        relativeTime: TimeInterval = .zero,
        duration: TimeInterval = 100
    ) {
        self.initialIntensity = initialIntensity
        self.initialSharpness = initialSharpness
        self.relativeTime = relativeTime
        self.duration = duration
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        guard supportsHaptics else {
            Logger.haptic.info("Haptics are not supported")
            return
        }

        do {
            try createAndStartHapticEngine()
            Task { try await startEngine() }
        } catch {
            Logger.haptic.error("Error creating haptic engine: \(error)")
        }
    }

    // MARK: Public methods

    func startEngine() async throws {
        guard supportsHaptics else { return }
        
        try await engine.start()
    }

    func stopEngine() async throws {
        guard supportsHaptics else { return }

        try await engine.stop()
    }

    func playTransientHaptic(intensity: Float, sharpness: Float) throws {
        guard supportsHaptics else { return }

        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity,
                                                        value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness,
                                                        value: sharpness)
        let event = CHHapticEvent(eventType: .hapticTransient,
                                  parameters: [intensityParameter, sharpnessParameter],
                                  relativeTime: .zero)
        let pattern = try CHHapticPattern(events: [event], parameters: [])

        let player = try engine.makePlayer(with: pattern)
        try player.start(atTime: CHHapticTimeImmediate)
    }

    // MARK: Private methods

    private func createAndStartHapticEngine() throws {
        engine = try CHHapticEngine()
        engine.playsHapticsOnly = true
        engine.resetHandler = {
            do {
                try self.engine.start()
            } catch {
                Logger.haptic.error("Failed to start haptic engine: \(error)")
            }
        }
    }
}
