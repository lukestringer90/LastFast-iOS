//
//  GoalStatusIcon.swift
//  LastFast
//
//  Reusable goal status icon component
//

import SwiftUI

// MARK: - Goal Status Icon

struct GoalStatusIcon: View {
    let goalMet: Bool
    var font: Font = .subheadline

    var body: some View {
        Image(systemName: GoalStatusColors.iconSystemName(goalMet: goalMet))
            .foregroundStyle(GoalStatusColors.iconColor(goalMet: goalMet))
            .font(font)
    }
}

// MARK: - Preview

#Preview("Goal Met") {
    GoalStatusIcon(goalMet: true)
}

#Preview("Goal Not Met") {
    GoalStatusIcon(goalMet: false)
}
