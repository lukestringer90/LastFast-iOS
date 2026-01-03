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
                        Text("Until \(format24HourTime(endTime))")
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

// MARK: - Medium Widget View (matches Live Activity Lock Screen layout)

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
    
    var remainingHours: Int {
        remainingMinutes / 60
    }
    
    var remainingMins: Int {
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
        if entry.isActive {
            if goalMet {
                // SCENARIO 2: Active fast, goal met
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        // Left side - Fasted label
                        Text("FASTED FOR \(elapsedHours)h \(elapsedMins)m")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Right side - checkmark
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                            .foregroundStyle(.green)
                    }
                    
                    // Large elapsed time in green
                    Text("\(elapsedHours)h \(elapsedMins)m")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
                .padding(16)
                .containerBackground(for: .widget) {
                    Color(UIColor.secondarySystemBackground)
                }
            } else {
                // SCENARIO 1: Active fast, goal not met
                VStack(alignment: .leading, spacing: 8) {
                    HStack(alignment: .top) {
                        // Left side - Keep fasting label
                        Text("KEEP FASTING FOR")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Right side - start time "TO"
                        if let start = entry.startTime {
                            Text("\(format24HourTime(start)) TO")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        // Left side - remaining time in orange
                        Text("\(remainingHours)h \(remainingMins)m")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                        
                        Spacer()
                        
                        // Right side - end time in white/primary
                        if let start = entry.startTime, let goal = entry.goalMinutes {
                            let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                            Text(format24HourTime(endTime))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.primary)
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.gray.opacity(0.3))
                            
                            RoundedRectangle(cornerRadius: 5)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 8)
                }
                .padding(16)
                .containerBackground(for: .widget) {
                    Color(UIColor.secondarySystemBackground)
                }
            }
        } else {
            // SCENARIO 3: No active fast - same as small widget
            VStack(spacing: 6) {
                Text("Last Fast")
                    .font(.caption)
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
                            HStack(alignment: .firstTextBaseline, spacing: 1) {
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
                                .font(.title2)
                        }
                    }
                    .minimumScaleFactor(0.5)
                } else {
                    Text("No fasts yet")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }
                
                Text("Tap to start")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .containerBackground(for: .widget) {
                Color(.systemBackground)
            }
        }
    }
}

// MARK: - Large Widget View (matches Live Activity Lock Screen layout)

struct LargeWidgetView: View {
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
    
    var remainingHours: Int {
        remainingMinutes / 60
    }
    
    var remainingMins: Int {
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
        if entry.isActive {
            if goalMet {
                // SCENARIO 2: Active fast, goal met
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        // Left side - Fasted label
                        Text("Fasted for \(elapsedHours)h \(elapsedMins)m")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Right side - checkmark
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                    }
                    
                    // Large elapsed time in green
                    Text("\(elapsedHours)h \(elapsedMins)m")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                }
                .padding(20)
                .containerBackground(for: .widget) {
                    Color(UIColor.secondarySystemBackground)
                }
            } else {
                // SCENARIO 1: Active fast, goal not met - matches screenshot exactly
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top) {
                        // Left side - Fasted label
                        Text("Fasted for \(elapsedHours)h \(elapsedMins)m")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Spacer()
                        
                        // Right side - start time "to"
                        if let start = entry.startTime {
                            Text("\(format24HourTime(start)) to")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline) {
                        // Left side - remaining time
                        Text("\(remainingHours)h \(remainingMins)m")
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        
                        Spacer()
                        
                        // Right side - end time in orange
                        if let start = entry.startTime, let goal = entry.goalMinutes {
                            let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                            Text(format24HourTime(endTime))
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    // Progress bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.gray.opacity(0.3))
                            
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.orange)
                                .frame(width: geo.size.width * progress)
                        }
                    }
                    .frame(height: 10)
                }
                .padding(20)
                .containerBackground(for: .widget) {
                    Color(UIColor.secondarySystemBackground)
                }
            }
        } else {
            // SCENARIO 3: No active fast
            VStack(alignment: .leading, spacing: 12) {
                Text("Not Fasting")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(alignment: .firstTextBaseline) {
                    Text("Not Fasting")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "fork.knife")
                        .font(.system(size: 48))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
            .containerBackground(for: .widget) {
                Color(UIColor.secondarySystemBackground)
            }
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

// MARK: - Lock Screen Circular Widget (Progress)

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
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met - full circle with checkmark
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 4)
                            .opacity(0.3)
                        Circle()
                            .stroke(lineWidth: 4)
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                    }
                } else {
                    // Active fast - show progress and remaining time
                    Gauge(value: progress) {
                        Text("")
                    } currentValueLabel: {
                        if hours > 0 {
                            Text("\(hours)h \(minutes)m")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                        } else {
                            Text("\(minutes)m")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                }
            } else {
                // No active fast - blank
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Small End Time Widget View

struct SmallEndTimeWidgetView: View {
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
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        VStack(spacing: 6) {
            if entry.isActive {
                if goalMet {
                    // Goal met - show elapsed time
                    Text("You've fasted for")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
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
                    
                    Text("🎉 Goal reached!")
                        .font(.caption2)
                        .foregroundStyle(.green)
                } else {
                    // Show end time
                    Text("Fast until")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                    
                    if let end = endTime {
                        Text(format24HourTime(end))
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                            .minimumScaleFactor(0.5)
                            .lineLimit(1)
                    }
                    
                    // Progress bar
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
                    
                    // Fasted duration
                    Text("\(formatWidgetDuration(hours: elapsedHours, minutes: elapsedMins)) fasted")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                // Not fasting - show last fast (same as regular small widget)
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
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
}

// MARK: - End Time Widget Configuration

struct EndTimeWidget: Widget {
    let kind: String = "EndTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            SmallEndTimeWidgetView(entry: entry)
        }
        .configurationDisplayName("End Time")
        .description("Shows when your fast will end instead of the countdown.")
        .supportedFamilies([.systemSmall])
    }
}

// MARK: - Lock Screen Circular End Time Widget

struct LockScreenCircularEndTimeView: View {
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
    
    var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met - show emoji and total elapsed time
                    VStack(spacing: 2) {
                        Text("🎉")
                            .font(.system(size: 20))
                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                        }
                    }
                } else {
                    // Active fast - show fork.knife.circle and end time
                    VStack(spacing: 2) {
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 20))
                        if let end = endTime {
                            Text(format24HourTime(end))
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                        }
                    }
                }
            } else {
                // No active fast - blank
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

struct CircularEndTimeWidget: Widget {
    let kind: String = "CircularEndTimeWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenCircularEndTimeView(entry: entry)
        }
        .configurationDisplayName("End Time (Circular)")
        .description("A circular Lock Screen widget showing when your fast will end.")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Lock Screen Rectangular Combined Widget

struct LockScreenRectangularCombinedView: View {
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
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met - checkmark and elapsed time, full height
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                        
                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        
                        Spacer()
                    }
                } else {
                    // Active fast - progress gauge on left, UNTIL and end time on right
                    HStack(spacing: 8) {
                        // Left - progress gauge with remaining time
                        Gauge(value: progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)
                        
                        // Right - UNTIL and end time
                        VStack(alignment: .leading, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(format24HourTime(end))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                        }
                        
                        Spacer()
                    }
                }
            } else {
                // No active fast - blank
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

struct RectangularCombinedWidget: Widget {
    let kind: String = "RectangularCombinedWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time")
        .description("A rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Lock Screen Rectangular Combined Widget (Right-Aligned)

struct LockScreenRectangularCombinedRightView: View {
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
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met - elapsed time and checkmark, full height, right-aligned
                    HStack(spacing: 8) {
                        Spacer()
                        
                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                    }
                } else {
                    // Active fast - UNTIL and end time on left, progress gauge on right
                    HStack(spacing: 8) {
                        Spacer()
                        
                        // Left - UNTIL and end time
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(format24HourTime(end))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                        }
                        
                        // Right - progress gauge with remaining time
                        Gauge(value: progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)
                    }
                }
            } else {
                // No active fast - blank
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

struct RectangularCombinedRightWidget: Widget {
    let kind: String = "RectangularCombinedRightWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedRightView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time (Right)")
        .description("A right-aligned rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Lock Screen Rectangular Combined Widget (Center-Aligned)

struct LockScreenRectangularCombinedCenterView: View {
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
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met - checkmark and elapsed time, full height, center-aligned
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 32, weight: .bold))
                        
                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                        }
                    }
                } else {
                    // Active fast - progress gauge on left, UNTIL and end time on right, centered
                    HStack(spacing: 8) {
                        // Left - progress gauge with remaining time
                        Gauge(value: progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)
                        
                        // Right - UNTIL and end time
                        VStack(alignment: .leading, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(format24HourTime(end))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                        }
                    }
                }
            } else {
                // No active fast - blank
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

struct RectangularCombinedCenterWidget: Widget {
    let kind: String = "RectangularCombinedCenterWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FastingTimelineProvider()) { entry in
            LockScreenRectangularCombinedCenterView(entry: entry)
        }
        .configurationDisplayName("Progress & End Time (Center)")
        .description("A center-aligned rectangular Lock Screen widget showing progress and end time.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Rectangular Spacer Widget

struct RectangularSpacerWidget: Widget {
    let kind: String = "RectangularSpacerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpacerTimelineProvider()) { _ in
            SpacerWidgetView()
        }
        .configurationDisplayName("Spacer (Medium)")
        .description("A blank medium-width widget to use as a spacer on the Lock Screen.")
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Spacer Widget

struct SpacerEntry: TimelineEntry {
    let date: Date
}

struct SpacerTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SpacerEntry {
        SpacerEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SpacerEntry) -> Void) {
        completion(SpacerEntry(date: Date()))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SpacerEntry>) -> Void) {
        let entry = SpacerEntry(date: Date())
        // Never needs to update
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct SpacerWidgetView: View {
    var body: some View {
        Color.clear
            .containerBackground(for: .widget) { }
    }
}

struct SpacerWidget: Widget {
    let kind: String = "SpacerWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SpacerTimelineProvider()) { _ in
            SpacerWidgetView()
        }
        .configurationDisplayName("Spacer")
        .description("A blank widget to use as a spacer on the Lock Screen.")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Widget Bundle

@main
struct LastFastWidgetBundle: WidgetBundle {
    var body: some Widget {
        LastFastWidget()
        EndTimeWidget()
        CircularEndTimeWidget()
        RectangularCombinedWidget()
        RectangularCombinedRightWidget()
        RectangularCombinedCenterWidget()
        SpacerWidget()
        RectangularSpacerWidget()
        LastFastWidgetLiveActivity()
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
