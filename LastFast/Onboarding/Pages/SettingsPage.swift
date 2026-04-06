// SettingsPage.swift
// LastFast

import SwiftUI

struct SettingsPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "gear",
            iconColor: .gray,
            title: "Quick Access to Settings",
            description: "Tap the Last Fast title at the top of the screen to open Settings. From there you can manage notifications, view your app version, and replay this introduction."
        ) {
            VStack(spacing: 16) {
                // Mockup of the tappable title
                HStack(spacing: 6) {
                    Image("AppIconDisplay")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                    Text("Last Fast")
                        .font(.headline)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
                .tapHint()

                // Mockup of a settings row
                AppIntroductionRow()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color(.secondarySystemBackground)))
            }
        }
    }
}

#Preview {
    SettingsPage()
}
