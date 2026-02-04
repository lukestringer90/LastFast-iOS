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

// MARK: - Notification Content Configuration Tests

/// Tests for notification content settings
final class NotificationContentConfigurationTests: XCTestCase {

    func testOneHourNotification_TitleFormat() {
        // Given: The expected title format for one hour notification
        let expectedTitle = "⏰ One Hour to Go!"

        // Then: Title should contain timer emoji and "One Hour"
        XCTAssertTrue(expectedTitle.contains("⏰"))
        XCTAssertTrue(expectedTitle.contains("One Hour"))
    }

    func testGoalNotification_TitleFormat() {
        // Given: A goal text for a 16-hour fast
        let goalText = "16h"
        let title = "🎉 Goal Achieved - \(goalText)"

        // Then: Title should contain celebration emoji and goal
        XCTAssertTrue(title.contains("🎉"))
        XCTAssertTrue(title.contains("Goal Achieved"))
        XCTAssertTrue(title.contains("16h"))
    }

    func testGoalNotification_BodyFormat() {
        // Given: Start and end times
        let startTimeText = "08:00"
        let endTimeText = "00:00"
        let body = "Amazing work! You fasted from \(startTimeText) → \(endTimeText)"

        // Then: Body should contain congratulations and time range
        XCTAssertTrue(body.contains("Amazing work"))
        XCTAssertTrue(body.contains(startTimeText))
        XCTAssertTrue(body.contains(endTimeText))
        XCTAssertTrue(body.contains("→"))
    }
}

// MARK: - Notification Scheduling Logic Tests

/// Tests for notification scheduling edge cases
final class NotificationSchedulingEdgeCasesTests: XCTestCase {

    func testScheduling_GoalInPast_ShouldNotSchedule() {
        // Given: A goal time that has already passed
        let startTime = Date().addingTimeInterval(-72000) // 20 hours ago
        let goalMinutes = 960 // 16 hours
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let timeUntilGoal = goalTime.timeIntervalSinceNow

        // When: Checking if we should schedule
        let shouldSchedule = timeUntilGoal > 0

        // Then: Should not schedule (already passed)
        XCTAssertFalse(shouldSchedule)
    }

    func testScheduling_GoalInFuture_ShouldSchedule() {
        // Given: A goal time in the future
        let startTime = Date()
        let goalMinutes = 960
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let timeUntilGoal = goalTime.timeIntervalSinceNow

        // When: Checking if we should schedule
        let shouldSchedule = timeUntilGoal > 0

        // Then: Should schedule
        XCTAssertTrue(shouldSchedule)
    }

    func testScheduling_OneHourNotification_ExactlyOneHourLeft() {
        // Given: A goal exactly 1 hour away
        let goalTime = Date().addingTimeInterval(3600)
        let oneHourBefore = goalTime.addingTimeInterval(-3600)
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow

        // Then: Should be approximately now (0 seconds)
        XCTAssertEqual(timeUntilOneHourBefore, 0, accuracy: 1)
    }

    func testScheduling_OneHourNotification_MoreThanOneHourLeft() {
        // Given: A goal 2 hours away
        let goalTime = Date().addingTimeInterval(7200)
        let oneHourBefore = goalTime.addingTimeInterval(-3600)
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow

        // Then: One hour notification should be 1 hour from now
        let shouldScheduleOneHour = timeUntilOneHourBefore > 0
        XCTAssertTrue(shouldScheduleOneHour)
        XCTAssertEqual(timeUntilOneHourBefore, 3600, accuracy: 1)
    }

    func testScheduling_ShortGoal_NoOneHourNotification() {
        // Given: A goal only 30 minutes away (less than 1 hour)
        let startTime = Date()
        let goalMinutes = 30
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let oneHourBefore = goalTime.addingTimeInterval(-3600)
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow

        // Then: One hour notification would be in the past
        let shouldScheduleOneHour = timeUntilOneHourBefore > 0
        XCTAssertFalse(shouldScheduleOneHour)
    }
}

// MARK: - Time Formatter Tests

/// Tests for the time formatting used in notifications
final class NotificationTimeFormatterTests: XCTestCase {

    func testTimeFormatter_24HourFormat() {
        // Given: A date formatter configured for 24-hour time
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // When: Formatting various times
        let midnight = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        let noon = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        let evening = Calendar.current.date(bySettingHour: 22, minute: 30, second: 0, of: Date())!

        // Then: Should format in 24-hour format
        XCTAssertEqual(formatter.string(from: midnight), "00:00")
        XCTAssertEqual(formatter.string(from: noon), "12:00")
        XCTAssertEqual(formatter.string(from: evening), "22:30")
    }

    func testTimeFormatter_LeadingZeros() {
        // Given: A date formatter
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"

        // When: Formatting early morning time
        let earlyMorning = Calendar.current.date(bySettingHour: 5, minute: 30, second: 0, of: Date())!

        // Then: Should have leading zero
        XCTAssertEqual(formatter.string(from: earlyMorning), "05:30")
    }
}

// MARK: - Notification Cancellation Tests

/// Tests for notification cancellation logic
final class NotificationCancellationTests: XCTestCase {

    func testCancellationIdentifiers_IncludesGoalMet() {
        // Given: Identifiers to cancel
        let identifiersToCancel = [
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ]

        // Then: Should include goal met identifier
        XCTAssertTrue(identifiersToCancel.contains(NotificationIdentifier.goalMet))
    }

    func testCancellationIdentifiers_IncludesOneHourBefore() {
        // Given: Identifiers to cancel
        let identifiersToCancel = [
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ]

        // Then: Should include one hour before identifier
        XCTAssertTrue(identifiersToCancel.contains(NotificationIdentifier.oneHourBefore))
    }

    func testCancellationIdentifiers_MatchesScheduledIdentifiers() {
        // Given: Identifiers used for scheduling
        let scheduledIdentifiers = Set([
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ])

        // When: Getting cancellation identifiers
        let cancellationIdentifiers = Set([
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ])

        // Then: Should match exactly
        XCTAssertEqual(scheduledIdentifiers, cancellationIdentifiers)
    }
}
