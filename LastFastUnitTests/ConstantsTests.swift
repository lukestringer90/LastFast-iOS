//
//  ConstantsTests.swift
//  LastFastTests
//
//  Tests for app constants and feature flags
//

import XCTest
@testable import LastFast

final class ConstantsTests: XCTestCase {
    
    func testDefaultFastingGoalMinutes_Is16Hours() {
        // Given: The default constant

        // When: Checking its value
        let defaultGoal = defaultFastingGoalMinutes

        // Then: Should be 960 minutes (16 hours)
        XCTAssertEqual(defaultGoal, 960)
    }
    
    func testFastingGoalStorageKey_HasCorrectValue() {
        // Given: The storage key constant
        
        // When: Checking its value
        let key = fastingGoalStorageKey
        
        // Then: Should match expected key
        XCTAssertEqual(key, "fastingGoalMinutes")
    }
}

// MARK: - Feature Flag Tests

final class FeatureFlagTests: XCTestCase {
    
    func testLiveActivityEnabled_HasExpectedDefaultValue() {
        // Given: The live activity feature flag
        
        // When: Checking its value
        let isEnabled = liveActivityEnabled
        
        // Then: Should be false by default (as per current implementation)
        XCTAssertFalse(isEnabled)
    }
}
