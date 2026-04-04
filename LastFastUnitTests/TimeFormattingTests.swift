//
//  TimeFormattingTests.swift
//  LastFastTests
//
//  Tests for time formatting functions
//

import XCTest
@testable import LastFast

final class TimeFormattingTests: XCTestCase {

    // Reference formatter matching the production formatter configuration
    private let referenceFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()

    // MARK: - formatTime Tests

    func testFormatTime_MorningTime_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 9, minute: 30)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_AfternoonTime_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 14, minute: 45)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_Midnight_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 0, minute: 0)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_Noon_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 12, minute: 0)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_SingleDigitMinutes_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 15, minute: 5)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_EndOfDay_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 23, minute: 59)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_SingleDigitHour_FormatsCorrectly() {
        let date = TestDateBuilder.date(hour: 1, minute: 0)
        let formatted = formatTime(date)
        XCTAssertEqual(formatted, referenceFormatter.string(from: date))
    }

    func testFormatTime_VariousTimesOfDay() {
        let hours = [0, 6, 9, 12, 13, 18, 23]
        let minutes = [0, 30, 15, 0, 45, 30, 59]

        for (hour, minute) in zip(hours, minutes) {
            let date = TestDateBuilder.date(hour: hour, minute: minute)
            let formatted = formatTime(date)
            XCTAssertEqual(
                formatted,
                referenceFormatter.string(from: date),
                "Failed for \(hour):\(minute)"
            )
        }
    }

    // MARK: - Non-empty output

    func testFormatTime_ReturnsNonEmptyString() {
        let date = TestDateBuilder.date(hour: 8, minute: 0)
        XCTAssertFalse(formatTime(date).isEmpty)
    }
}
