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
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Gauge(value: 0.65) {
                                Text("")
                            } currentValueLabel: {
                                Text("08:00")
                                    .font(.system(size: 13, weight: .bold, design: .rounded))
                                    .minimumScaleFactor(0.7)
                            }
                            .gaugeStyle(.accessoryCircularCapacity)
                            .frame(width: 52, height: 52)
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
