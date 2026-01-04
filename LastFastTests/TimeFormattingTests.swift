//
//  TimeFormattingTests.swift
//  LastFastTests
//
//  Tests for time formatting functions
//

import XCTest
@testable import LastFast

final class TimeFormattingTests: XCTestCase {
    
    func testFormat24HourTime_MorningTime_FormatsCorrectly() {
        // Given: A morning time (9:30 AM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 9
        components.minute = 30
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "09:30"
        XCTAssertEqual(formatted, "09:30")
    }
    
    func testFormat24HourTime_AfternoonTime_FormatsCorrectly() {
        // Given: An afternoon time (2:45 PM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 14
        components.minute = 45
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "14:45"
        XCTAssertEqual(formatted, "14:45")
    }
    
    func testFormat24HourTime_Midnight_FormatsCorrectly() {
        // Given: Midnight
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 0
        components.minute = 0
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "00:00"
        XCTAssertEqual(formatted, "00:00")
    }
    
    func testFormat24HourTime_Noon_FormatsCorrectly() {
        // Given: Noon
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 12
        components.minute = 0
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "12:00"
        XCTAssertEqual(formatted, "12:00")
    }
    
    func testFormat24HourTime_SingleDigitMinutes_PadsWithZero() {
        // Given: A time with single digit minutes (3:05 PM)
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 15
        components.minute = 5
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "15:05" (padded)
        XCTAssertEqual(formatted, "15:05")
    }
    
    func testFormat24HourTime_EndOfDay_FormatsCorrectly() {
        // Given: 11:59 PM
        var components = DateComponents()
        components.year = 2024
        components.month = 1
        components.day = 15
        components.hour = 23
        components.minute = 59
        let date = Calendar.current.date(from: components)!
        
        // When: Formatting the time
        let formatted = format24HourTime(date)
        
        // Then: Should show "23:59"
        XCTAssertEqual(formatted, "23:59")
    }
}
