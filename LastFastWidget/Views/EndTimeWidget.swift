//
//  EndTimeWidget.swift
//  LastFastWidget
//
//  End Time widget showing when fast will end
//

import SwiftUI
import WidgetKit

// MARK: - Small End Time Widget View

struct SmallEndTimeWidgetView: View {
    let entry: FastingEntry
    
    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }
    
    var elapsedHours: Int { Int(currentDuration) / 3600 }
    var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }
    
    var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }
    
    var remainingHours: Int { remainingMinutes / 60 }
    var remainingMins: Int { remainingMinutes % 60 }
    
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
        VStack(spacing: 4) {
            if entry.isActive {
                if goalMet {
                    goalMetView
                } else {
                    activeView
                }
            } else {
                inactiveView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    private var goalMetView: some View {
        VStack(spacing: 4) {
            Spacer()
            
            if elapsedHours > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(elapsedHours)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    Text("h")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                    Text("\(elapsedMins)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    Text("m")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                }
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 1) {
                    Text("\(elapsedMins)")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(.green)
                    Text("m")
                        .font(.system(size: 20, weight: .medium, design: .rounded))
                        .foregroundStyle(.green.opacity(0.7))
                }
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            }
            
            Text("Goal reached!")
                .font(.caption)
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
    
    private var activeView: some View {
        VStack(spacing: 6) {
            Spacer()
            
            // Large end time
            if let end = endTime {
                Text(format24HourTime(end))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
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
            .padding(.horizontal, 8)
            
            // Remaining time (not elapsed)
            Text("\(formatWidgetDuration(hours: remainingHours, minutes: remainingMins)) left")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Spacer()
        }
    }
    
    private var inactiveView: some View {
        VStack(spacing: 4) {
            Spacer()
            
            if let duration = entry.lastFastDuration {
                let h = Int(duration) / 3600
                let m = (Int(duration) % 3600) / 60
                let color: Color = entry.lastFastGoalMet == true ? .green : .orange
                
                Text("LAST FAST")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 4) {
                    if h > 0 {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(h)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("h")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
                            Text("\(m)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("m")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(m)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("m")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
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
            
            Spacer()
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
        .description("Shows when your fast will end.")
        .supportedFamilies([.systemSmall])
    }
}

