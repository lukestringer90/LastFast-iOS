//
//  ActiveFastingView.swift
//  LastFast
//
//  View displayed when user is actively fasting
//

import SwiftUI

struct ActiveFastingView: View {
    let goalMet: Bool
    let hours: Int
    let minutes: Int
    let elapsedHours: Int
    let elapsedMins: Int
    let progress: Double
    let startTime: Date?
    let endTime: Date?
    let goalMinutes: Int?
    let lastFastDuration: TimeInterval?
    var onStopFast: () -> Void
    var onShowHistory: () -> Void
    var onCelebrate: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            TimerDisplayView(
                goalMet: goalMet,
                hours: hours,
                minutes: minutes,
                elapsedHours: elapsedHours,
                elapsedMins: elapsedMins,
                progress: progress,
                startTime: startTime,
                endTime: endTime,
                goalMinutes: goalMinutes,
                onElapsedTimeTapped: onCelebrate
            )
            .transition(.opacity.combined(with: .scale(scale: 0.8)))

            Spacer()

            FastingActionButton(isActive: true, onTap: onStopFast)
                .padding(.bottom, 24)

            HistoryButton(lastFastDuration: lastFastDuration, onTap: onShowHistory)
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Preview

#Preview("In Progress - Light") {
    ActiveFastingView(
        goalMet: false,
        hours: 8,
        minutes: 30,
        elapsedHours: 3,
        elapsedMins: 30,
        progress: 0.45,
        startTime: Date().addingTimeInterval(-3.5 * 3600),
        endTime: Date().addingTimeInterval(8.5 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
}

#Preview("In Progress - Dark") {
    ActiveFastingView(
        goalMet: false,
        hours: 8,
        minutes: 30,
        elapsedHours: 3,
        elapsedMins: 30,
        progress: 0.45,
        startTime: Date().addingTimeInterval(-3.5 * 3600),
        endTime: Date().addingTimeInterval(8.5 * 3600),
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
    .preferredColorScheme(.dark)
}

#Preview("Goal Met - Light") {
    ActiveFastingView(
        goalMet: true,
        hours: 0,
        minutes: 0,
        elapsedHours: 16,
        elapsedMins: 5,
        progress: 1.0,
        startTime: Date().addingTimeInterval(-16.1 * 3600),
        endTime: nil,
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
}

#Preview("Goal Met - Dark") {
    ActiveFastingView(
        goalMet: true,
        hours: 0,
        minutes: 0,
        elapsedHours: 16,
        elapsedMins: 5,
        progress: 1.0,
        startTime: Date().addingTimeInterval(-16.1 * 3600),
        endTime: nil,
        goalMinutes: 16 * 60,
        lastFastDuration: 14.5 * 3600,
        onStopFast: {},
        onShowHistory: {}
    )
    .preferredColorScheme(.dark)
}
