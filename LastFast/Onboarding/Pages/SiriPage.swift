// SiriPage.swift
// LastFast

import SwiftUI

struct SiriPage: View {
    private let phrases = [
        "Hey Siri, start a 16-hour fast",
        "Hey Siri, stop my fast",
        "Hey Siri, how long have I been fasting?"
    ]

    var body: some View {
        OnboardingPageView(
            iconName: "mic.fill",
            iconColor: .purple,
            title: "Siri Shortcuts",
            description: "Ask Siri to start or stop your fast, or check your progress — hands-free, any time."
        ) {
            VStack(spacing: 0) {
                ForEach(Array(phrases.enumerated()), id: \.offset) { index, phrase in
                    HStack(spacing: 12) {
                        Image(systemName: "mic.fill")
                            .font(.body)
                            .foregroundStyle(.purple)
                            .frame(width: 24)

                        Text(phrase)
                            .font(.subheadline)
                            .foregroundStyle(.primary)

                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    if index < phrases.count - 1 {
                        Divider()
                            .padding(.leading, 52)
                    }
                }
            }
            .cardBackground(padding: 0)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    SiriPage()
}
