//
//  LockScreenWidgetViews.swift
//  LastFastWidget
//
//  Lock Screen widget views (circular and rectangular)
//

import SwiftUI
import WidgetKit

// MARK: - Lock Screen Circular View

struct LockScreenCircularView: View {
    let entry: FastingEntry

    var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
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

    var elapsedHours: Int { Int(currentDuration) / 3600 }
    var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }

    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }

    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    // Goal met: checkmark + hours
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                        Text("\(elapsedHours)h")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                    }
                } else {
                    // Progress: gauge with end time in center
                    Gauge(value: progress) {
                        Text("")
                    } currentValueLabel: {
                        if let end = endTime {
                            Text(format24HourTime(end))
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                }
            } else {
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Lock Screen Rectangular Combined View (Left-Aligned)

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
    
    var hours: Int { remainingMinutes / 60 }
    var minutes: Int { remainingMinutes % 60 }
    var elapsedHours: Int { Int(currentDuration) / 3600 }
    var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
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
                    HStack(spacing: 8) {
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
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Lock Screen Rectangular Combined View (Right-Aligned)

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
    
    var hours: Int { remainingMinutes / 60 }
    var minutes: Int { remainingMinutes % 60 }
    var elapsedHours: Int { Int(currentDuration) / 3600 }
    var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
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
                    HStack(spacing: 8) {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(format24HourTime(end))
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                            }
                        }
                        
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
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Lock Screen Rectangular Combined View (Center-Aligned)

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
    
    var hours: Int { remainingMinutes / 60 }
    var minutes: Int { remainingMinutes % 60 }
    var elapsedHours: Int { Int(currentDuration) / 3600 }
    var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
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
                    HStack(spacing: 8) {
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
                Color.clear
            }
        }
        .containerBackground(for: .widget) { }
    }
}

// MARK: - Previews

#Preview("Circular - In Progress", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-10 * 3600), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Circular - Goal Met", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-18 * 3600 - 30 * 60), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rectangular - In Progress", as: .accessoryRectangular) {
    RectangularCombinedWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-6 * 3600), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}
