// OnboardingView.swift
// LastFast
//
// Main onboarding container — shown once on first launch via fullScreenCover

import SwiftUI

struct OnboardingView: View {
    var onComplete: () -> Void

    @State private var currentPage = 0
    private let totalPages = 10

    var body: some View {
        ZStack(alignment: .top) {
            TabView(selection: $currentPage) {
                WelcomePage().tag(0)
                StartFastPage().tag(1)
                TrackProgressPage(isActive: currentPage == 2).tag(2)
                GoalAchievedPage().tag(3)
                EndFastPage().tag(4)
                HistoryPage().tag(5)
                WidgetsPage().tag(6)
                NotificationsPage().tag(7)
                PrivacyPage().tag(8)
                SettingsPage().tag(9)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .animation(.easeInOut, value: currentPage)

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
            AnalyticsManager.logEvent("onboarding_viewed")
        }
    }

    private func advance() {
        // On the notifications page, request permission first and only advance once the alert is dismissed
        if currentPage == 7 {
            NotificationManager.requestPermission { advancePage() }
            return
        }
        // On the privacy page, request ATT tracking permission before advancing
        if currentPage == 8 {
            AnalyticsManager.requestTrackingPermission { advancePage() }
            return
        }
        advancePage()
    }

    private func advancePage() {
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
