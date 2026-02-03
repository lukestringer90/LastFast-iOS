//
//  NaturalLanguageFormatting.swift
//  LastFast
//
//  Natural language formatting for Siri intents and spoken responses
//

import Foundation

// MARK: - Duration Formatting (Natural Language)

/// Formats duration as natural language (e.g., "16 hours and 30 minutes")
/// Used by Siri intents for spoken responses
/// - Parameters:
///   - hours: Number of hours
///   - minutes: Number of minutes
/// - Returns: Natural language string
func formatDurationNaturalLanguage(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours) hours and \(minutes) minutes"
    } else if hours > 0 {
        return hours == 1 ? "1 hour" : "\(hours) hours"
    } else {
        return minutes == 1 ? "1 minute" : "\(minutes) minutes"
    }
}

/// Formats a TimeInterval as natural language duration
/// - Parameter interval: Time interval in seconds
/// - Returns: Natural language string
func formatDurationNaturalLanguage(from interval: TimeInterval) -> String {
    let totalSeconds = Int(interval)
    let hours = totalSeconds / 3600
    let minutes = (totalSeconds % 3600) / 60
    return formatDurationNaturalLanguage(hours: hours, minutes: minutes)
}

/// Formats remaining time as natural language
/// - Parameters:
///   - remainingMinutes: Total remaining minutes
/// - Returns: Natural language string
func formatRemainingTimeNaturalLanguage(_ remainingMinutes: Int) -> String {
    let hours = remainingMinutes / 60
    let minutes = remainingMinutes % 60
    return formatDurationNaturalLanguage(hours: hours, minutes: minutes)
}

// MARK: - Goal Description Formatting

/// Formats goal hours as natural language description
/// Used when describing fasting goals in Siri responses
/// - Parameter hours: Goal duration in hours (can be fractional)
/// - Returns: Natural language description
func formatGoalDescription(hours: Double) -> String {
    let wholeHours = Int(hours)
    let mins = Int((hours - Double(wholeHours)) * 60)
    return formatDurationNaturalLanguage(hours: wholeHours, minutes: mins)
}

/// Formats goal minutes as natural language description
/// - Parameter goalMinutes: Goal in minutes
/// - Returns: Natural language description
func formatGoalDescription(minutes goalMinutes: Int) -> String {
    let hours = goalMinutes / 60
    let mins = goalMinutes % 60
    return formatDurationNaturalLanguage(hours: hours, minutes: mins)
}
