//
//  NotFastingView.swift
//  LastFast
//
//  View displayed when user is not currently fasting
//

import SwiftUI

struct NotFastingView: View {
    let savedGoalMinutes: Int
    let currentTime: Date
    let lastFast: FastingSession?
    var onStartFast: () -> Void
    var onShowGoalPicker: () -> Void
    var onShowHistory: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                GoalSetterView(
                    savedGoalMinutes: savedGoalMinutes,
                    currentTime: currentTime,
                    onTap: onShowGoalPicker
                )
                .transition(.opacity)

                FastingActionButton(isActive: false, onTap: onStartFast)
            }

            Spacer()

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
    NotFastingView(
        savedGoalMinutes: 720,
        currentTime: Date(),
        lastFast: nil,
        onStartFast: {},
        onShowGoalPicker: {},
        onShowHistory: {}
    )
}
