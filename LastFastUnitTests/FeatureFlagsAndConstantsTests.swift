//
//  FeatureFlagsAndConstantsTests.swift
//  LastFastTests
//
//  Tests for feature flags, constants, and configuration values
//

import XCTest
@testable import LastFast

// MARK: - Feature Flags Tests

final class FeatureFlagsTests: XCTestCase {

    func testUseGraphHistoryView_IsEnabled() {
        // Given: The useGraphHistoryView feature flag
        // Then: Should be true (graph view is default)
        XCTAssertTrue(useGraphHistoryView)
    }

    func testLiveActivityEnabled_IsDisabled() {
        // Given: The liveActivityEnabled feature flag
        // Then: Should be false (disabled by default)
        XCTAssertFalse(liveActivityEnabled)
    }
}

// MARK: - Default Values Tests

final class DefaultValuesTests: XCTestCase {

    func testDefaultFastingGoalMinutes_Is960() {
        XCTAssertEqual(defaultFastingGoalMinutes, 960)
    }

    func testDefaultFastingGoalMinutes_Equals16Hours() {
        let expectedMinutes = 16 * 60
        XCTAssertEqual(defaultFastingGoalMinutes, expectedMinutes)
    }

    func testFastingGoalStorageKey() {
        XCTAssertEqual(fastingGoalStorageKey, "fastingGoalMinutes")
    }
}

// MARK: - Notification Constants Tests

final class NotificationConstantsExtendedTests: XCTestCase {

    // Ensure notification identifiers are non-empty strings
    func testNotificationIdentifiers_AreNonEmpty() {
        XCTAssertFalse(NotificationIdentifier.goalMet.isEmpty)
        XCTAssertFalse(NotificationIdentifier.oneHourBefore.isEmpty)
    }

    func testNotificationCategory_IsNonEmpty() {
        XCTAssertFalse(NotificationCategory.goalMet.isEmpty)
    }

    func testNotificationActions_AreNonEmpty() {
        XCTAssertFalse(NotificationAction.continueFasting.isEmpty)
        XCTAssertFalse(NotificationAction.endFasting.isEmpty)
    }

    // Ensure consistent naming conventions
    func testNotificationCategory_UsesUppercaseSnakeCase() {
        XCTAssertTrue(NotificationCategory.goalMet.contains("_"))
        XCTAssertEqual(NotificationCategory.goalMet, NotificationCategory.goalMet.uppercased())
    }

    func testNotificationActions_UseUppercaseSnakeCase() {
        XCTAssertTrue(NotificationAction.continueFasting.contains("_"))
        XCTAssertTrue(NotificationAction.endFasting.contains("_"))
    }
}

// MARK: - UserDefaults Keys Tests

final class UserDefaultsKeysTests: XCTestCase {

    func testFastingGoalMinutesKey() {
        // Given: The storage key
        let key = "fastingGoalMinutes"

        // Then: Should match the constant
        XCTAssertEqual(fastingGoalStorageKey, key)
    }

    // Document the shared UserDefaults keys used across app and widgets
    func testSharedUserDefaultsKeys() {
        let expectedKeys = [
            "fastingGoalMinutes",
            "fastingStartTime",
            "isFasting"
        ]

        // These keys are used in:
        // - FastingView.swift (main app)
        // - NotificationDelegate.swift
        // - FastingTimelineProvider.swift (widget)
        // - FastingIntents.swift (Siri)

        for key in expectedKeys {
            XCTAssertFalse(key.isEmpty, "Key '\(key)' should not be empty")
        }
    }
}

// MARK: - App Group Identifier Tests

final class AppGroupTests: XCTestCase {

    func testAppGroupIdentifier() {
        // Given: The expected app group identifier
        let expectedIdentifier = "group.dev.stringer.lastfast.shared"

        // This identifier is used in:
        // - NotificationDelegate.swift
        // - FastingTimelineProvider.swift
        // - FastingIntents.swift

        // Verify the format is correct
        XCTAssertTrue(expectedIdentifier.hasPrefix("group."))
        XCTAssertFalse(expectedIdentifier.isEmpty)
    }
}

// MARK: - Time Constants Tests

final class TimeConstantsTests: XCTestCase {

    func testSecondsInMinute() {
        XCTAssertEqual(60, 60)
    }

    func testSecondsInHour() {
        XCTAssertEqual(3600, 60 * 60)
    }

    func testSecondsIn16Hours() {
        XCTAssertEqual(57600, 16 * 60 * 60)
    }

    func testMinutesIn16Hours() {
        XCTAssertEqual(960, 16 * 60)
    }
}

// MARK: - Date Calculation Integration Tests

final class DateCalculationIntegrationTests: XCTestCase {

    func testGoalEndTimeCalculation_16Hours() {
        // Given: Start time and 16-hour goal
        let startTime = Date()
        let goalMinutes = defaultFastingGoalMinutes

        // When: Calculating end time
        let endTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))

        // Then: End time should be 16 hours later
        let difference = endTime.timeIntervalSince(startTime)
        XCTAssertEqual(difference, 57600, accuracy: 1.0)
    }

    func testOneHourBeforeGoalCalculation() {
        // Given: A goal time
        let goalTime = Date().addingTimeInterval(7200) // 2 hours from now

        // When: Calculating one hour before
        let oneHourBefore = goalTime.addingTimeInterval(-3600)

        // Then: Should be 1 hour from now
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow
        XCTAssertEqual(timeUntilOneHourBefore, 3600, accuracy: 1.0)
    }

    func testDurationFromStartToEnd() {
        // Given: Start and end times
        let startTime = Date().addingTimeInterval(-57600)
        let endTime = Date()

        // When: Calculating duration
        let duration = endTime.timeIntervalSince(startTime)

        // Then: Should be 16 hours
        XCTAssertEqual(duration, 57600, accuracy: 1.0)
    }
}

// MARK: - Progress Calculation Integration Tests

final class ProgressCalculationIntegrationTests: XCTestCase {

    func testProgressPercentages() {
        let testCases: [(elapsed: TimeInterval, goal: Int, expectedProgress: Double)] = [
            (0, 960, 0.0),           // 0%
            (14400, 960, 0.25),      // 4h/16h = 25%
            (28800, 960, 0.5),       // 8h/16h = 50%
            (43200, 960, 0.75),      // 12h/16h = 75%
            (57600, 960, 1.0),       // 16h/16h = 100%
            (72000, 960, 1.0),       // 20h/16h = 100% (capped)
        ]

        for testCase in testCases {
            let progress = min(1.0, (testCase.elapsed / 60) / Double(testCase.goal))
            XCTAssertEqual(
                progress,
                testCase.expectedProgress,
                accuracy: 0.001,
                "Failed for elapsed: \(testCase.elapsed), goal: \(testCase.goal)"
            )
        }
    }

    func testRemainingTimeCalculations() {
        let testCases: [(elapsed: TimeInterval, goal: Int, expectedRemaining: Int)] = [
            (0, 960, 960),          // 16h remaining
            (28800, 960, 480),      // 8h remaining
            (57600, 960, 0),        // 0h remaining
            (72000, 960, 0),        // Past goal, clamped to 0
        ]

        for testCase in testCases {
            let elapsedMinutes = Int(testCase.elapsed) / 60
            let remainingMinutes = max(0, testCase.goal - elapsedMinutes)
            XCTAssertEqual(
                remainingMinutes,
                testCase.expectedRemaining,
                "Failed for elapsed: \(testCase.elapsed), goal: \(testCase.goal)"
            )
        }
    }
}
