// OnboardingPageView.swift
// LastFast
//
// Reusable template for onboarding pages

import SwiftUI

struct OnboardingPageView<Mockup: View>: View {
    let iconName: String
    let iconColor: Color
    var imageName: String? = nil
    let title: String
    let description: String
    @ViewBuilder let mockup: () -> Mockup

    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ZStack {
                    if let imageName {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    } else {
                        Circle()
                            .fill(iconColor.opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: iconName)
                            .font(.system(size: 44))
                            .foregroundStyle(iconColor)
                    }
                }
                .scaleEffect(appeared ? 1.0 : 0.8)
                .opacity(appeared ? 1.0 : 0.0)
                .onAppear {
                    withAnimation(.spring(duration: 0.4)) {
                        appeared = true
                    }
                }
                .onDisappear {
                    appeared = false
                }

                VStack(spacing: 12) {
                    Text(title)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    Text(description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                }

                mockup()
                    .padding(.horizontal, 24)

                Spacer(minLength: 120)
            }
            .padding(.top, 60)
            .padding(.horizontal, 16)
        }
    }
}
