//
//  GoalStatusColors.swift
//  LastFast
//
//  Centralized color definitions for goal status indicators
//

import SwiftUI

// MARK: - Goal Status Colors

enum GoalStatusColors {
    /// Color for duration display based on goal status
    /// - Parameters:
    ///   - goalMet: Whether the goal has been met
    ///   - hasGoal: Whether a goal is set (defaults to true)
    /// - Returns: Green if goal met, orange if not met, primary if no goal
    static func durationColor(goalMet: Bool, hasGoal: Bool = true) -> Color {
        guard hasGoal else { return .primary }
        return goalMet ? .green : .orange
    }

    /// Color for goal status icon
    /// - Parameter goalMet: Whether the goal has been met
    /// - Returns: Green if goal met, red if not met
    static func iconColor(goalMet: Bool) -> Color {
        goalMet ? .green : .red
    }

    /// System name for goal status icon
    /// - Parameter goalMet: Whether the goal has been met
    /// - Returns: Checkmark circle if met, X circle if not
    static func iconSystemName(goalMet: Bool) -> String {
        goalMet ? "checkmark.circle.fill" : "xmark.circle.fill"
    }
}
