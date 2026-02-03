//
//  DurationFormattingTests.swift
//  LastFastTests
//
//  Tests for duration formatting utility functions
//

import XCTest
@testable import LastFast

final class DurationFormattingTests: XCTestCase {

    // MARK: - formatDuration(hours:minutes:) Tests

    func testFormatDuration_HoursAndMinutes_ShowsBoth() {
        // Given: Hours and minutes both greater than zero
        let hours = 8
        let minutes = 30

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should show both
        XCTAssertEqual(result, "8h 30m")
    }

    func testFormatDuration_OnlyHours_ShowsHoursOnly() {
        // Given: Hours with zero minutes
        let hours = 16
        let minutes = 0

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should show hours only
        XCTAssertEqual(result, "16h")
    }

    func testFormatDuration_OnlyMinutes_ShowsMinutesOnly() {
        // Given: Zero hours with minutes
        let hours = 0
        let minutes = 45

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should show minutes only
        XCTAssertEqual(result, "45m")
    }

    func testFormatDuration_ZeroHoursZeroMinutes_ShowsZeroMinutes() {
        // Given: Both hours and minutes are zero
        let hours = 0
        let minutes = 0

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should show 0m
        XCTAssertEqual(result, "0m")
    }

    func testFormatDuration_LargeValues_FormatsCorrectly() {
        // Given: Large hour values (multi-day fast)
        let hours = 72
        let minutes = 15

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should handle large values
        XCTAssertEqual(result, "72h 15m")
    }

    func testFormatDuration_SingleDigitValues_NoLeadingZeros() {
        // Given: Single digit values
        let hours = 1
        let minutes = 5

        // When: Formatting
        let result = formatDuration(hours: hours, minutes: minutes)

        // Then: Should not pad with zeros
        XCTAssertEqual(result, "1h 5m")
    }

    // MARK: - hoursAndMinutes(from:) Tests

    func testHoursAndMinutes_ZeroInterval_ReturnsZeros() {
        // Given: Zero time interval
        let interval: TimeInterval = 0

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should return zeros
        XCTAssertEqual(result.hours, 0)
        XCTAssertEqual(result.minutes, 0)
    }

    func testHoursAndMinutes_LessThanOneMinute_ReturnsZeros() {
        // Given: 59 seconds
        let interval: TimeInterval = 59

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should truncate to zero minutes
        XCTAssertEqual(result.hours, 0)
        XCTAssertEqual(result.minutes, 0)
    }

    func testHoursAndMinutes_ExactlyOneMinute_ReturnsOneMinute() {
        // Given: Exactly 60 seconds
        let interval: TimeInterval = 60

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should return 1 minute
        XCTAssertEqual(result.hours, 0)
        XCTAssertEqual(result.minutes, 1)
    }

    func testHoursAndMinutes_ExactlyOneHour_ReturnsOneHour() {
        // Given: Exactly 3600 seconds
        let interval: TimeInterval = 3600

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should return 1 hour, 0 minutes
        XCTAssertEqual(result.hours, 1)
        XCTAssertEqual(result.minutes, 0)
    }

    func testHoursAndMinutes_MixedValue_CalculatesCorrectly() {
        // Given: 2 hours 30 minutes (9000 seconds)
        let interval: TimeInterval = 9000

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should calculate correctly
        XCTAssertEqual(result.hours, 2)
        XCTAssertEqual(result.minutes, 30)
    }

    func testHoursAndMinutes_16Hours_CalculatesCorrectly() {
        // Given: 16 hours (57600 seconds) - default fasting goal
        let interval: TimeInterval = 57600

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should return 16 hours
        XCTAssertEqual(result.hours, 16)
        XCTAssertEqual(result.minutes, 0)
    }

    func testHoursAndMinutes_DiscardsSeconds() {
        // Given: 1 hour, 30 minutes, 45 seconds
        let interval: TimeInterval = 3600 + 1800 + 45

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Seconds should be discarded
        XCTAssertEqual(result.hours, 1)
        XCTAssertEqual(result.minutes, 30)
    }

    func testHoursAndMinutes_LargeInterval_HandlesMultipleDays() {
        // Given: 3 days (72 hours)
        let interval: TimeInterval = 72 * 3600

        // When: Converting
        let result = hoursAndMinutes(from: interval)

        // Then: Should handle large values
        XCTAssertEqual(result.hours, 72)
        XCTAssertEqual(result.minutes, 0)
    }

    // MARK: - formatDuration(from:) Tests

    func testFormatDurationFromInterval_ZeroInterval_ShowsZeroMinutes() {
        // Given: Zero interval
        let interval: TimeInterval = 0

        // When: Formatting
        let result = formatDuration(from: interval)

        // Then: Should show 0m
        XCTAssertEqual(result, "0m")
    }

    func testFormatDurationFromInterval_MinutesOnly_ShowsMinutes() {
        // Given: 45 minutes
        let interval: TimeInterval = 45 * 60

        // When: Formatting
        let result = formatDuration(from: interval)

        // Then: Should show 45m
        XCTAssertEqual(result, "45m")
    }

    func testFormatDurationFromInterval_HoursOnly_ShowsHours() {
        // Given: Exactly 2 hours
        let interval: TimeInterval = 2 * 3600

        // When: Formatting
        let result = formatDuration(from: interval)

        // Then: Should show 2h
        XCTAssertEqual(result, "2h")
    }

    func testFormatDurationFromInterval_HoursAndMinutes_ShowsBoth() {
        // Given: 16 hours 30 minutes
        let interval: TimeInterval = 16 * 3600 + 30 * 60

        // When: Formatting
        let result = formatDuration(from: interval)

        // Then: Should show both
        XCTAssertEqual(result, "16h 30m")
    }

    func testFormatDurationFromInterval_DiscardsSeconds() {
        // Given: 1 hour, 15 minutes, 59 seconds
        let interval: TimeInterval = 3600 + 15 * 60 + 59

        // When: Formatting
        let result = formatDuration(from: interval)

        // Then: Seconds should be discarded
        XCTAssertEqual(result, "1h 15m")
    }
}
