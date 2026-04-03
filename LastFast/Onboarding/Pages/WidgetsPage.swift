// WidgetsPage.swift
// LastFast

import SwiftUI

struct WidgetsPage: View {
    @State private var progress: CGFloat = 0.5

    var body: some View {
        OnboardingPageView(
            iconName: "rectangle.stack.fill",
            iconColor: .indigo,
            title: "Widgets Everywhere",
            description: "Add Last Fast to your Home Screen or Lock Screen to check your fast at a glance — no need to open the app."
        ) {
            HStack(alignment: .top, spacing: 16) {
                // Home Screen widget
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(.systemBackground))
                        .frame(width: 130, height: 130)
                        .overlay(
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.orange.opacity(0.3), lineWidth: 6)
                                RoundedRectangle(cornerRadius: 20)
                                    .trim(from: 0, to: progress)
                                    .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                VStack(spacing: 2) {
                                    Text("FAST UNTIL")
                                        .font(.system(size: 10, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                    Text("08:00")
                                        .font(.system(size: 30, weight: .bold, design: .rounded))
                                        .foregroundStyle(.orange)
                                        .minimumScaleFactor(0.5)
                                        .lineLimit(1)
                                    Text("Goal: 16h")
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(8)
                            }
                            .padding(8)
                        )

                    Text("Home Screen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Lock Screen widget
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 80, height: 80)
                        .overlay(
                            ZStack {
                                Circle()
                                    .stroke(Color.primary.opacity(0.2), lineWidth: 6)
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                    .rotationEffect(.degrees(-90))
                                Text("08:00")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(width: 52, height: 52)
                        )

                    Text("Lock Screen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .onAppear { progress = 0.5 }
            .onDisappear { progress = 0.5 }
            .task {
                try? await Task.sleep(for: .seconds(1.0))
                withAnimation(.easeInOut(duration: 1.5)) { progress = 0.75 }
            }
        }
    }
}

#Preview {
    WidgetsPage()
}
