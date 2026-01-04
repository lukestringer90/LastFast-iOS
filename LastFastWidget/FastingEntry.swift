//
//  FastingEntry.swift
//  LastFastWidget
//
//  Timeline entry for fasting widgets
//

import WidgetKit

struct FastingEntry: TimelineEntry {
    let date: Date
    let isActive: Bool
    let startTime: Date?
    let goalMinutes: Int?
    let lastFastDuration: TimeInterval?
    let lastFastGoalMet: Bool?
    let lastFastStartTime: Date?
    let lastFastEndTime: Date?
}
