//
//  NotificationManagerTests.swift
//  LastFastTests
//
//  Tests for notification-related constants and calculation logic
//

import XCTest
@testable import LastFast

// MARK: - Notification Identifier Tests

final class NotificationIdentifierTests: XCTestCase {

    func testNotificationIdentifier_GoalMet_HasExpectedValue() {
        XCTAssertEqual(NotificationIdentifier.goalMet, "goalMet")
    }

    func testNotificationIdentifier_OneHourBefore_HasExpectedValue() {
        XCTAssertEqual(NotificationIdentifier.oneHourBefore, "oneHourBefore")
    }

    func testNotificationIdentifiers_AreUnique() {
        let identifiers = [
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ]
        let uniqueIdentifiers = Set(identifiers)
        XCTAssertEqual(identifiers.count, uniqueIdentifiers.count)
    }
}

// MARK: - Notification Category Tests

final class NotificationCategoryTests: XCTestCase {

    func testNotificationCategory_GoalMet_HasExpectedValue() {
        XCTAssertEqual(NotificationCategory.goalMet, "FASTING_GOAL_MET")
    }
}

// MARK: - Notification Action Tests

final class NotificationActionTests: XCTestCase {

    func testNotificationAction_ContinueFasting_HasExpectedValue() {
        XCTAssertEqual(NotificationAction.continueFasting, "CONTINUE_FASTING")
    }

    func testNotificationAction_EndFasting_HasExpectedValue() {
        XCTAssertEqual(NotificationAction.endFasting, "END_FASTING")
    }

    func testNotificationActions_AreUnique() {
        let actions = [
            NotificationAction.continueFasting,
            NotificationAction.endFasting
        ]
        let uniqueActions = Set(actions)
        XCTAssertEqual(actions.count, uniqueActions.count)
    }
}

// MARK: - Goal Time Calculation Tests

/// Tests for the notification scheduling time calculations
/// These test the logic that would be used in NotificationManager
final class NotificationSchedulingCalculationTests: XCTestCase {

    func testGoalTimeCalculation_16HourGoal() {
        // Given: A start time and 16-hour goal
        let startTime = Date()
        let goalMinutes = 960 // 16 hours

        // When: Calculating goal time
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))

        // Then: Goal time should be 16 hours later
        let expectedTime = startTime.addingTimeInterval(57600)
        XCTAssertEqual(goalTime, expectedTime)
    }

    func testOneHourBeforeCalculation() {
        // Given: A goal time
        let goalTime = Date().addingTimeInterval(7200) // 2 hours from now

        // When: Calculating one hour before
        let oneHourBefore = goalTime.addingTimeInterval(-3600)

        // Then: Should be 1 hour from now
        let expectedTime = Date().addingTimeInterval(3600)
        XCTAssertEqual(oneHourBefore.timeIntervalSince1970, expectedTime.timeIntervalSince1970, accuracy: 1.0)
    }

    func testOneHourBefore_WhenLessThanOneHourToGoal_IsInPast() {
        // Given: A goal time only 30 minutes away
        let startTime = Date()
        let goalMinutes = 30

        // When: Calculating one hour before
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let oneHourBefore = goalTime.addingTimeInterval(-3600)
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow

        // Then: One hour before should be in the past (negative interval)
        XCTAssertLessThan(timeUntilOneHourBefore, 0)
    }

    func testGoalTime_WhenAlreadyPassed_HasNegativeInterval() {
        // Given: A fast that started 20 hours ago with 16-hour goal
        let startTime = Date().addingTimeInterval(-72000) // 20 hours ago
        let goalMinutes = 960 // 16 hours

        // When: Calculating time until goal
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let timeUntilGoal = goalTime.timeIntervalSinceNow

        // Then: Time until goal should be negative (already passed)
        XCTAssertLessThan(timeUntilGoal, 0)
    }

    func testGoalTime_WhenInFuture_HasPositiveInterval() {
        // Given: A fast just started with 16-hour goal
        let startTime = Date()
        let goalMinutes = 960

        // When: Calculating time until goal
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let timeUntilGoal = goalTime.timeIntervalSinceNow

        // Then: Time until goal should be positive
        XCTAssertGreaterThan(timeUntilGoal, 0)
        XCTAssertEqual(timeUntilGoal, 57600, accuracy: 1.0)
    }
}

// MARK: - Goal Text Formatting Tests

/// Tests for goal text formatting (matches NotificationManager.formatGoalText logic)
final class GoalTextFormattingTests: XCTestCase {

    /// Helper that replicates the formatGoalText logic from NotificationManager
    private func formatGoalText(goalMinutes: Int) -> String {
        let goalHours = goalMinutes / 60
        let goalMins = goalMinutes % 60

        if goalHours > 0 && goalMins > 0 {
            return "\(goalHours)h \(goalMins)m"
        } else if goalHours > 0 {
            return "\(goalHours)h"
        } else {
            return "\(goalMins)m"
        }
    }

    func testFormatGoalText_HoursAndMinutes() {
        XCTAssertEqual(formatGoalText(goalMinutes: 990), "16h 30m")
    }

    func testFormatGoalText_HoursOnly() {
        XCTAssertEqual(formatGoalText(goalMinutes: 960), "16h")
    }

    func testFormatGoalText_MinutesOnly() {
        XCTAssertEqual(formatGoalText(goalMinutes: 45), "45m")
    }

    func testFormatGoalText_OneHour() {
        XCTAssertEqual(formatGoalText(goalMinutes: 60), "1h")
    }

    func testFormatGoalText_ZeroMinutes() {
        XCTAssertEqual(formatGoalText(goalMinutes: 0), "0m")
    }

    func testFormatGoalText_LargeValue() {
        XCTAssertEqual(formatGoalText(goalMinutes: 1440), "24h") // 24 hours
    }
}
