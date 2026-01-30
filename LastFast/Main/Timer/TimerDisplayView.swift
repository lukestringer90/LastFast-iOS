//
//  TimerDisplayView.swift
//  LastFast
//
//  View for displaying the main countdown/elapsed timer
//

import SwiftUI

// MARK: - Timer Display View

struct TimerDisplayView: View {
    let goalMet: Bool
    let hours: Int          // Remaining hours (for active state)
    let minutes: Int        // Remaining minutes (for active state)
    let elapsedHours: Int
    let elapsedMins: Int
    let progress: Double
    let startTime: Date?
    let endTime: Date?
    var onElapsedTimeTapped: (() -> Void)? = nil

    private var ringColor: Color {
        goalMet ? .green : .orange
    }

    var body: some View {
        ZStack {
            // Invisible circle to maintain consistent layout
            Circle()
                .stroke(Color.clear, lineWidth: 12)

            if !goalMet {
                // Background ring (only show when goal not met)
                Circle()
                    .stroke(ringColor.opacity(0.3), lineWidth: 12)

                // Progress ring
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(ringColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }

            // Time display and info label in center
            VStack(spacing: 4) {
                timeDisplay
                infoLabel
            }
            .padding(20)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }

    // MARK: - Time Display

    @ViewBuilder
    private var timeDisplay: some View {
        if goalMet {
            elapsedTimeDisplay
        } else if hours > 0 {
            hoursAndMinutesDisplay
        } else {
            minutesOnlyDisplay
        }
    }

    private var elapsedTimeDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(elapsedHours)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.green)

            Text("h")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.green.opacity(0.7))

            Text("\(elapsedMins)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.green)

            Text("m")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.green.opacity(0.7))
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
        .contentShape(Rectangle())
        .onTapGesture {
            onElapsedTimeTapped?()
        }
    }

    private var hoursAndMinutesDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(hours)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)

            Text("h")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))

            Text("\(minutes)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)

            Text("m")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }

    private var minutesOnlyDisplay: some View {
        HStack(alignment: .firstTextBaseline, spacing: 4) {
            Text("\(minutes)")
                .font(.system(size: 96, weight: .bold, design: .rounded))
                .foregroundStyle(.orange)

            Text("m")
                .font(.system(size: 36, weight: .medium, design: .rounded))
                .foregroundStyle(.orange.opacity(0.7))
        }
        .monospacedDigit()
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }

    // MARK: - Info Label

    private var infoLabel: some View {
        Group {
            if goalMet {
                if let start = startTime {
                    Text("Started: \(formatTime(start))")
                } else {
                    Text("Started: --:--")
                }
            } else {
                if let end = endTime {
                    Text("Ends: \(formatTime(end))")
                } else {
                    Text("Ends: --:--")
                }
            }
        }
        .font(.title3)
        .fontWeight(.medium)
        .foregroundStyle(goalMet ? .green.opacity(0.8) : .orange.opacity(0.8))
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }

}

// MARK: - Preview

#Preview("Active - In Progress") {
    TimerDisplayView(
        goalMet: false,
        hours: 8,
        minutes: 30,
        elapsedHours: 7,
        elapsedMins: 30,
        progress: 0.47,
        startTime: Date().addingTimeInterval(-7.5 * 3600),
        endTime: Date().addingTimeInterval(8.5 * 3600)
    )
}

#Preview("Goal Met") {
    TimerDisplayView(
        goalMet: true,
        hours: 0,
        minutes: 0,
        elapsedHours: 16,
        elapsedMins: 5,
        progress: 1.0,
        startTime: Date().addingTimeInterval(-16.1 * 3600),
        endTime: nil
    )
}
