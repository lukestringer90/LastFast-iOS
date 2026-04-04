// OnboardingView.swift
// LastFast
//
// Main onboarding container — shown once on first launch via fullScreenCover

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 8

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentPage) {
                WelcomePage().tag(0)
                StartFastPage().tag(1)
                TrackProgressPage(isActive: currentPage == 2).tag(2)
                GoalAchievedPage().tag(3)
                EndFastPage().tag(4)
                HistoryPage().tag(5)
                NotificationsPage().tag(6)
                WidgetsPage().tag(7)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

            // Skip button — hidden on last page
            if currentPage < totalPages - 1 {
                HStack {
                    Spacer()
                    Button("Skip") {
                        AnalyticsManager.logEvent("onboarding_skipped", parameters: ["page": currentPage])
                        onComplete()
                    }
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 20)
                    .padding(.top, 56)
                    .accessibilityIdentifier("onboardingSkipButton")
                }
            }

            // Next / Get Started button pinned to bottom
            VStack {
                Spacer()
                Button(action: advance) {
                    HStack(spacing: 6) {
                        Text(currentPage == totalPages - 1 ? "Get Started" : "Next")
                        Image(systemName: "chevron.right")
                    }
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.blue)
                }
                .accessibilityIdentifier(currentPage == totalPages - 1 ? "onboardingGetStartedButton" : "onboardingNextButton")
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            UIPageControl.appearance().currentPageIndicatorTintColor = .label
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.label.withAlphaComponent(0.3)
        }
    }

    private func advance() {
        // Request notification permission when leaving the notifications page
        if currentPage == 6 {
            NotificationManager.requestPermission()
        }

        if currentPage == totalPages - 1 {
            AnalyticsManager.logEvent("onboarding_completed")
            onComplete()
        } else {
            withAnimation {
                currentPage += 1
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
