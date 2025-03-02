//
//  LoggerManager.swift
//  Slider
//
//  Created by Рамиз Кичибеков on 06.01.2025.
//  Copyright © 2025 Ramiz Kichibekov. All rights reserved.
//

import Foundation
import OSLog

extension Logger {
    private static let subsystem: String = "Slider"

    static let haptic = Logger(subsystem: subsystem, category: "haptic_feedback")
}
