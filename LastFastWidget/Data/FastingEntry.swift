//
//  FastingEntry.swift
//  LastFastWidget
//
//  Timeline entry for fasting widgets
//

import WidgetKit

/// Represents a single completed fast for the history graph
struct FastHistoryData: Hashable {
    let startDate: Date
    let fastedHours: Double
    let goalHours: Double
    let goalMet: Bool
}

struct FastingEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let startTime: Date?
    let goalMinutes: Int?
    let savedGoalMinutes: Int
    let lastFastDuration: TimeInterval?
    let lastFastGoalMet: Bool?
    let lastFastStartTime: Date?
    let lastFastEndTime: Date?

    /// Last 5 completed fasts for the graph
    let recentFasts: [FastHistoryData]

    init(
        date: Date,
        isActive: Bool,
        startTime: Date?,
        goalMinutes: Int?,
        savedGoalMinutes: Int = defaultFastingGoalMinutes,
        lastFastDuration: TimeInterval?,
        lastFastGoalMet: Bool?,
        lastFastStartTime: Date?,
        lastFastEndTime: Date?,
        recentFasts: [FastHistoryData] = []
    ) {
        self.date = date
        self.isActive = isActive
        self.startTime = startTime
        self.goalMinutes = goalMinutes
        self.savedGoalMinutes = savedGoalMinutes
        self.lastFastDuration = lastFastDuration
        self.lastFastGoalMet = lastFastGoalMet
        self.lastFastStartTime = lastFastStartTime
        self.lastFastEndTime = lastFastEndTime
        self.recentFasts = recentFasts
    }
}
