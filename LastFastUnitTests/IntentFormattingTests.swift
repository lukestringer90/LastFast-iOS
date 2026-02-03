//
//  IntentFormattingTests.swift
//  LastFastTests
//
//  Tests for natural language formatting used in Siri intents
//

import XCTest
@testable import LastFast

// MARK: - Natural Language Duration Formatting Tests

final class NaturalLanguageDurationFormattingTests: XCTestCase {

    // MARK: - formatDurationNaturalLanguage(hours:minutes:) Tests

    func testFormatDurationNaturalLanguage_HoursAndMinutes() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 16, minutes: 30), "16 hours and 30 minutes")
    }

    func testFormatDurationNaturalLanguage_OnlyHours_Plural() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 16, minutes: 0), "16 hours")
    }

    func testFormatDurationNaturalLanguage_OnlyHours_Singular() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 1, minutes: 0), "1 hour")
    }

    func testFormatDurationNaturalLanguage_OnlyMinutes_Plural() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 0, minutes: 30), "30 minutes")
    }

    func testFormatDurationNaturalLanguage_OnlyMinutes_Singular() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 0, minutes: 1), "1 minute")
    }

    func testFormatDurationNaturalLanguage_ZeroValues() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 0, minutes: 0), "0 minutes")
    }

    func testFormatDurationNaturalLanguage_LargeValues() {
        XCTAssertEqual(formatDurationNaturalLanguage(hours: 48, minutes: 45), "48 hours and 45 minutes")
    }

    // MARK: - formatDurationNaturalLanguage(from:) Tests

    func testFormatDurationFromInterval_16Hours() {
        let interval: TimeInterval = 16 * 3600
        XCTAssertEqual(formatDurationNaturalLanguage(from: interval), "16 hours")
    }

    func testFormatDurationFromInterval_16Hours30Minutes() {
        let interval: TimeInterval = (16 * 3600) + (30 * 60)
        XCTAssertEqual(formatDurationNaturalLanguage(from: interval), "16 hours and 30 minutes")
    }

    func testFormatDurationFromInterval_30Minutes() {
        let interval: TimeInterval = 30 * 60
        XCTAssertEqual(formatDurationNaturalLanguage(from: interval), "30 minutes")
    }

    func testFormatDurationFromInterval_1Hour() {
        let interval: TimeInterval = 3600
        XCTAssertEqual(formatDurationNaturalLanguage(from: interval), "1 hour")
    }

    func testFormatDurationFromInterval_1Minute() {
        let interval: TimeInterval = 60
        XCTAssertEqual(formatDurationNaturalLanguage(from: interval), "1 minute")
    }

    // MARK: - formatRemainingTimeNaturalLanguage Tests

    func testFormatRemainingTime_480Minutes() {
        XCTAssertEqual(formatRemainingTimeNaturalLanguage(480), "8 hours")
    }

    func testFormatRemainingTime_510Minutes() {
        XCTAssertEqual(formatRemainingTimeNaturalLanguage(510), "8 hours and 30 minutes")
    }

    func testFormatRemainingTime_45Minutes() {
        XCTAssertEqual(formatRemainingTimeNaturalLanguage(45), "45 minutes")
    }

    func testFormatRemainingTime_1Minute() {
        XCTAssertEqual(formatRemainingTimeNaturalLanguage(1), "1 minute")
    }

    func testFormatRemainingTime_60Minutes() {
        XCTAssertEqual(formatRemainingTimeNaturalLanguage(60), "1 hour")
    }
}

// MARK: - Goal Description Formatting Tests

final class GoalDescriptionFormattingTests: XCTestCase {

    // MARK: - formatGoalDescription(hours:) Tests

    func testFormatGoalDescription_WholeHours() {
        XCTAssertEqual(formatGoalDescription(hours: 16.0), "16 hours")
    }

    func testFormatGoalDescription_FractionalHours() {
        XCTAssertEqual(formatGoalDescription(hours: 16.5), "16 hours and 30 minutes")
    }

    func testFormatGoalDescription_QuarterHour() {
        XCTAssertEqual(formatGoalDescription(hours: 18.25), "18 hours and 15 minutes")
    }

    func testFormatGoalDescription_1Hour() {
        XCTAssertEqual(formatGoalDescription(hours: 1.0), "1 hour")
    }

    func testFormatGoalDescription_30Minutes() {
        XCTAssertEqual(formatGoalDescription(hours: 0.5), "30 minutes")
    }

    // MARK: - formatGoalDescription(minutes:) Tests

    func testFormatGoalDescriptionFromMinutes_960() {
        XCTAssertEqual(formatGoalDescription(minutes: 960), "16 hours")
    }

    func testFormatGoalDescriptionFromMinutes_510() {
        XCTAssertEqual(formatGoalDescription(minutes: 510), "8 hours and 30 minutes")
    }

    func testFormatGoalDescriptionFromMinutes_60() {
        XCTAssertEqual(formatGoalDescription(minutes: 60), "1 hour")
    }

    func testFormatGoalDescriptionFromMinutes_45() {
        XCTAssertEqual(formatGoalDescription(minutes: 45), "45 minutes")
    }

    func testFormatGoalDescriptionFromMinutes_1() {
        XCTAssertEqual(formatGoalDescription(minutes: 1), "1 minute")
    }
}

// MARK: - Intent Logic Calculation Tests

/// Tests the calculation patterns used in FastingIntents
final class IntentCalculationTests: XCTestCase {

    // MARK: - Goal Minutes From Hours

    func testGoalMinutesFromHours_Whole() {
        let hours = 16.0
        let goalMinutes = Int(hours * 60)
        XCTAssertEqual(goalMinutes, 960)
    }

    func testGoalMinutesFromHours_Fractional() {
        let hours = 18.5
        let goalMinutes = Int(hours * 60)
        XCTAssertEqual(goalMinutes, 1110)
    }

    // MARK: - Minutes Until End Time

    func testMinutesUntilEndTime_Future() {
        let endTime = Date().addingTimeInterval(3600) // 1 hour from now
        let minutes = Int(endTime.timeIntervalSinceNow / 60)
        XCTAssertEqual(minutes, 60, accuracy: 1)
    }

    func testMinutesUntilEndTime_Past() {
        let endTime = Date().addingTimeInterval(-3600) // 1 hour ago
        let minutes = Int(endTime.timeIntervalSinceNow / 60)
        XCTAssertEqual(minutes, -60, accuracy: 1)
    }

    // MARK: - Duration Text Calculation

    func testDurationTextCalculation() {
        let duration: TimeInterval = 57600 // 16 hours
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        XCTAssertEqual(hours, 16)
        XCTAssertEqual(minutes, 0)
    }

    func testDurationTextCalculation_WithMinutes() {
        let duration: TimeInterval = 59400 // 16 hours 30 minutes
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60

        XCTAssertEqual(hours, 16)
        XCTAssertEqual(minutes, 30)
    }

    // MARK: - Remaining Time Calculation

    func testRemainingTimeCalculation() {
        let currentHours = 8
        let currentMinutes = 30
        let goalMinutes = 960 // 16 hours

        let elapsedMinutes = currentHours * 60 + currentMinutes
        let remaining = goalMinutes - elapsedMinutes

        XCTAssertEqual(remaining, 450) // 7.5 hours
    }

    func testRemainingTimeFormatting() {
        let remainingMinutes = 450 // 7.5 hours
        let hours = remainingMinutes / 60
        let mins = remainingMinutes % 60

        XCTAssertEqual(hours, 7)
        XCTAssertEqual(mins, 30)
    }
}
