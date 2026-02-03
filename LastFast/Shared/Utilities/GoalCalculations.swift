//
//  GoalCalculations.swift
//  LastFast
//
//  Shared calculation functions for goal-related logic
//

import Foundation

// MARK: - Goal Validation

/// Validates if the goal is valid based on the mode and values
/// - Parameters:
///   - mode: The goal mode (duration or endTime)
///   - selectedHours: Hours selected in duration mode
///   - selectedMinutes: Minutes selected in duration mode
///   - minutesUntilEndTime: Minutes until end time in end time mode
/// - Returns: True if the goal is valid
func isGoalValid(
    mode: GoalMode,
    selectedHours: Int,
    selectedMinutes: Int,
    minutesUntilEndTime: Int
) -> Bool {
    switch mode {
    case .duration:
        return selectedHours > 0 || selectedMinutes > 0
    case .endTime:
        return minutesUntilEndTime > 0
    }
}

/// Calculates the minutes until a given end time
/// - Parameter endTime: The target end time
/// - Returns: Minutes until end time, clamped to 0 if in the past
func calculateMinutesUntilEndTime(_ endTime: Date) -> Int {
    let interval = endTime.timeIntervalSince(Date())
    return max(0, Int(interval / 60))
}

/// Computes the total goal minutes based on mode and values
/// - Parameters:
///   - mode: The goal mode
///   - selectedHours: Hours in duration mode
///   - selectedMinutes: Minutes in duration mode
///   - minutesUntilEndTime: Minutes in end time mode
/// - Returns: Total goal in minutes
func computeGoalMinutes(
    mode: GoalMode,
    selectedHours: Int,
    selectedMinutes: Int,
    minutesUntilEndTime: Int
) -> Int {
    switch mode {
    case .duration:
        return selectedHours * 60 + selectedMinutes
    case .endTime:
        return minutesUntilEndTime
    }
}

// MARK: - Fasting Progress Calculations

/// Calculates the remaining minutes until goal is met
/// - Parameters:
///   - currentDuration: Current elapsed duration in seconds
///   - goalMinutes: Goal in minutes (nil if no goal)
/// - Returns: Remaining minutes, clamped to 0
func calculateRemainingMinutes(currentDuration: TimeInterval, goalMinutes: Int?) -> Int {
    guard let goal = goalMinutes else { return 0 }
    let elapsedMinutes = Int(currentDuration) / 60
    return max(0, goal - elapsedMinutes)
}

/// Checks if the fasting goal has been met
/// - Parameters:
///   - currentDuration: Current elapsed duration in seconds
///   - goalMinutes: Goal in minutes (nil if no goal)
/// - Returns: True if goal is met
func isGoalMet(currentDuration: TimeInterval, goalMinutes: Int?) -> Bool {
    guard let goal = goalMinutes else { return false }
    return Int(currentDuration) / 60 >= goal
}

/// Calculates the progress towards the goal (0.0 to 1.0)
/// - Parameters:
///   - currentDuration: Current elapsed duration in seconds
///   - goalMinutes: Goal in minutes (nil or 0 returns 0)
/// - Returns: Progress value capped at 1.0
func calculateProgress(currentDuration: TimeInterval, goalMinutes: Int?) -> Double {
    guard let goal = goalMinutes, goal > 0 else { return 0 }
    return min(1.0, (currentDuration / 60) / Double(goal))
}

// MARK: - Time Component Extraction

/// Extracts hours from remaining minutes
/// - Parameter remainingMinutes: Total remaining minutes
/// - Returns: Hours component
func hoursFromMinutes(_ remainingMinutes: Int) -> Int {
    remainingMinutes / 60
}

/// Extracts minutes component from remaining minutes
/// - Parameter remainingMinutes: Total remaining minutes
/// - Returns: Minutes component (0-59)
func minutesComponent(_ remainingMinutes: Int) -> Int {
    remainingMinutes % 60
}

/// Extracts elapsed hours from duration
/// - Parameter duration: Duration in seconds
/// - Returns: Elapsed hours
func elapsedHours(from duration: TimeInterval) -> Int {
    Int(duration) / 3600
}

/// Extracts elapsed minutes component from duration
/// - Parameter duration: Duration in seconds
/// - Returns: Elapsed minutes (0-59)
func elapsedMinutesComponent(from duration: TimeInterval) -> Int {
    (Int(duration) % 3600) / 60
}
