// LastFastWatchWidget.swift
// LastFastWatchWidget
// Watch complication and widget for Last Fast

import WidgetKit
import SwiftUI
import SwiftData

// MARK: - Widget Entry

struct WatchFastingEntry: TimelineEntry {
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

struct WatchFastingTimelineProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WatchFastingEntry {
        WatchFastingEntry(
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
    
    func getSnapshot(in context: Context, completion: @escaping (WatchFastingEntry) -> Void) {
        let entry = createEntry(for: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchFastingEntry>) -> Void) {
        let currentDate = Date()
        let data = fetchFastingData()
        
        var entries: [WatchFastingEntry] = []
        
        if data.isActive {
            // Generate entries for every minute for the next 60 minutes
            for minuteOffset in 0..<60 {
                let entryDate = currentDate.addingTimeInterval(TimeInterval(minuteOffset * 60))
                let entry = WatchFastingEntry(
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
            
            let refreshDate = currentDate.addingTimeInterval(60 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        } else {
            let entry = WatchFastingEntry(
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
            
            let refreshDate = currentDate.addingTimeInterval(15 * 60)
            let timeline = Timeline(entries: entries, policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func createEntry(for date: Date) -> WatchFastingEntry {
        let data = fetchFastingData()
        return WatchFastingEntry(
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
            
            let activeFast = sessions.first { $0.isActive }
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

func formatWatchDuration(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}

// MARK: - Accessory Corner Widget

struct AccessoryCornerView: View {
    let entry: WatchFastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var displayHours: Int {
        if entry.isActive && goalMet {
            return Int(currentDuration) / 3600
        }
        return remainingMinutes / 60
    }
    
    var displayMins: Int {
        if entry.isActive && goalMet {
            return (Int(currentDuration) % 3600) / 60
        }
        return remainingMinutes % 60
    }
    
    var body: some View {
        if entry.isActive {
            Text(formatWatchDuration(hours: displayHours, minutes: displayMins))
                .foregroundStyle(goalMet ? .green : .orange)
                .widgetCurvesContent()
        } else if let duration = entry.lastFastDuration {
            let h = Int(duration) / 3600
            let m = (Int(duration) % 3600) / 60
            Text(formatWatchDuration(hours: h, minutes: m))
                .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                .widgetCurvesContent()
        } else {
            Text("--")
                .foregroundStyle(.secondary)
                .widgetCurvesContent()
        }
    }
}

// MARK: - Accessory Circular Pie Chart Widget

struct AccessoryCircularPieView: View {
    let entry: WatchFastingEntry
    
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
        if entry.isActive {
            ZStack {
                if goalMet {
                    // Full green circle when goal met
                    Circle()
                        .fill(Color.green)
                    
                    if elapsedHours > 0 {
                        Text("\(elapsedHours)h")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(elapsedMins)m")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                } else {
                    // Background circle
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                    
                    // Pie chart progress
                    PieShape(progress: progress)
                        .fill(Color.orange)
                    
                    // Center text
                    if hours > 0 {
                        Text("\(hours)h")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    } else {
                        Text("\(minutes)m")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)
                    }
                }
            }
        } else if let duration = entry.lastFastDuration {
            let h = Int(duration) / 3600
            let m = (Int(duration) % 3600) / 60
            
            ZStack {
                Circle()
                    .fill(entry.lastFastGoalMet == true ? Color.green : Color.orange)
                
                if h > 0 {
                    Text("\(h)h")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                } else {
                    Text("\(m)m")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
            }
        } else {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.3))
                
                Text("--")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Pie Shape

struct PieShape: Shape {
    var progress: Double
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let startAngle = Angle(degrees: -90)
        let endAngle = Angle(degrees: -90 + (360 * progress))
        
        path.move(to: center)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Accessory Circular Widget

struct AccessoryCircularView: View {
    let entry: WatchFastingEntry
    
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
    
    var displayHours: Int {
        if entry.isActive && goalMet {
            return Int(currentDuration) / 3600
        }
        return remainingMinutes / 60
    }
    
    var displayMins: Int {
        if entry.isActive && goalMet {
            return (Int(currentDuration) % 3600) / 60
        }
        return remainingMinutes % 60
    }
    
    var body: some View {
        if entry.isActive {
            Gauge(value: progress) {
                Text("")
            } currentValueLabel: {
                VStack(spacing: 0) {
                    if displayHours > 0 {
                        Text("\(displayHours)h\(displayMins)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    } else {
                        Text("\(displayMins)m")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                }
                .foregroundStyle(goalMet ? .green : .orange)
            }
            .gaugeStyle(.accessoryCircular)
            .tint(goalMet ? .green : .orange)
        } else if let duration = entry.lastFastDuration {
            let h = Int(duration) / 3600
            let m = (Int(duration) % 3600) / 60
            
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 0) {
                    if h > 0 {
                        Text("\(h)h\(m)")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                    } else {
                        Text("\(m)m")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                    }
                    if entry.lastFastGoalMet == true {
                        Image(systemName: "checkmark")
                            .font(.system(size: 8))
                    }
                }
                .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Text("--")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Accessory Rectangular Widget

struct AccessoryRectangularView: View {
    let entry: WatchFastingEntry
    
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
                                .foregroundStyle(.green)
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.green)
                        }
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.green)
                    } else {
                        if hours > 0 {
                            Text("\(hours)h \(minutes)m")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        } else {
                            Text("\(minutes)m")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                // Progress bar (only show when goal not met)
                if !goalMet {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 4)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * progress, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
            }
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
                                .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                        } else {
                            Text("\(m)m")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundStyle(entry.lastFastGoalMet == true ? .green : .orange)
                        }
                        
                        if let goalMet = entry.lastFastGoalMet {
                            Image(systemName: goalMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(goalMet ? .green : .red)
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
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Accessory Inline Widget

struct AccessoryInlineView: View {
    let entry: WatchFastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }
    
    var displayHours: Int {
        if entry.isActive && goalMet {
            return Int(currentDuration) / 3600
        }
        return remainingMinutes / 60
    }
    
    var displayMins: Int {
        if entry.isActive && goalMet {
            return (Int(currentDuration) % 3600) / 60
        }
        return remainingMinutes % 60
    }
    
    var body: some View {
        if entry.isActive {
            if goalMet {
                Label("Fasted \(formatWatchDuration(hours: displayHours, minutes: displayMins)) ✓", systemImage: "checkmark.circle.fill")
            } else {
                Label("Fast \(formatWatchDuration(hours: displayHours, minutes: displayMins)) left", systemImage: "timer")
            }
        } else if let duration = entry.lastFastDuration {
            let h = Int(duration) / 3600
            let m = (Int(duration) % 3600) / 60
            Label("Last: \(formatWatchDuration(hours: h, minutes: m))", systemImage: "clock")
        } else {
            Label("No fasts", systemImage: "clock")
        }
    }
}

// MARK: - Widget Entry View

struct LastFastWatchWidgetEntryView: View {
    var entry: WatchFastingEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .accessoryCorner:
            AccessoryCornerView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularPieView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)
        default:
            AccessoryCircularPieView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct LastFastWatchWidget: Widget {
    let kind: String = "LastFastWatchWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchFastingTimelineProvider()) { entry in
            LastFastWatchWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Last Fast")
        .description("Track your fasting progress.")
        .supportedFamilies([
            .accessoryCorner,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Widget Bundle

@main
struct LastFastWatchWidgetBundle: WidgetBundle {
    var body: some Widget {
        LastFastWatchWidget()
    }
}

// MARK: - Previews

#Preview("Circular Pie - Fasting", as: .accessoryCircular) {
    LastFastWatchWidget()
} timeline: {
    WatchFastingEntry(
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

#Preview("Circular Pie - Almost Done", as: .accessoryCircular) {
    LastFastWatchWidget()
} timeline: {
    WatchFastingEntry(
        date: Date(),
        isActive: true,
        startTime: Date().addingTimeInterval(-3600 * 7.5),
        goalMinutes: 480,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Rectangular - Fasting", as: .accessoryRectangular) {
    LastFastWatchWidget()
} timeline: {
    WatchFastingEntry(
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

#Preview("Rectangular - Not Fasting", as: .accessoryRectangular) {
    LastFastWatchWidget()
} timeline: {
    WatchFastingEntry(
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
