//
//  LastFastWidget.swift
//  LastFastWidget
//
//  Main Home Screen Widget for Last Fast
//

import SwiftUI
import WidgetKit

// MARK: - Widget Entry Views

struct LastFastWidgetEntryView: View {
    var entry: FastingEntry

    var body: some View {
        LockScreenCircularView(entry: entry)
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
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Previews

#Preview("Circular - In Progress", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: true,
        startTime: Date.now.addingTimeInterval(-10 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Circular - Goal Met", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: true,
        startTime: Date.now.addingTimeInterval(-18 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Circular - Inactive", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: false,
        startTime: nil,
        goalMinutes: nil,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}
