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
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
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
        .description("Track your current fast or see your last completed fast.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryCircular])
    }
}

// MARK: - Previews

#Preview("Small - Fasting", as: .systemSmall) {
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

#Preview("Small - Not Fasting", as: .systemSmall) {
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
        lastFastEndTime: Date().addingTimeInterval(-3600 * 4)
    )
}

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
        lastFastEndTime: Date().addingTimeInterval(-3600 * 4)
    )
}
