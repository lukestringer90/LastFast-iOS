// FastingSession.swift
// LastFast
// SwiftData model for fasting sessions

import Foundation
import SwiftData

#if canImport(ActivityKit)
import ActivityKit
#endif

// MARK: - Constants

/// Default fasting goal in minutes (12 hours)
let defaultFastingGoalMinutes: Int = 720

/// App Storage key for fasting goal
let fastingGoalStorageKey = "fastingGoalMinutes"

// MARK: - Time Formatting

/// Formats a date as 24-hour time (HH:mm)
func format24HourTime(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

// MARK: - Live Activity Attributes

#if canImport(ActivityKit)
struct LastFastWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic state - updated as fast progresses
        var elapsedSeconds: Int
        var goalMet: Bool
    }
    
    // Fixed properties - set when activity starts
    var startTime: Date
    var goalMinutes: Int
}
#endif

// MARK: - Fasting Session Model

@Model
final class FastingSession {
    var id: UUID
    var startTime: Date
    var endTime: Date?
    var goalMinutes: Int?
    var goalCelebrationShown: Bool = false
    
    var isActive: Bool {
        endTime == nil
    }
    
    var duration: TimeInterval {
        let end = endTime ?? Date()
        return end.timeIntervalSince(startTime)
    }
    
    var goalMet: Bool {
        guard let goal = goalMinutes else { return false }
        let durationMinutes = Int(duration) / 60
        return durationMinutes >= goal
    }
    
    var formattedDuration: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, seconds)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    var formattedDurationShort: String {
        let totalSeconds = Int(duration)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        if hours > 0 {
            return String(format: "%d:%02d", hours, minutes)
        } else {
            return String(format: "0:%02d", minutes)
        }
    }
    
    init(startTime: Date = Date(), goalMinutes: Int? = nil) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = nil
        self.goalMinutes = goalMinutes
        self.goalCelebrationShown = false
    }
    
    func stop() {
        self.endTime = Date()
    }
}
