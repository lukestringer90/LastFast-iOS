// OnboardingUITests.swift
// LastFastUITests
//
// UI tests for onboarding flow

import XCTest

final class OnboardingUITests: XCTestCase {

    var app: XCUIApplication!
    private let totalPages = 8

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--show-onboarding", "--clear-data", "--ui-test-goal", "1"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Helpers

    private var nextButton: XCUIElement { app.buttons["onboardingNextButton"] }
    private var getStartedButton: XCUIElement { app.buttons["onboardingGetStartedButton"] }
    private var skipButton: XCUIElement { app.buttons["onboardingSkipButton"] }
    private var fastGoalLabel: XCUIElement { app.staticTexts["fastGoalLabel"] }

    // MARK: - Scenario 1: Tap Next through all pages, then Get Started

    /// Taps Next on every page to advance through the full onboarding flow,
    /// then taps Get Started on the last page and verifies the main app appears.
    func testTapNextThroughAllPagesAndGetStartedDismissesOnboarding() throws {
        app.launch()

        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Onboarding should be visible with Next button")
        XCTAssertTrue(skipButton.exists, "Skip button should be visible on the first page")

        // Tap Next through pages 0–6
        for page in 0..<(totalPages - 1) {
            XCTAssertTrue(nextButton.waitForExistence(timeout: 3), "Next button should exist on page \(page)")
            nextButton.tap()

            // Dismiss any system alerts (e.g. notification permission triggered on page 6)
            let alert = app.alerts.firstMatch
            if alert.waitForExistence(timeout: 1) {
                alert.buttons.firstMatch.tap()
            }
        }

        // Last page: Get Started visible, Skip hidden
        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 3), "Get Started should be visible on the last page")
        XCTAssertFalse(skipButton.exists, "Skip button should not be visible on the last page")

        getStartedButton.tap()

        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Main app should be visible after tapping Get Started")
    }

    // MARK: - Scenario 2: Swipe through all pages, then Get Started

    /// Swipes left through all onboarding pages, then taps Get Started and
    /// verifies the main app appears.
    func testSwipeThroughAllPagesAndGetStartedDismissesOnboarding() throws {
        app.launch()

        XCTAssertTrue(nextButton.waitForExistence(timeout: 5), "Onboarding should be visible")

        // Swipe left through pages 0–6
        for _ in 0..<(totalPages - 1) {
            app.swipeLeft()
        }

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 3), "Get Started should be visible after swiping to last page")

        getStartedButton.tap()

        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Main app should be visible after tapping Get Started")
    }

    // MARK: - Scenario 3: Skip button dismisses onboarding

    /// Taps Skip on the first page and verifies the main app is shown immediately.
    func testSkipButtonDismissesOnboarding() throws {
        app.launch()

        XCTAssertTrue(skipButton.waitForExistence(timeout: 5), "Skip button should be visible")

        skipButton.tap()

        XCTAssertTrue(fastGoalLabel.waitForExistence(timeout: 5), "Main app should be visible after tapping Skip")
    }

    // MARK: - Scenario 4: Skip hidden on last page, Get Started visible

    /// Navigates to the last onboarding page and verifies the Skip button is
    /// hidden while the Get Started button is visible.
    func testSkipButtonHiddenOnLastPage() throws {
        app.launch()

        XCTAssertTrue(skipButton.waitForExistence(timeout: 5), "Skip should be visible on the first page")
        XCTAssertFalse(getStartedButton.exists, "Get Started should not be visible on the first page")

        // Swipe to the last page
        for _ in 0..<(totalPages - 1) {
            app.swipeLeft()
        }

        XCTAssertTrue(getStartedButton.waitForExistence(timeout: 3), "Get Started should be visible on the last page")
        XCTAssertFalse(skipButton.exists, "Skip should not be visible on the last page")
    }
}
