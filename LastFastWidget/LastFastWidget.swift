//
//  LastFastWidget.swift
//  LastFastWidget
//
//  Main Home Screen Widget for Last Fast
//

import SwiftUI
import WidgetKit

// MARK: - Widget Entry View

struct LastFastWidgetEntryView: View {
    var entry: FastingEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        default:
            MediumWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct LastFastWidget: Widget {
    let kind: String = "LastFastWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LastFastWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Last Fast")
        .description("Track your current fast or see your fasting history.")
        .supportedFamilies([.systemMedium, .accessoryCircular])
    }
}

// MARK: - Previews

#Preview("Medium - Fasting", as: .systemMedium) {
    LastFastWidget()
} timeline: {
    FastingEntry(
        date: Date(),
        isActive: true,
        startTime: Date().addingTimeInterval(-3600 * 4),
        goalMinutes: 480,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Medium - Not Fasting", as: .systemMedium) {
    LastFastWidget()
} timeline: {
    FastingEntry(
        date: Date(),
        isActive: false,
        startTime: nil,
        goalMinutes: nil,
        lastFastDuration: 3600 * 16,
        lastFastGoalMet: true,
        lastFastStartTime: Date().addingTimeInterval(-3600 * 20),
        lastFastEndTime: Date().addingTimeInterval(-3600 * 4),
        recentFasts: [
            FastHistoryData(startDate: Date().addingTimeInterval(-4 * 86400), fastedHours: 16, goalHours: 16, goalMet: true),
            FastHistoryData(startDate: Date().addingTimeInterval(-3 * 86400), fastedHours: 14, goalHours: 16, goalMet: false),
            FastHistoryData(startDate: Date().addingTimeInterval(-2 * 86400), fastedHours: 8, goalHours: 12, goalMet: false),
            FastHistoryData(startDate: Date().addingTimeInterval(-1 * 86400), fastedHours: 18, goalHours: 16, goalMet: true),
            FastHistoryData(startDate: Date(), fastedHours: 12, goalHours: 12, goalMet: true)
        ]
    )
}
