//
//  NotFastingView.swift
//  LastFast
//
//  View displayed when user is not currently fasting
//

import SwiftUI

struct NotFastingView: View {
    let savedGoalMinutes: Int
    var onStartFast: () -> Void
    var onShowGoalPicker: () -> Void
    var onShowHistory: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            GoalSetterView(
                savedGoalMinutes: savedGoalMinutes,
                onTap: onShowGoalPicker
            )
            .transition(.opacity)

            Spacer()

            FastingActionButton(isActive: false, onTap: onStartFast)
                .padding(.bottom, 24)

            HistoryButton(onTap: onShowHistory)
                .padding(.bottom, 40)
        }
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    NotFastingView(
        savedGoalMinutes: 720,
        onStartFast: {},
        onShowGoalPicker: {},
        onShowHistory: {}
    )
}

#Preview("Dark Mode") {
    NotFastingView(
        savedGoalMinutes: 720,
        onStartFast: {},
        onShowGoalPicker: {},
        onShowHistory: {}
    )
    .preferredColorScheme(.dark)
}
