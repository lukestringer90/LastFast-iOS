// GoalAchievedPage.swift
// LastFast

import SwiftUI

struct GoalAchievedPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "checkmark.seal.fill",
            iconColor: .green,
            title: "Goal Achieved!",
            description: "When you hit your goal, the ring turns green and a celebration fires. Keep going or end your fast — it's up to you."
        ) {
            VStack(spacing: 16) {
                ZStack {
                    // Confetti dots
                    ForEach(confettiItems, id: \.id) { item in
                        Circle()
                            .fill(item.color)
                            .frame(width: item.size, height: item.size)
                            .offset(x: item.x, y: item.y)
                    }

                    Circle()
                        .stroke(Color.green.opacity(0.2), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: 1.0)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("YOU'VE FASTED FOR")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("16h 12m")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(.green)
                    }
                }
                .frame(width: 200, height: 200)

                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Goal: 16h")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.green)
                }
            }
            .frame(maxWidth: .infinity)
            .cardBackground()
        }
    }

    private struct ConfettiItem {
        let id: Int
        let color: Color
        let size: CGFloat
        let x: CGFloat
        let y: CGFloat
    }

    private let confettiItems: [ConfettiItem] = [
        ConfettiItem(id: 0, color: .green, size: 10, x: -100, y: -79),
        ConfettiItem(id: 1, color: .mint, size: 8, x: 93, y: -71),
        ConfettiItem(id: 2, color: .teal, size: 12, x: -86, y: 79),
        ConfettiItem(id: 3, color: .green.opacity(0.6), size: 7, x: 100, y: 71),
        ConfettiItem(id: 4, color: .mint, size: 9, x: 0, y: -107),
    ]
}

#Preview {
    GoalAchievedPage()
}
