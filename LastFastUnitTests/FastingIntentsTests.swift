//
//  FastingIntentsTests.swift
//  LastFastTests
//
//  Tests for FastingIntents App Intent configurations
//

import XCTest
import AppIntents
@testable import LastFast

// MARK: - StartFastingIntent Tests

final class StartFastingIntentTests: XCTestCase {

    func testStartFastingIntent_Title() {
        XCTAssertEqual(String(localized: StartFastingIntent.title), "Start a fast")
    }

    func testStartFastingIntent_Description() {
        let description = StartFastingIntent.description
        XCTAssertNotNil(description)
    }

    func testStartFastingIntent_DoesNotOpenApp() {
        XCTAssertFalse(StartFastingIntent.openAppWhenRun)
    }

    func testStartFastingIntent_CanBeInstantiated() {
        let intent = StartFastingIntent()
        XCTAssertNil(intent.durationHours)
    }

    func testStartFastingIntent_AcceptsDurationParameter() {
        var intent = StartFastingIntent()
        intent.durationHours = 16.0
        XCTAssertEqual(intent.durationHours, 16.0)
    }

    func testStartFastingIntent_AcceptsFractionalHours() {
        var intent = StartFastingIntent()
        intent.durationHours = 18.5
        XCTAssertEqual(intent.durationHours, 18.5)
    }
}

// MARK: - StartFastingWithEndTimeIntent Tests

final class StartFastingWithEndTimeIntentTests: XCTestCase {

    func testStartFastingWithEndTimeIntent_Title() {
        XCTAssertEqual(String(localized: StartFastingWithEndTimeIntent.title), "Start a fast with an end time")
    }

    func testStartFastingWithEndTimeIntent_DoesNotOpenApp() {
        XCTAssertFalse(StartFastingWithEndTimeIntent.openAppWhenRun)
    }

    func testStartFastingWithEndTimeIntent_CanBeInstantiated() {
        let intent = StartFastingWithEndTimeIntent()
        XCTAssertNotNil(intent)
    }

    func testStartFastingWithEndTimeIntent_AcceptsEndTimeParameter() {
        var intent = StartFastingWithEndTimeIntent()
        let endTime = Date().addingTimeInterval(3600)
        intent.endTime = endTime
        XCTAssertEqual(intent.endTime, endTime)
    }
}

// MARK: - StopFastingIntent Tests

final class StopFastingIntentTests: XCTestCase {

    func testStopFastingIntent_Title() {
        XCTAssertEqual(String(localized: StopFastingIntent.title), "Stop Fasting")
    }

    func testStopFastingIntent_DoesNotOpenApp() {
        XCTAssertFalse(StopFastingIntent.openAppWhenRun)
    }

    func testStopFastingIntent_CanBeInstantiated() {
        let intent = StopFastingIntent()
        XCTAssertNotNil(intent)
    }
}

// MARK: - CheckFastingStatusIntent Tests

final class CheckFastingStatusIntentTests: XCTestCase {

    func testCheckFastingStatusIntent_Title() {
        XCTAssertEqual(String(localized: CheckFastingStatusIntent.title), "Check Fasting Status")
    }

    func testCheckFastingStatusIntent_DoesNotOpenApp() {
        XCTAssertFalse(CheckFastingStatusIntent.openAppWhenRun)
    }

    func testCheckFastingStatusIntent_CanBeInstantiated() {
        let intent = CheckFastingStatusIntent()
        XCTAssertNotNil(intent)
    }
}

// MARK: - FastingShortcuts Provider Tests

final class FastingShortcutsTests: XCTestCase {

    func testFastingShortcuts_HasFourShortcuts() {
        let shortcuts = FastingShortcuts.appShortcuts
        XCTAssertEqual(shortcuts.count, 4)
    }

    func testFastingShortcuts_StartFastingShortcut_HasPhrases() {
        let shortcuts = FastingShortcuts.appShortcuts
        XCTAssertGreaterThanOrEqual(shortcuts.count, 1)

        // First shortcut should be start fasting
        let startShortcut = shortcuts[0]
        XCTAssertNotNil(startShortcut)
    }
}

// MARK: - Intent Duration Calculation Tests

/// Tests the duration calculations used within intent perform() methods
final class IntentDurationCalculationTests: XCTestCase {

    func testGoalMinutes_FromWholeHours() {
        // Given: A duration in whole hours
        let hours: Double = 16.0

        // When: Converting to minutes (as done in StartFastingIntent)
        let goalMinutes = Int(hours * 60)

        // Then: Should equal expected minutes
        XCTAssertEqual(goalMinutes, 960)
    }

    func testGoalMinutes_FromFractionalHours() {
        // Given: A duration with fractional hours
        let hours: Double = 18.5

        // When: Converting to minutes
        let goalMinutes = Int(hours * 60)

        // Then: Should equal expected minutes
        XCTAssertEqual(goalMinutes, 1110)
    }

    func testGoalDescription_WholeHours() {
        // Given: A duration in whole hours (simulating intent logic)
        let hours: Double = 16.0
        let wholeHours = Int(hours)
        let mins = Int((hours - Double(wholeHours)) * 60)

        // When: Generating description
        let description: String
        if mins > 0 {
            description = "\(wholeHours) hours and \(mins) minutes"
        } else {
            description = "\(wholeHours) hours"
        }

        // Then: Should match expected format
        XCTAssertEqual(description, "16 hours")
    }

    func testGoalDescription_FractionalHours() {
        // Given: A duration with fractional hours
        let hours: Double = 18.5
        let wholeHours = Int(hours)
        let mins = Int((hours - Double(wholeHours)) * 60)

        // When: Generating description
        let description: String
        if mins > 0 {
            description = "\(wholeHours) hours and \(mins) minutes"
        } else {
            description = "\(wholeHours) hours"
        }

        // Then: Should match expected format
        XCTAssertEqual(description, "18 hours and 30 minutes")
    }

    func testMinutesFromGoal_ToHoursAndMinutes() {
        // Given: A goal in minutes
        let goalMinutes = 990 // 16h 30m

        // When: Converting to hours and minutes (as in CheckFastingStatusIntent)
        let hours = goalMinutes / 60
        let mins = goalMinutes % 60

        // Then: Should extract correctly
        XCTAssertEqual(hours, 16)
        XCTAssertEqual(mins, 30)
    }

    func testEndTimeValidation_FutureTime() {
        // Given: An end time in the future
        let endTime = Date().addingTimeInterval(3600) // 1 hour from now

        // When: Calculating minutes until end (as in StartFastingWithEndTimeIntent)
        let minutesUntilEnd = Int(endTime.timeIntervalSinceNow / 60)

        // Then: Should be positive
        XCTAssertGreaterThan(minutesUntilEnd, 0)
    }

    func testEndTimeValidation_PastTime() {
        // Given: An end time in the past
        let endTime = Date().addingTimeInterval(-3600) // 1 hour ago

        // When: Calculating minutes until end
        let minutesUntilEnd = Int(endTime.timeIntervalSinceNow / 60)

        // Then: Should be negative (invalid)
        XCTAssertLessThanOrEqual(minutesUntilEnd, 0)
    }
}

// MARK: - Intent Status Message Calculation Tests

/// Tests the message formatting logic used in intent responses
final class IntentStatusMessageTests: XCTestCase {

    func testDurationText_HoursAndMinutes() {
        // Given: A duration in seconds
        let duration: TimeInterval = 59400 // 16h 30m

        // When: Calculating text (as in StopFastingIntent)
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let durationText = hours > 0 ? "\(hours) hours and \(minutes) minutes" : "\(minutes) minutes"

        // Then: Should format correctly
        XCTAssertEqual(durationText, "16 hours and 30 minutes")
    }

    func testDurationText_MinutesOnly() {
        // Given: A short duration
        let duration: TimeInterval = 1800 // 30 minutes

        // When: Calculating text
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        let durationText = hours > 0 ? "\(hours) hours and \(minutes) minutes" : "\(minutes) minutes"

        // Then: Should only show minutes
        XCTAssertEqual(durationText, "30 minutes")
    }

    func testDurationTextForStatus_AllFormats() {
        // Given: Duration values
        let testCases: [(TimeInterval, String)] = [
            (57600, "16 hours"),                    // 16h 0m
            (61200, "17 hours"),                    // 17h 0m
            (1800, "30 minutes"),                   // 0h 30m
            (0, "0 minutes")                        // 0h 0m
        ]

        for (duration, expected) in testCases {
            // When: Formatting using CheckFastingStatusIntent logic
            let hours = Int(duration) / 3600
            let minutes = (Int(duration) % 3600) / 60

            let durationText: String
            if hours > 0 && minutes > 0 {
                durationText = "\(hours) hours and \(minutes) minutes"
            } else if hours > 0 {
                durationText = "\(hours) hours"
            } else {
                durationText = "\(minutes) minutes"
            }

            // Then: Should match expected
            XCTAssertEqual(durationText, expected, "Failed for duration: \(duration)")
        }
    }

    func testRemainingTimeCalculation() {
        // Given: Current elapsed time and goal
        let currentDuration: TimeInterval = 28800 // 8 hours
        let goalMinutes = 960 // 16 hours

        // When: Calculating remaining time
        let hours = Int(currentDuration) / 3600
        let minutes = (Int(currentDuration) % 3600) / 60
        let remainingMinutes = goalMinutes - (hours * 60 + minutes)
        let remainingHours = remainingMinutes / 60
        let remainingMins = remainingMinutes % 60

        // Then: Should calculate correctly
        XCTAssertEqual(remainingMinutes, 480) // 8 hours remaining
        XCTAssertEqual(remainingHours, 8)
        XCTAssertEqual(remainingMins, 0)
    }
}
