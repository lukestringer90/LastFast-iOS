// StartFastPage.swift
// LastFast

import SwiftUI

struct StartFastPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "play.circle.fill",
            iconColor: .green,
            title: "Start Your Fast",
            description: "When you're ready, tap Start Fast. LastFast begins tracking your elapsed time against your goal immediately."
        ) {
            HStack(spacing: 10) {
                Image(systemName: "play.fill")
                    .font(.body)
                    .foregroundStyle(.white)
                Text("Start Fast")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.green)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .tapHint()
        }
    }
}

#Preview {
    StartFastPage()
}
