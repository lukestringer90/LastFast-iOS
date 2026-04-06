// PrivacyPage.swift
// LastFast

import SwiftUI

struct PrivacyPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "hand.raised.fill",
            iconColor: .purple,
            title: "Help Improve Last Fast",
            description: "On the next screen, iOS will ask if Last Fast can use anonymous data to understand how the app is used. No personal data is ever shared, and you can change this at any time in Settings."
        ) {
            VStack(alignment: .leading, spacing: 12) {
                privacyRow(icon: "chart.bar.fill", color: .purple, text: "Crash reports and usage patterns only")
                privacyRow(icon: "person.slash.fill", color: .purple, text: "Never linked to your identity")
                privacyRow(icon: "gear", color: .purple, text: "Change your mind anytime in iOS Settings")
            }
            .padding(16)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
        }
    }

    private func privacyRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    PrivacyPage()
}
