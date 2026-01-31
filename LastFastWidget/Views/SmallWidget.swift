//
//  SmallWidget.swift
//  LastFastWidget
//
//  Small Home Screen widget with circular progress
//

import SwiftUI
import WidgetKit

// MARK: - Small Widget View

struct SmallEndTimeWidgetView: View {
    let entry: FastingEntry

    private var currentDuration: TimeInterval {
        guard let start = entry.startTime else { return 0 }
        return entry.date.timeIntervalSince(start)
    }

    private var elapsedHours: Int { Int(currentDuration) / 3600 }
    private var elapsedMins: Int { (Int(currentDuration) % 3600) / 60 }

    private var remainingMinutes: Int {
        guard let goal = entry.goalMinutes else { return 0 }
        let elapsedMinutes = Int(currentDuration) / 60
        return max(0, goal - elapsedMinutes)
    }

    private var remainingHours: Int { remainingMinutes / 60 }
    private var remainingMins: Int { remainingMinutes % 60 }

    private var progress: Double {
        guard let goal = entry.goalMinutes, goal > 0 else { return 0 }
        let elapsedMinutes = currentDuration / 60
        return min(1.0, elapsedMinutes / Double(goal))
    }

    private var goalMet: Bool {
        guard let goal = entry.goalMinutes else { return false }
        return Int(currentDuration) / 60 >= goal
    }

    private var endTime: Date? {
        guard let goal = entry.goalMinutes, let start = entry.startTime else { return nil }
        return start.addingTimeInterval(TimeInterval(goal * 60))
    }

    private var ringColor: Color {
        goalMet ? .green : .orange
    }

    var body: some View {
        Group {
            if entry.isActive {
                activeView
            } else {
                inactiveView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(.systemBackground)
        }
    }

    // MARK: - Active View

    private var activeView: some View {
        GeometryReader { geometry in
            let lineWidth: CGFloat = 6
            let cornerRadius: CGFloat = 20

            ZStack {
                // Background ring (only when goal not met)
                if !goalMet {
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(ringColor.opacity(0.3), lineWidth: lineWidth)

                    // Progress ring
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .trim(from: 0, to: progress)
                        .stroke(ringColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                }

                // Center content
                VStack(spacing: 4) {
                    if goalMet {
                        // Goal met: show elapsed time on separate lines
                        subtitleLabel("GOAL MET 🎉")
                        verticalTimeDisplay(hours: elapsedHours, minutes: elapsedMins, color: .green)
                    } else {
                        // In progress: show end time
                        subtitleLabel("FAST UNTIL")
                        if let end = endTime {
                            Text(format24HourTime(end))
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundStyle(.orange)
                                .minimumScaleFactor(0.5)
                                .lineLimit(1)
                        }
                        if let goal = entry.goalMinutes {
                            supplementaryLabel("Goal: \(formatDuration(hours: goal / 60, minutes: goal % 60))")
                        }
                    }
                }
                .padding(8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    // MARK: - Standardized Labels

    private func subtitleLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.secondary)
    }

    private func primaryLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 44, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
    }

    private func supplementaryLabel(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.secondary)
    }

    private func supplementaryLabel(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(color)
    }

    // MARK: - Time Display

    private func formatDuration(hours: Int, minutes: Int) -> String {
        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        } else if hours > 0 {
            return "\(hours)h"
        } else {
            return "\(minutes)m"
        }
    }

    @ViewBuilder
    private func timeDisplay(hours: Int, minutes: Int, color: Color) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            if hours > 0 {
                Text("\(hours)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("h")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            if minutes > 0 {
                Text("\(minutes)")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("m")
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }

    @ViewBuilder
    private func verticalTimeDisplay(hours: Int, minutes: Int, color: Color) -> some View {
        VStack(spacing: -8) {
            if hours > 0 {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(hours)")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(color)
                    Text("hours")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(color.opacity(0.7))
                }
                .monospacedDigit()
            }
            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(minutes)")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(color)
                Text("mins")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(color.opacity(0.7))
            }
            .monospacedDigit()
        }
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }

    // MARK: - Inactive View

    private var savedGoalHours: Int { entry.savedGoalMinutes / 60 }
    private var savedGoalMins: Int { entry.savedGoalMinutes % 60 }

    private var inactiveView: some View {
        VStack(spacing: 4) {
            subtitleLabel("FAST GOAL")

            // Goal length as primary text in blue
            timeDisplay(hours: savedGoalHours, minutes: savedGoalMins, color: .blue)

            if let duration = entry.lastFastDuration {
                let h = Int(duration) / 3600
                let m = (Int(duration) % 3600) / 60
                let lastGoalMet = entry.lastFastGoalMet == true
                let lastFastColor: Color = lastGoalMet ? .green : .orange

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 13))
                        .foregroundStyle(lastFastColor)

                    supplementaryLabel(formatDuration(hours: h, minutes: m), color: lastFastColor)
                }
            }
        }
    }
}

// MARK: - End Time Widget Configuration

struct SmallWidget: Widget {
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

// MARK: - Previews

#Preview("Active - In Progress", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: true,
        startTime: Date.now.addingTimeInterval(-6 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Active - Almost Done", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: true,
        startTime: Date.now.addingTimeInterval(-15.5 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Active - Goal Met", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: true,
        startTime: Date.now.addingTimeInterval(-18 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

#Preview("Inactive - With History", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: false,
        startTime: nil,
        goalMinutes: nil,
        lastFastDuration: 16.1 * 3600,
        lastFastGoalMet: true,
        lastFastStartTime: Date.now.addingTimeInterval(-20 * 3600),
        lastFastEndTime: Date.now.addingTimeInterval(-4 * 3600)
    )
}

#Preview("Inactive - Goal Not Met", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: false,
        startTime: nil,
        goalMinutes: nil,
        lastFastDuration: 12.5 * 3600,
        lastFastGoalMet: false,
        lastFastStartTime: Date.now.addingTimeInterval(-16 * 3600),
        lastFastEndTime: Date.now.addingTimeInterval(-4 * 3600)
    )
}

#Preview("Inactive - No History", as: .systemSmall) {
    SmallWidget()
} timeline: {
    FastingEntry(
        date: .now,
        isActive: false,
        startTime: nil,
        goalMinutes: nil,
        lastFastDuration: nil,
        lastFastGoalMet: nil,
        lastFastStartTime: nil,
        lastFastEndTime: nil
    )
}

