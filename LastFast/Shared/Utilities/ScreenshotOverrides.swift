//
//  ScreenshotOverrides.swift
//  LastFast
//
//  Override values for capturing marketing screenshots.
//  These overrides are ONLY available in DEBUG builds.
//

import Foundation

// MARK: - Screenshot Configuration

/// Configure these values to override the fasting display for marketing screenshots.
/// Set `screenshotOverridesEnabled` to `true` to activate overrides.
///
/// SAFETY: These overrides are automatically disabled in Release builds
/// via the `#if DEBUG` compiler directive.

#if DEBUG

/// Master switch to enable/disable all screenshot overrides
let screenshotOverridesEnabled = false

/// Override the fasting goal duration (in minutes)
/// Example: 960 = 16 hours, 1080 = 18 hours
let screenshotGoalMinutes: Int? = 960

/// Override the fast start time
/// Example: (7, 0) = 7:00 AM, (19, 0) = 7:00 PM
/// xcrun simctl status_bar booted override --time "19:10"
let screenshotStartTime: (hour: Int, minute: Int)? = (19,10)

/// Override the "current time" used to calculate elapsed duration and progress
/// Example: (7, 0) = 7:00 AM, (15, 30) = 3:30 PM
/// xcrun simctl status_bar booted override --time "11:10"
let screenshotCurrentTime: (hour: Int, minute: Int)? = (7,10)

#else

let screenshotOverridesEnabled = false
let screenshotGoalMinutes: Int? = nil
let screenshotStartTime: (hour: Int, minute: Int)? = nil
let screenshotCurrentTime: (hour: Int, minute: Int)? = nil

#endif

// MARK: - Override Helpers

/// Returns the effective start time, applying screenshot override if enabled
/// Handles overnight fasts: if start time > current time, assumes start was yesterday
func effectiveStartTime(_ originalStartTime: Date) -> Date {
    guard screenshotOverridesEnabled, let time = screenshotStartTime else {
        return originalStartTime
    }

    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.hour = time.hour
    components.minute = time.minute
    components.second = 0

    guard var startDate = calendar.date(from: components) else {
        return originalStartTime
    }

    // If start time is after current time, it must be from yesterday
    let currentTime = effectiveCurrentTime()
    if startDate > currentTime {
        startDate = calendar.date(byAdding: .day, value: -1, to: startDate) ?? startDate
    }

    return startDate
}

/// Returns the effective "current time", applying screenshot override if enabled
func effectiveCurrentTime() -> Date {
    guard screenshotOverridesEnabled, let time = screenshotCurrentTime else {
        return Date()
    }

    let calendar = Calendar.current
    var components = calendar.dateComponents([.year, .month, .day], from: Date())
    components.hour = time.hour
    components.minute = time.minute
    components.second = 0

    return calendar.date(from: components) ?? Date()
}

/// Returns the effective goal minutes, applying screenshot override if enabled
func effectiveGoalMinutes(_ originalGoal: Int?) -> Int? {
    guard screenshotOverridesEnabled, let override = screenshotGoalMinutes else {
        return originalGoal
    }
    return override
}

/// Returns the effective end time, calculated from start time + goal minutes
func effectiveEndTime(startTime: Date, goalMinutes: Int?) -> Date? {
    guard let goal = goalMinutes else { return nil }
    return startTime.addingTimeInterval(TimeInterval(goal * 60))
}
