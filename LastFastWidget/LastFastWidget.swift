// LastFastWidget.swift
// LastFastWidget
// Home Screen Widget for Last Fast

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

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

// MARK: - Widget Provider

struct FastingTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> FastingEntry {
        FastingEntry(
            date: Date(),
            isActive: true,
            startTime: Date().addingTimeInterval(-3600 * 4), // 4 hours ago
            goalMinutes: 480,
            lastFastDuration: nil,
            lastFastGoalMet: nil,
            lastFastStartTime: nil,
            lastFastEndTime: nil
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FastingEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FastingEntry>) -> Void) {
        let currentDate = Date()
        let data = fetchFastingData()
        
        var entries: [FastingEntry] = []
        
        if data.isActive {
            // Generate entries for every minute for the next 60 minutes
            for minuteOffset in 0..<60 {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(minuteOffset * 60))
                let entry = FastingEntry(
                    date: entryDate,
                    isActive: data.isActive,
                    startTime: data.startTime,
                    goalMinutes: data.goalMinutes,
                    lastFastDuration: data.lastFastDuration,
                    lastFastGoalMet: data.lastFastGoalMet,
                    lastFastStartTime: data.lastFastStartTime,
                    lastFastEndTime: data.lastFastEndTime
                )
                entries.append(entry)
            }
            
            // Refresh timeline after 60 minutes
            let refreshDate = currentDate.addingTimeInterval(60 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        } else {
            // Not fasting - single entry, refresh less often
            let entry = FastingEntry(
                date: currentDate,
                isActive: data.isActive,
                startTime: data.startTime,
                goalMinutes: data.goalMinutes,
                lastFastDuration: data.lastFastDuration,
                lastFastGoalMet: data.lastFastGoalMet,
                lastFastStartTime: data.lastFastStartTime,
                lastFastEndTime: data.lastFastEndTime
            )
            entries.append(entry)
            
            // Refresh every 15 minutes when not fasting
            let refreshDate = currentDate.addingTimeInterval(15 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func createEntry(for date: Date) -> FastingEntry {
        let data = fetchFastingData()
        return FastingEntry(
            date: date,
            isActive: data.isActive,
            startTime: data.startTime,
            goalMinutes: data.goalMinutes,
            lastFastDuration: data.lastFastDuration,
            lastFastGoalMet: data.lastFastGoalMet,
            lastFastStartTime: data.lastFastStartTime,
            lastFastEndTime: data.lastFastEndTime
        )
    }
    
    private struct FastingData {
        let isActive: Bool
        let startTime: Date?
        let goalMinutes: Int?
        let lastFastDuration: TimeInterval?
        let lastFastGoalMet: Bool?
        let lastFastStartTime: Date?
        let lastFastEndTime: Date?
    }
    
    private func fetchFastingData() -> FastingData {
        // Try to fetch from shared SwiftData container
        do {
            let schema = Schema([FastingSession.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<FastingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            let sessions = try context.fetch(descriptor)
            
            // Find active fast
            let activeFast = sessions.first { $0.isActive }
            
            // Find last completed fast
            let lastCompletedFast = sessions.first { !$0.isActive }
            
            return FastingData(
                isActive: activeFast != nil,
                startTime: activeFast?.startTime,
                goalMinutes: activeFast?.goalMinutes,
                lastFastDuration: lastCompletedFast?.duration,
                lastFastGoalMet: lastCompletedFast?.goalMet,
                lastFastStartTime: lastCompletedFast?.startTime,
                lastFastEndTime: lastCompletedFast?.endTime
            )
        } catch {
            // Return default data if fetch fails
            return FastingData(
                isActive: false,
                startTime: nil,
                goalMinutes: nil,
                lastFastDuration: nil,
                lastFastGoalMet: nil,
                lastFastStartTime: nil,
                lastFastEndTime: nil
            )
        }
    }
}

// MARK: - Duration Formatting

func formatWidgetDuration(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: FastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var hours: Int {
        remainingMinutes / 60
    }
    
    var minutes: Int {
        remainingMinutes % 60
    }
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var body: some View {
        VStack(spacing: 6) {
            if entry.isActive {
                // Label
                Text(goalMet ? "You've fasted for" : "Keep fasting")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                // Time display
                if goalMet {
                    // Show elapsed time when goal met
                    if elapsedHours > 0 {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(elapsedHours)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                            Text("h")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.green.opacity(0.7))
                            Text("\(elapsedMins)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                            Text("m")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.green.opacity(0.7))
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(elapsedMins)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                            Text("m")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.green.opacity(0.7))
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    }
                } else {
                    // Show countdown
                    if hours > 0 {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(hours)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                            Text("h")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.orange.opacity(0.7))
                            Text("\(minutes)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                            Text("m")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.orange.opacity(0.7))
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(minutes)")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                            Text("m")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(.orange.opacity(0.7))
                        }
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    }
                }
                
                // Progress bar (only show when goal not met)
                if !goalMet {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                                .frame(height: 6)
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * progress, height: 6)
                        }
                    }
                    .frame(height: 6)
                    .padding(.horizontal, 4)
                    
                    // Predicted end time
                    if let goal = entry.goalMinutes, let start = entry.startTime {
                        let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                        Text("Until \(endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("🎉 Goal reached!")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
            } else {
                // Not fasting - show last fast
                Text("Last Fast")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                if let duration = entry.lastFastDuration {
                    let h = Int(duration) / 3600
                    let m = (Int(duration) % 3600) / 60
                    
                    HStack(spacing: 4) {
                        if h > 0 {
                            HStack(alignment: .firstTextBaseline, spacing: 1) {
                                Text("\(h)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                Text("h")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                                Text("\(m)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                Text("m")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                            }
                        } else {
                            HStack(alignment: .firstTextBaseline, spacing: 1) {
                                Text("\(m)")
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                Text("m")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                            }
                        }
                        
                        if let goalMet = entry.lastFastGoalMet {
                            Image(systemName: goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(goalMet ? .green : .red)
                                .font(.caption)
                        }
                    }
                    .minimumScaleFactor(0.5)
                } else {
                    Text("No fasts yet")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
                
                Text("Tap to start")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: FastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var hours: Int {
        remainingMinutes / 60
    }
    
    var minutes: Int {
        remainingMinutes % 60
    }
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if entry.isActive {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        // Label
                        Text(goalMet ? "You've fasted for" : "Keep fasting")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                        
                        // Time display
                        if goalMet {
                            // Show elapsed time
                            if elapsedHours > 0 {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(elapsedHours)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.green)
                                    Text("h")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.green.opacity(0.7))
                                    Text("\(elapsedMins)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.green)
                                    Text("m")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.green.opacity(0.7))
                                }
                                .minimumScaleFactor(0.5)
                            } else {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(elapsedMins)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.green)
                                    Text("m")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.green.opacity(0.7))
                                }
                                .minimumScaleFactor(0.5)
                            }
                        } else {
                            // Show countdown
                            if hours > 0 {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(hours)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.orange)
                                    Text("h")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.orange.opacity(0.7))
                                    Text("\(minutes)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.orange)
                                    Text("m")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.orange.opacity(0.7))
                                }
                                .minimumScaleFactor(0.5)
                            } else {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(minutes)")
                                        .font(.system(size: 48, weight: .bold, design: .rounded))
                                        .foregroundStyle(.orange)
                                    Text("m")
                                        .font(.system(size: 18, weight: .medium, design: .rounded))
                                        .foregroundStyle(.orange.opacity(0.7))
                                }
                                .minimumScaleFactor(0.5)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Right side info
                    if let goal = entry.goalMinutes, let start = entry.startTime {
                        VStack(alignment: .trailing, spacing: 4) {
                            // Fasted time or goal reached
                            if goalMet {
                                Text("🎉 Goal reached!")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.green)
                            } else {
                                Text("\(formatWidgetDuration(hours: elapsedHours, minutes: elapsedMins)) fasted")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                            }
                            
                            // Start → End times
                            let completionTime = start.addingTimeInterval(TimeInterval(goal * 60))
                            Text("\(start.formatted(date: .omitted, time: .shortened)) → \(completionTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            // Goal
                            Text("Goal: \(formatWidgetDuration(hours: goal / 60, minutes: goal % 60))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Progress bar (only show when goal not met)
                if !goalMet {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(.systemGray5))
                                .frame(height: 10)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * progress, height: 10)
                        }
                    }
                    .frame(height: 10)
                    
                    // Predicted end time
                    if let goal = entry.goalMinutes, let start = entry.startTime {
                        let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                        Text("Until \(endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                // Not fasting - left aligned
                VStack(alignment: .leading, spacing: 4) {
                    Text("Last Fast")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    if let duration = entry.lastFastDuration {
                        let h = Int(duration) / 3600
                        let m = (Int(duration) % 3600) / 60
                        
                        HStack(spacing: 6) {
                            if h > 0 {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(h)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                    Text("h")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                                    Text("\(m)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                    Text("m")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                                }
                            } else {
                                HStack(alignment: .firstTextBaseline, spacing: 2) {
                                    Text("\(m)")
                                        .font(.system(size: 44, weight: .bold, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                                    Text("m")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundStyle(entry.lastFastGoalMet == true ? .green.opacity(0.7) : .orange.opacity(0.7))
                                }
                            }
                            
                            if let goalMet = entry.lastFastGoalMet {
                                Image(systemName: goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(goalMet ? .green : .red)
                                    .font(.title3)
                            }
                        }
                        .minimumScaleFactor(0.5)
                        
                        // Start → End times for last fast
                        if let startTime = entry.lastFastStartTime, let endTime = entry.lastFastEndTime {
                            Text("\(startTime.formatted(date: .omitted, time: .shortened)) → \(endTime.formatted(date: .omitted, time: .shortened))")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("No fasts")
                            .font(.title)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Tap to start")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal, 4)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

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
        case .accessoryCircular:
            LockScreenCircularView(entry: entry)
        case .accessoryRectangular:
            LockScreenRectangularView(entry: entry)
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
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Lock Screen Circular Widget (Small)

struct LockScreenCircularView: View {
    let entry: FastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var hours: Int {
        remainingMinutes / 60
    }
    
    var minutes: Int {
        remainingMinutes % 60
    }
    
    var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Full circle when goal met
                    ZStack {
                        AccessoryWidgetBackground()
                        
                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                } else {
                    // Gauge progress
                    Gauge(value: progress) {
                        Text("")
                    } currentValueLabel: {
                        if hours > 0 {
                            Text("\(hours)h")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        } else {
                            Text("\(minutes)m")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                }
            } else if let duration = entry.lastFastDuration {
                let h = Int(duration) / 3600
                let m = (Int(duration) % 3600) / 60
                
                ZStack {
                    AccessoryWidgetBackground()
                    VStack(spacing: 0) {
                        if h > 0 {
                            Text("\(h)h")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        } else {
                            Text("\(m)m")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                        if entry.lastFastGoalMet == true {
                            Image(systemName: "checkmark")
                                .font(.system(size: 8))
                        }
                    }
                }
            } else {
                ZStack {
                    AccessoryWidgetBackground()
                    Text("--")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                }
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Lock Screen Rectangular Widget (Medium)

struct LockScreenRectangularView: View {
    let entry: FastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var elapsedHours: Int {
        Int(currentDuration) / 3600
    }
    
    var elapsedMins: Int {
        (Int(currentDuration) % 3600) / 60
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var hours: Int {
        remainingMinutes / 60
    }
    
    var minutes: Int {
        remainingMinutes % 60
    }
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                VStack(alignment: .leading, spacing: 2) {
                    // Label
                    Text(goalMet ? "FASTED" : "KEEP FASTING")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    // Time
                    HStack(spacing: 2) {
                        if goalMet {
                            if elapsedHours > 0 {
                                Text("\(elapsedHours)h \(elapsedMins)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            } else {
                                Text("\(elapsedMins)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                        } else {
                            if hours > 0 {
                                Text("\(hours)h \(minutes)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                        }
                    }
                    
                    // Start → End times (show during fasting)
                    if let start = entry.startTime, let goal = entry.goalMinutes {
                        let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                        Text("\(start.formatted(date: .omitted, time: .shortened)) → \(endTime.formatted(date: .omitted, time: .shortened))")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                    }
                    
                    // Progress bar (only show when goal not met)
                    if !goalMet {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 4)
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.primary)
                                    .frame(width: geometry.size.width * progress, height: 4)
                            }
                        }
                        .frame(height: 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text("LAST FAST")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                    
                    if let duration = entry.lastFastDuration {
                        let h = Int(duration) / 3600
                        let m = (Int(duration) % 3600) / 60
                        
                        HStack(spacing: 4) {
                            if h > 0 {
                                Text("\(h)h \(m)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            } else {
                                Text("\(m)m")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            
                            if let goalMet = entry.lastFastGoalMet {
                                Image(systemName: goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 12))
                            }
                        }
                        
                        // Start → End times
                        if let startTime = entry.lastFastStartTime, let endTime = entry.lastFastEndTime {
                            Text("\(startTime.formatted(date: .omitted, time: .shortened)) → \(endTime.formatted(date: .omitted, time: .shortened))")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        Text("No fasts")
                            .font(.system(size: 16, weight: .medium))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Widget Bundle

@main
struct LastFastWidgetBundle: WidgetBundle {
    var body: some Widget {
        LastFastWidget()
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
