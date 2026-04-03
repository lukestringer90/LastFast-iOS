// EndFastPage.swift
// LastFast

import SwiftUI

struct EndFastPage: View {
    var body: some View {
        OnboardingPageView(
            iconName: "stop.circle.fill",
            iconColor: .red,
            title: "End Your Fast",
            description: "Tap Stop Fast whenever you're done. LastFast saves your session to History automatically."
        ) {
            ZStack(alignment: .bottomTrailing) {
                HStack(spacing: 10) {
                    Image(systemName: "square.fill")
                        .font(.body)
                        .foregroundStyle(.white)
                    Text("Stop Fast")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                Image(systemName: "hand.tap.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .padding(8)
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    EndFastPage()
}
