//
//  MediumWidgetView.swift
//  LastFastWidget
//
//  Medium Home Screen widget view
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
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
    
    var body: some View {
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
    
    private var goalMetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("FASTED FOR")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            }
            
            Text("\(elapsedHours)h \(elapsedMins)m")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var activeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Top row: countdown on left, end time info on right
            HStack(alignment: .top) {
                // Left side: Large countdown time
                if remainingHours > 0 {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(remainingHours)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("h")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text("\(remainingMins)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("m")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .minimumScaleFactor(0.6)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(remainingMins)")
                            .font(.system(size: 64, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                        Text("m")
                            .font(.system(size: 28, weight: .medium, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .minimumScaleFactor(0.6)
                }
                
                Spacer()
                
                // Right side: Start time to / End time
                if let start = entry.startTime, let goal = entry.goalMinutes {
                    let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(format24HourTime(start)) to")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Text(format24HourTime(endTime))
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                }
            }
            
            // Full width progress bar
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
            
            // Centered elapsed time below progress bar
            HStack {
                Spacer()
                Text("Fasted for \(elapsedHours)h \(elapsedMins)m")
                    .font(.caption)
                    .foregroundStyle(.white)
                Spacer()
            }
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var inactiveView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LAST 5 DAYS")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
            
            if entry.recentHistory.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No fasting history")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Spacer()
            } else {
                // Bar graph
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(entry.recentHistory, id: \.self) { day in
                        VStack(spacing: 4) {
                            // Bar
                            barView(for: day)
                            
                            // Day label
                            Text(dayLabel(for: day.date))
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            Text("Tap to start fasting")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }
    
    @ViewBuilder
    private func barView(for day: DayFastingData) -> some View {
        let maxHours: Double = 24
        let heightRatio = min(1.0, day.totalFastedHours / maxHours)
        let barColor: Color = day.goalMet ? .green : .orange
        
        GeometryReader { geo in
            VStack {
                Spacer()
                
                if day.totalFastedHours > 0 {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(barColor)
                        .frame(height: max(4, geo.size.height * heightRatio))
                } else {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
    
    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
