// HistoryPage.swift
// LastFast

import SwiftUI

struct HistoryPage: View {
    private struct BarData: Identifiable {
        let id = UUID()
        let label: String
        let fraction: CGFloat
        let goalMet: Bool
        let date: String
    }

    private let bars: [BarData] = [
        BarData(label: "14h", fraction: 0.75, goalMet: false, date: "28/03"),
        BarData(label: "16h", fraction: 0.86, goalMet: true,  date: "29/03"),
        BarData(label: "18h", fraction: 1.00, goalMet: true,  date: "30/03"),
        BarData(label: "14h", fraction: 0.75, goalMet: false,  date: "31/03"),
        BarData(label: "13h", fraction: 0.60, goalMet: false, date: "01/04"),
        BarData(label: "16h", fraction: 0.86, goalMet: true,  date: "02/04"),
    ]

    private let barWidth: CGFloat = 36
    private let barSpacing: CGFloat = 8
    private let barAreaHeight: CGFloat = 100
    // Goal is 16h, max is 18h → 16/18 ≈ 0.89
    private let goalFraction: CGFloat = 15.5 / 18.0

    var body: some View {
        OnboardingPageView(
            iconName: "clock.arrow.circlepath",
            iconColor: .indigo,
            title: "Review Your History",
            description: "Every completed fast is saved. See your progress over time with the history graph."
        ) {
            chartMockup
        }
    }

    private var chartMockup: some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                // Duration labels
                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(bars) { bar in
                        Text(bar.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.primary)
                            .frame(width: barWidth, height: 16)
                    }
                }

                // Bars with goal line overlay
                HStack(alignment: .bottom, spacing: barSpacing) {
                    ForEach(bars) { bar in
                        RoundedRectangle(cornerRadius: 5)
                            .fill((bar.goalMet ? Color.green : Color.orange).opacity(0.6))
                            .frame(width: barWidth, height: bar.fraction * barAreaHeight)
                    }
                }
                .frame(height: barAreaHeight, alignment: .bottom)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color.primary)
                        .frame(height: 1.5)
                        .padding(.bottom, goalFraction * barAreaHeight)
                }

                // Date labels
                HStack(spacing: barSpacing) {
                    ForEach(bars) { bar in
                        Text(bar.date)
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                            .frame(width: barWidth)
                    }
                }
                .padding(.top, 4)
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))

            VStack(spacing: 0) {
                sessionRow(duration: "16h 10m", durationColor: .green, date: "Yesterday")
                Divider()
                    .padding(.leading, 44)
                sessionRow(duration: "13h 30m", durationColor: .orange, date: "2 days ago")
            }
            .cardBackground(padding: 0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func sessionRow(duration: String, durationColor: Color, date: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "clock")
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(duration)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(durationColor)
                Text(date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    HistoryPage()
}
