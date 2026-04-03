// WidgetsPage.swift
// LastFast

import SwiftUI

struct WidgetsPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "rectangle.stack.fill",
            iconColor: .indigo,
            title: "Widgets Everywhere",
            description: "Add LastFast to your Home Screen or Lock Screen to check your fast at a glance — no need to open the app."
        ) {
            HStack(alignment: .top, spacing: 16) {
                // Home Screen widget
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 130, height: 130)
                        .overlay(
                            VStack(spacing: 6) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.orange.opacity(0.2), lineWidth: 6)
                                    Circle()
                                        .trim(from: 0, to: 0.65)
                                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                    Text("08:30")
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .foregroundStyle(.orange)
                                }
                                .frame(width: 70, height: 70)

                                Text("LastFast")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.secondary)
                            }
                        )

                    Text("Home Screen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Lock Screen widget
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 90, height: 44)
                        .overlay(
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .stroke(Color.orange.opacity(0.25), lineWidth: 3)
                                    Circle()
                                        .trim(from: 0, to: 0.65)
                                        .stroke(Color.orange, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                        .rotationEffect(.degrees(-90))
                                }
                                .frame(width: 22, height: 22)

                                Text("08:30")
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .foregroundStyle(.orange)
                            }
                        )

                    Text("Lock Screen")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}

#Preview {
    WidgetsPage()
}
