//
//  SmallWidgetView.swift
//  LastFastWidget
//
//  Small Home Screen widget view
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
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
    
    var hours: Int { remainingMinutes / 60 }
    var minutes: Int { remainingMinutes % 60 }
    
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
                activeStateView
            } else {
                inactiveStateView
            }
        }
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }
    
    @ViewBuilder
    private var activeStateView: some View {
        Text(goalMet ? "You've fasted for" : "Keep fasting")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
        
        timeDisplay
        
        if !goalMet {
            progressBar
            endTimeLabel
        } else {
            Text("🎉 Goal reached!")
                .font(.caption2)
                .foregroundStyle(.green)
        }
    }
    
    @ViewBuilder
    private var timeDisplay: some View {
        if goalMet {
            elapsedTimeDisplay(color: .green)
        } else {
            remainingTimeDisplay(color: .orange)
        }
    }
    
    @ViewBuilder
    private func elapsedTimeDisplay(color: Color) -> some View {
        if elapsedHours > 0 {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(elapsedHours)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("h")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
                Text("\(elapsedMins)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("m")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(elapsedMins)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("m")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        }
    }
    
    @ViewBuilder
    private func remainingTimeDisplay(color: Color) -> some View {
        if hours > 0 {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(hours)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("h")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
                Text("\(minutes)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("m")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        } else {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text("\(minutes)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("m")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            .minimumScaleFactor(0.5)
            .lineLimit(1)
        }
    }
    
    private var progressBar: some View {
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
    }
    
    @ViewBuilder
    private var endTimeLabel: some View {
        if let goal = entry.goalMinutes, let start = entry.startTime {
            let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
            Text("Until \(format24HourTime(endTime))")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var inactiveStateView: some View {
        Text("Last Fast")
            .font(.caption2)
            .fontWeight(.medium)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
        
        if let duration = entry.lastFastDuration {
            lastFastDurationView(duration: duration)
        } else {
            Text("No fasts yet")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
        
        Text("Tap to start")
            .font(.caption2)
            .foregroundStyle(.tertiary)
    }
    
    @ViewBuilder
    private func lastFastDurationView(duration: TimeInterval) -> some View {
        let h = Int(duration) / 3600
        let m = (Int(duration) % 3600) / 60
        let color: Color = entry.lastFastGoalMet == true ? .green : .orange
        
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
    }
}
