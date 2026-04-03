// GoalAchievedPage.swift
// LastFast

import SwiftUI

struct GoalAchievedPage: View {
    @State private var showConfetti = false

    var body: some View {
        OnboardingPageView(
            iconName: "checkmark.seal.fill",
            iconColor: .green,
            title: "Goal Achieved!",
            description: "When you hit your goal, the ring turns green and a celebration fires. Keep going or end your fast — it's up to you."
        ) {
            VStack(spacing: 16) {
                ZStack {
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
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay {
                if showConfetti {
                    ConfettiView(id: UUID(), onComplete: nil)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.0))
            showConfetti = true
        }
        .onDisappear {
            showConfetti = false
        }
    }
}

#Preview {
    GoalAchievedPage()
}
