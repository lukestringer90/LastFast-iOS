//
//  TimeFormattingTests.swift
//  LastFastTests
//
//  Tests for time formatting functions
//

import XCTest
@testable import LastFast

final class TimeFormattingTests: XCTestCase {

    // MARK: - format24HourTime Tests Using Helper

    func testFormat24HourTime_MorningTime_FormatsCorrectly() {
        // Given: A morning time (9:30 AM)
        let date = TestDateBuilder.date(hour: 9, minute: 30)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "09:30"
        XCTAssertEqual(formatted, "09:30")
    }

    func testFormat24HourTime_AfternoonTime_FormatsCorrectly() {
        // Given: An afternoon time (2:45 PM)
        let date = TestDateBuilder.date(hour: 14, minute: 45)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "14:45"
        XCTAssertEqual(formatted, "14:45")
    }

    func testFormat24HourTime_Midnight_FormatsCorrectly() {
        // Given: Midnight
        let date = TestDateBuilder.date(hour: 0, minute: 0)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "00:00"
        XCTAssertEqual(formatted, "00:00")
    }

    func testFormat24HourTime_Noon_FormatsCorrectly() {
        // Given: Noon
        let date = TestDateBuilder.date(hour: 12, minute: 0)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "12:00"
        XCTAssertEqual(formatted, "12:00")
    }

    func testFormat24HourTime_SingleDigitMinutes_PadsWithZero() {
        // Given: A time with single digit minutes (3:05 PM)
        let date = TestDateBuilder.date(hour: 15, minute: 5)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "15:05" (padded)
        XCTAssertEqual(formatted, "15:05")
    }

    func testFormat24HourTime_EndOfDay_FormatsCorrectly() {
        // Given: 11:59 PM
        let date = TestDateBuilder.date(hour: 23, minute: 59)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "23:59"
        XCTAssertEqual(formatted, "23:59")
    }

    // MARK: - Additional Edge Cases

    func testFormat24HourTime_SingleDigitHour_PadsWithZero() {
        // Given: A time with single digit hour (1:00 AM)
        let date = TestDateBuilder.date(hour: 1, minute: 0)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "01:00" (padded)
        XCTAssertEqual(formatted, "01:00")
    }

    func testFormat24HourTime_AllSingleDigits_PadsBoth() {
        // Given: A time with both single digit hour and minute (5:07 AM)
        let date = TestDateBuilder.date(hour: 5, minute: 7)

        // When: Formatting the time
        let formatted = format24HourTime(date)

        // Then: Should show "05:07" (both padded)
        XCTAssertEqual(formatted, "05:07")
    }

    // MARK: - Parameterized Tests

    func testFormat24HourTime_VariousTimesOfDay() {
        // Given: Various times throughout the day
        let testCases: [(hour: Int, minute: Int, expected: String)] = [
            (0, 0, "00:00"),    // Midnight
            (6, 30, "06:30"),   // Early morning
            (9, 15, "09:15"),   // Mid morning
            (12, 0, "12:00"),   // Noon
            (13, 45, "13:45"),  // Early afternoon
            (18, 30, "18:30"),  // Evening
            (23, 59, "23:59"),  // End of day
        ]

        for testCase in testCases {
            // When: Formatting
            let date = TestDateBuilder.date(hour: testCase.hour, minute: testCase.minute)
            let formatted = format24HourTime(date)

            // Then: Should match expected format
            XCTAssertEqual(
                formatted,
                testCase.expected,
                "Failed for \(testCase.hour):\(testCase.minute)"
            )
        }
    }
}
