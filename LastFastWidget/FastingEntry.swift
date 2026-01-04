//
//  FastingEntry.swift
//  LastFastWidget
//
//  Timeline entry for fasting widgets
//

import WidgetKit

/// Represents a single day's fasting data for the history graph
struct DayFastingData: Hashable {
    let date: Date
    let totalFastedHours: Double
    let goalMet: Bool
}

struct FastingEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let startTime: Date?
    let goalMinutes: Int?
    let lastFastDuration: TimeInterval?
    let lastFastGoalMet: Bool?
    let lastFastStartTime: Date?
    let lastFastEndTime: Date?
    
    /// Last 5 days of fasting history for the graph
    let recentHistory: [DayFastingData]
    
    init(
        date: Date,
        isActive: Bool,
        startTime: Date?,
        goalMinutes: Int?,
        lastFastDuration: TimeInterval?,
        lastFastGoalMet: Bool?,
        lastFastStartTime: Date?,
        lastFastEndTime: Date?,
        recentHistory: [DayFastingData] = []
    ) {
        self.date = date
        self.isActive = isActive
        self.startTime = startTime
        self.goalMinutes = goalMinutes
        self.lastFastDuration = lastFastDuration
        self.lastFastGoalMet = lastFastGoalMet
        self.lastFastStartTime = lastFastStartTime
        self.lastFastEndTime = lastFastEndTime
        self.recentHistory = recentHistory
    }
}
