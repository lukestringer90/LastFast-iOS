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
                Text("FASTED FOR \(elapsedHours)h \(elapsedMins)m")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            }
            
            Text("\(elapsedHours)h \(elapsedMins)m")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundStyle(.green)
        }
        .padding(16)
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var activeView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text("KEEP FASTING FOR")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                if let start = entry.startTime {
                    Text("\(format24HourTime(start)) TO")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(alignment: .firstTextBaseline) {
                Text("\(remainingHours)h \(remainingMins)m")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.orange)
                
                Spacer()
                
                if let start = entry.startTime, let goal = entry.goalMinutes {
                    let endTime = start.addingTimeInterval(TimeInterval(goal * 60))
                    Text(format24HourTime(endTime))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
            
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
    
    private var inactiveView: some View {
        VStack(spacing: 6) {
            Text("Last Fast")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            
            if let duration = entry.lastFastDuration {
                let h = Int(duration) / 3600
                let m = (Int(duration) % 3600) / 60
                let color: Color = entry.lastFastGoalMet == true ? .green : .orange
                
                HStack(spacing: 4) {
                    if h > 0 {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(h)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("h")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
                            Text("\(m)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("m")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
                        }
                    } else {
                        HStack(alignment: .firstTextBaseline, spacing: 1) {
                            Text("\(m)")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(color)
                            Text("m")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(color.opacity(0.7))
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
