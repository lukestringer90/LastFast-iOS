//
//  DurationFormatting.swift
//  LastFast
//
//  Helper functions for formatting durations and times
//

import Foundation

// MARK: - Time Formatting

/// Cached DateFormatter for 24-hour time (HH:mm)
private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
}()

/// Formats a date as 24-hour time (HH:mm)
/// - Parameter date: The date to format
/// - Returns: Formatted string like "08:30" or "14:45"
func format24HourTime(_ date: Date) -> String {
    timeFormatter.string(from: date)
}

// MARK: - Duration Formatting

/// Formats hours and minutes into a readable string
/// - Parameters:
///   - hours: Number of hours
///   - minutes: Number of minutes
/// - Returns: Formatted string like "8h 30m", "8h", or "30m"
func formatDuration(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

/// Formats a TimeInterval into hours and minutes
/// - Parameter interval: Time interval in seconds
/// - Returns: Tuple of (hours, minutes)
func hoursAndMinutes(from interval: TimeInterval) -> (hours: Int, minutes: Int) {
    let totalSeconds = Int(interval)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    return (hours, minutes)
}

/// Formats a TimeInterval as a duration string
/// - Parameter interval: Time interval in seconds
/// - Returns: Formatted string like "8h 30m"
func formatDuration(from interval: TimeInterval) -> String {
    let (hours, minutes) = hoursAndMinutes(from: interval)
    return formatDuration(hours: hours, minutes: minutes)
}
