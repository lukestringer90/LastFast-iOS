//
//  WidgetTimeSplitLabelTests.swift
//  LastFastUnitTests
//
//  Tests for splitTimeForDisplay — the logic behind WidgetTimeSplitLabel
//

import XCTest
@testable import LastFast

final class WidgetTimeSplitLabelTests: XCTestCase {

    // MARK: - 12-hour locale (en_US)

    private let locale12h = Locale(identifier: "en_US")

    func testSplit_12Hour_AfternoonTime_SplitsPeriod() {
        let date = TestDateBuilder.date(hour: 14, minute: 30) // 2:30 PM
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertEqual(result.time, "2:30")
        XCTAssertEqual(result.period, "PM")
    }

    func testSplit_12Hour_MorningTime_SplitsPeriod() {
        let date = TestDateBuilder.date(hour: 10, minute: 52) // 10:52 AM
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertEqual(result.time, "10:52")
        XCTAssertEqual(result.period, "AM")
    }

    func testSplit_12Hour_Noon_SplitsPeriod() {
        let date = TestDateBuilder.date(hour: 12, minute: 0) // 12:00 PM
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertEqual(result.time, "12:00")
        XCTAssertEqual(result.period, "PM")
    }

    func testSplit_12Hour_Midnight_SplitsPeriod() {
        let date = TestDateBuilder.date(hour: 0, minute: 0) // 12:00 AM
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertEqual(result.time, "12:00")
        XCTAssertEqual(result.period, "AM")
    }

    func testSplit_12Hour_TimePartContainsNoAmPm() {
        let date = TestDateBuilder.date(hour: 15, minute: 5)
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertFalse(result.time.localizedCaseInsensitiveContains("AM"))
        XCTAssertFalse(result.time.localizedCaseInsensitiveContains("PM"))
    }

    func testSplit_12Hour_PeriodIsNotNil() {
        let date = TestDateBuilder.date(hour: 9, minute: 0)
        let result = splitTimeForDisplay(date: date, locale: locale12h)
        XCTAssertNotNil(result.period)
    }

    // MARK: - 24-hour locale (de_DE)

    private let locale24h = Locale(identifier: "de_DE")

    func testSplit_24Hour_AfternoonTime_NoPeriod() {
        let date = TestDateBuilder.date(hour: 14, minute: 30)
        let result = splitTimeForDisplay(date: date, locale: locale24h)
        XCTAssertEqual(result.time, "14:30")
        XCTAssertNil(result.period)
    }

    func testSplit_24Hour_MorningTime_NoPeriod() {
        let date = TestDateBuilder.date(hour: 9, minute: 15)
        let result = splitTimeForDisplay(date: date, locale: locale24h)
        XCTAssertEqual(result.time, "09:15")
        XCTAssertNil(result.period)
    }

    func testSplit_24Hour_Midnight_NoPeriod() {
        let date = TestDateBuilder.date(hour: 0, minute: 0)
        let result = splitTimeForDisplay(date: date, locale: locale24h)
        XCTAssertNil(result.period)
    }

    func testSplit_24Hour_PeriodIsAlwaysNil() {
        let hours = [0, 6, 12, 13, 18, 23]
        for hour in hours {
            let date = TestDateBuilder.date(hour: hour, minute: 0)
            let result = splitTimeForDisplay(date: date, locale: locale24h)
            XCTAssertNil(result.period, "Expected nil period for \(hour):00 in 24-hour locale")
        }
    }
}
