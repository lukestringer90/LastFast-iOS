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
    let activeFast: FastingSession?
    let lastFast: FastingSession?
    var onStopFast: () -> Void
    var onShowHistory: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            TimerDisplayView(
                goalMet: goalMet,
                hours: hours,
                minutes: minutes,
                elapsedHours: elapsedHours,
                elapsedMins: elapsedMins,
                progress: progress
            )
            .transition(.opacity.combined(with: .scale(scale: 0.8)))

            GoalAndStartTimeView(
                goalMet: goalMet,
                elapsedHours: elapsedHours,
                elapsedMins: elapsedMins,
                activeFast: activeFast
            )
            .padding(.top, 24)
            .transition(.opacity.combined(with: .move(edge: .top)))

            Spacer()

            FastingActionButton(isActive: true, onTap: onStopFast)

            Button(action: onShowHistory) {
                LastFastButtonContent(lastFast: lastFast)
            }
            .padding(.top, 16)

            HistoryButton(onTap: onShowHistory)
                .padding(.top, 12)
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Preview

#Preview {
    ActiveFastingView(
        goalMet: false,
        hours: 8,
        minutes: 30,
        elapsedHours: 3,
        elapsedMins: 30,
        progress: 0.45,
        activeFast: nil,
        lastFast: nil,
        onStopFast: {},
        onShowHistory: {}
    )
}
