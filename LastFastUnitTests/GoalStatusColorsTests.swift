//
//  GoalStatusColorsTests.swift
//  LastFastTests
//
//  Tests for GoalStatusColors theme utilities
//

import XCTest
import SwiftUI
@testable import LastFast

// MARK: - Duration Color Tests

final class GoalStatusDurationColorTests: XCTestCase {

    func testDurationColor_GoalMet_ReturnsGreen() {
        // Given: Goal is met
        let goalMet = true

        // When: Getting duration color
        let color = GoalStatusColors.durationColor(goalMet: goalMet)

        // Then: Should be green
        XCTAssertEqual(color, .green)
    }

    func testDurationColor_GoalNotMet_ReturnsOrange() {
        // Given: Goal is not met
        let goalMet = false

        // When: Getting duration color
        let color = GoalStatusColors.durationColor(goalMet: goalMet)

        // Then: Should be orange
        XCTAssertEqual(color, .orange)
    }

    func testDurationColor_NoGoal_ReturnsPrimary() {
        // Given: No goal is set
        let hasGoal = false

        // When: Getting duration color (goalMet is irrelevant when hasGoal is false)
        let colorGoalMet = GoalStatusColors.durationColor(goalMet: true, hasGoal: hasGoal)
        let colorGoalNotMet = GoalStatusColors.durationColor(goalMet: false, hasGoal: hasGoal)

        // Then: Both should be primary (goal status doesn't matter without a goal)
        XCTAssertEqual(colorGoalMet, .primary)
        XCTAssertEqual(colorGoalNotMet, .primary)
    }

    func testDurationColor_HasGoalDefaultsToTrue() {
        // Given: Using default hasGoal parameter

        // When: Getting duration color without specifying hasGoal
        let colorMet = GoalStatusColors.durationColor(goalMet: true)
        let colorNotMet = GoalStatusColors.durationColor(goalMet: false)

        // Then: Should behave as if hasGoal is true
        XCTAssertEqual(colorMet, .green)
        XCTAssertEqual(colorNotMet, .orange)
    }
}

// MARK: - Icon Color Tests

final class GoalStatusIconColorTests: XCTestCase {

    func testIconColor_GoalMet_ReturnsGreen() {
        // Given: Goal is met
        let goalMet = true

        // When: Getting icon color
        let color = GoalStatusColors.iconColor(goalMet: goalMet)

        // Then: Should be green
        XCTAssertEqual(color, .green)
    }

    func testIconColor_GoalNotMet_ReturnsRed() {
        // Given: Goal is not met
        let goalMet = false

        // When: Getting icon color
        let color = GoalStatusColors.iconColor(goalMet: goalMet)

        // Then: Should be red
        XCTAssertEqual(color, .red)
    }
}

// MARK: - Icon System Name Tests

final class GoalStatusIconSystemNameTests: XCTestCase {

    func testIconSystemName_GoalMet_ReturnsCheckmark() {
        // Given: Goal is met
        let goalMet = true

        // When: Getting icon system name
        let iconName = GoalStatusColors.iconSystemName(goalMet: goalMet)

        // Then: Should be checkmark circle
        XCTAssertEqual(iconName, "checkmark.circle.fill")
    }

    func testIconSystemName_GoalNotMet_ReturnsXmark() {
        // Given: Goal is not met
        let goalMet = false

        // When: Getting icon system name
        let iconName = GoalStatusColors.iconSystemName(goalMet: goalMet)

        // Then: Should be xmark circle
        XCTAssertEqual(iconName, "xmark.circle.fill")
    }

    func testIconSystemNames_AreValidSFSymbols() {
        // Given: Both possible icon names
        let metIcon = GoalStatusColors.iconSystemName(goalMet: true)
        let notMetIcon = GoalStatusColors.iconSystemName(goalMet: false)

        // Then: Both should be non-empty valid SF Symbol names
        XCTAssertFalse(metIcon.isEmpty)
        XCTAssertFalse(notMetIcon.isEmpty)
        XCTAssertTrue(metIcon.contains("circle"))
        XCTAssertTrue(notMetIcon.contains("circle"))
    }
}

// MARK: - Integration Tests

final class GoalStatusColorsIntegrationTests: XCTestCase {

    func testColorConsistency_GoalMet_AllIndicatorsPositive() {
        // Given: Goal is met
        let goalMet = true

        // When: Getting all status indicators
        let durationColor = GoalStatusColors.durationColor(goalMet: goalMet)
        let iconColor = GoalStatusColors.iconColor(goalMet: goalMet)
        let iconName = GoalStatusColors.iconSystemName(goalMet: goalMet)

        // Then: All should indicate success
        XCTAssertEqual(durationColor, .green)
        XCTAssertEqual(iconColor, .green)
        XCTAssertTrue(iconName.contains("checkmark"))
    }

    func testColorConsistency_GoalNotMet_AllIndicatorsNegative() {
        // Given: Goal is not met
        let goalMet = false

        // When: Getting all status indicators
        let durationColor = GoalStatusColors.durationColor(goalMet: goalMet)
        let iconColor = GoalStatusColors.iconColor(goalMet: goalMet)
        let iconName = GoalStatusColors.iconSystemName(goalMet: goalMet)

        // Then: All should indicate incomplete/failure
        XCTAssertEqual(durationColor, .orange)
        XCTAssertEqual(iconColor, .red)
        XCTAssertTrue(iconName.contains("xmark"))
    }

    func testDurationAndIconColors_DifferentForNotMet() {
        // Given: Goal is not met
        let goalMet = false

        // When: Getting colors
        let durationColor = GoalStatusColors.durationColor(goalMet: goalMet)
        let iconColor = GoalStatusColors.iconColor(goalMet: goalMet)

        // Then: Duration shows warning (orange), icon shows failure (red)
        // This is intentional - duration is "in progress" while icon is definitive status
        XCTAssertEqual(durationColor, .orange)
        XCTAssertEqual(iconColor, .red)
        XCTAssertNotEqual(durationColor, iconColor)
    }
}
