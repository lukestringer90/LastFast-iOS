// TrackProgressPage.swift
// LastFast

import SwiftUI

struct TrackProgressPage: View {
    var isActive: Bool = false
    @State private var progress: CGFloat = 0.5

    var body: some View {
        OnboardingPageView(
            iconName: "chart.line.uptrend.xyaxis",
            iconColor: .orange,
            title: "Track Your Progress",
            description: "Watch the progress ring fill as you fast. The countdown shows how long until your goal is met."
        ) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .stroke(Color.orange.opacity(0.2), lineWidth: 10)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 2) {
                        Text("FAST UNTIL")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.secondary)
                            .tracking(1)
                        Text("08:30")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                    }
                }
                .frame(width: 200, height: 200)

                Text("Goal: 16h")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.orange)
            }
            .frame(maxWidth: .infinity)
            .cardBackground()
            .task(id: isActive) {
                withAnimation(.none) { progress = 0.5 }
                guard isActive else { return }
                try? await Task.sleep(for: .seconds(1.0))
                withAnimation(.easeInOut(duration: 1.5)) { progress = 0.75 }
            }
        }
    }
}

#Preview {
    TrackProgressPage()
}
