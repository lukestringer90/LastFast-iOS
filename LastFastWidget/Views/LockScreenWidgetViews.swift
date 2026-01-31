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
    
    // CORRECTION 1: Use isLuminanceReduced to detect Always On Display
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

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
    
    var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }
    
    var body: some View {
        Group {
            if entry.isActive {
                if goalMet {
                    VStack(spacing: 2) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12, weight: isLuminanceReduced ? .medium : .bold))
                            .foregroundStyle(.green)
                        Text("\(elapsedHours)h")
                            .font(.system(size: 18, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                    }
                    // Optional: The system handles dimming automatically, but you can add your own if needed.
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
                } else {
                    // CORRECTION 2: Use the new boolean to zero out the gauge
                    Gauge(value: isLuminanceReduced ? 0 : progress) {
                        Text("")
                    } currentValueLabel: {
                        if let end = endTime {
                            // Ensure time is static or simple text; avoid timers in AOD
                            Text(end, style: .time)
                                .font(.system(size: 13, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                                .minimumScaleFactor(0.7)
                        }
                    }
                    .gaugeStyle(.accessoryCircularCapacity)
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

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
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32, weight: isLuminanceReduced ? .medium : .bold))
                            .foregroundStyle(.green)

                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        }

                        Spacer()
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
                } else {
                    HStack(spacing: 8) {
                        Gauge(value: isLuminanceReduced ? 0 : progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(end, style: .time)
                                    .font(.system(size: 14, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }

                        Spacer()
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

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
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        }

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32, weight: isLuminanceReduced ? .medium : .bold))
                            .foregroundStyle(.green)
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
                } else {
                    HStack(spacing: 8) {
                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(end, style: .time)
                                    .font(.system(size: 14, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }

                        Gauge(value: isLuminanceReduced ? 0 : progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
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
    @Environment(\.isLuminanceReduced) var isLuminanceReduced

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
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32, weight: isLuminanceReduced ? .medium : .bold))
                            .foregroundStyle(.green)

                        if elapsedHours > 0 {
                            Text("\(elapsedHours)h \(elapsedMins)m")
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        } else {
                            Text("\(elapsedMins)m")
                                .font(.system(size: 24, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                        }
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
                } else {
                    HStack(spacing: 8) {
                        Gauge(value: isLuminanceReduced ? 0 : progress) {
                            Text("")
                        } currentValueLabel: {
                            if hours > 0 {
                                Text("\(hours)h\(minutes)m")
                                    .font(.system(size: 9, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            } else {
                                Text("\(minutes)m")
                                    .font(.system(size: 12, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }
                        .gaugeStyle(.accessoryCircularCapacity)
                        .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("UNTIL")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundStyle(.secondary)
                            if let end = endTime {
                                Text(end, style: .time)
                                    .font(.system(size: 14, weight: isLuminanceReduced ? .medium : .bold, design: .rounded))
                            }
                        }
                    }
                    .opacity(isLuminanceReduced ? 0.5 : 1.0)
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

// MARK: Rectangular Left-Aligned Previews

#Preview("Rect Left - In Progress", as: .accessoryRectangular) {
    RectangularCombinedWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-6 * 3600), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Left - Goal Met", as: .accessoryRectangular) {
    RectangularCombinedWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-18 * 3600 - 30 * 60), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

// MARK: Rectangular Right-Aligned Previews

#Preview("Rect Right - In Progress", as: .accessoryRectangular) {
    RectangularCombinedRightWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-6 * 3600), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Right - Goal Met", as: .accessoryRectangular) {
    RectangularCombinedRightWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-18 * 3600 - 30 * 60), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

// MARK: Rectangular Center-Aligned Previews

#Preview("Rect Center - In Progress", as: .accessoryRectangular) {
    RectangularCombinedCenterWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-6 * 3600), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Center - Goal Met", as: .accessoryRectangular) {
    RectangularCombinedCenterWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: true, startTime: Date().addingTimeInterval(-18 * 3600 - 30 * 60), goalMinutes: 16 * 60, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

// MARK: Inactive State Previews

#Preview("Circular - Inactive", as: .accessoryCircular) {
    LastFastWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: false, startTime: nil, goalMinutes: nil, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Left - Inactive", as: .accessoryRectangular) {
    RectangularCombinedWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: false, startTime: nil, goalMinutes: nil, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Right - Inactive", as: .accessoryRectangular) {
    RectangularCombinedRightWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: false, startTime: nil, goalMinutes: nil, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}

#Preview("Rect Center - Inactive", as: .accessoryRectangular) {
    RectangularCombinedCenterWidget()
} timeline: {
    FastingEntry(date: Date(), isActive: false, startTime: nil, goalMinutes: nil, lastFastDuration: nil, lastFastGoalMet: nil, lastFastStartTime: nil, lastFastEndTime: nil)
}
