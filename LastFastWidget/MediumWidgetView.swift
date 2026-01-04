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
            historyView
        }
    }
    
    // MARK: - Goal Met View (original style)
    
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
    
    // MARK: - Active View
    
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
    
    // MARK: - History View (inactive state)
    
    private var historyView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if entry.recentFasts.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text("No fasting history")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                Spacer()
                
                Text("Tap to start fasting")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            } else {
                historyGraphView
                
                Text("Tap to start fasting")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            Color(UIColor.secondarySystemBackground)
        }
    }
    
    private var historyGraphView: some View {
        let maxHours: Double = max(1, entry.recentFasts.map { max($0.fastedHours, $0.goalHours) }.max() ?? 1)
        
        return GeometryReader { geo in
            let barWidth = (geo.size.width - CGFloat(entry.recentFasts.count - 1) * 8) / CGFloat(max(1, entry.recentFasts.count))
            let durationLabelHeight: CGFloat = 14
            let dateLabelHeight: CGFloat = 14
            let barAreaHeight = geo.size.height - durationLabelHeight - dateLabelHeight - 4 // 4 for spacing
            
            VStack(spacing: 0) {
                // Duration labels row
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(Array(entry.recentFasts.enumerated()), id: \.element) { index, fast in
                        Text(formatShortDuration(fast.fastedHours))
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: barWidth, height: durationLabelHeight)
                    }
                }
                
                // Bars and goal line area
                ZStack(alignment: .bottom) {
                    // Bars
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(Array(entry.recentFasts.enumerated()), id: \.element) { index, fast in
                            let barHeight = max(4, barAreaHeight * (fast.fastedHours / maxHours))
                            let barColor: Color = fast.goalMet ? .green : .orange
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(barColor)
                                .frame(width: barWidth, height: barHeight)
                        }
                    }
                    
                    // Goal line overlay
                    Path { path in
                        let points = entry.recentFasts.enumerated().compactMap { index, fast -> CGPoint? in
                            guard fast.goalHours > 0 else { return nil }
                            let x = CGFloat(index) * (barWidth + 8) + barWidth / 2
                            let goalHeight = barAreaHeight * (fast.goalHours / maxHours)
                            let y = barAreaHeight - goalHeight
                            return CGPoint(x: x, y: y)
                        }
                        
                        if let first = points.first {
                            path.move(to: first)
                            for point in points.dropFirst() {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    
                    // Goal line dots
                    ForEach(Array(entry.recentFasts.enumerated()), id: \.element) { index, fast in
                        if fast.goalHours > 0 {
                            let x = CGFloat(index) * (barWidth + 8) + barWidth / 2
                            let goalHeight = barAreaHeight * (fast.goalHours / maxHours)
                            let y = barAreaHeight - goalHeight
                            
                            Circle()
                                .fill(Color.primary)
                                .frame(width: 5, height: 5)
                                .position(x: x, y: y)
                        }
                    }
                }
                .frame(height: barAreaHeight)
                
                // Date labels row
                HStack(alignment: .top, spacing: 8) {
                    ForEach(Array(entry.recentFasts.enumerated()), id: \.element) { index, fast in
                        Text(dateLabel(for: fast.startDate))
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth, height: dateLabelHeight)
                    }
                }
                .padding(.top, 2)
            }
        }
        .frame(height: 90)
    }
    
    private func formatShortDuration(_ hours: Double) -> String {
        let totalMinutes = Int(hours * 60)
        let h = totalMinutes / 60
        let m = totalMinutes % 60
        if h > 0 {
            return "\(h)h\(m)m"
        } else {
            return "\(m)m"
        }
    }
    
    private func dateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM"
        return formatter.string(from: date)
    }
}
