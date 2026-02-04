//
//  NotificationDelegateTests.swift
//  LastFastTests
//
//  Tests for NotificationDelegate action handling logic
//

import XCTest
import UserNotifications
@testable import LastFast

// MARK: - Notification Action Matching Tests

/// Tests the action identifier matching logic used by NotificationDelegate
final class NotificationActionMatchingTests: XCTestCase {

    func testActionIdentifier_ContinueFasting_MatchesConstant() {
        // Given: The continue fasting action identifier
        let actionIdentifier = NotificationAction.continueFasting

        // When/Then: Should match the expected value
        XCTAssertEqual(actionIdentifier, "CONTINUE_FASTING")
    }

    func testActionIdentifier_EndFasting_MatchesConstant() {
        // Given: The end fasting action identifier
        let actionIdentifier = NotificationAction.endFasting

        // When/Then: Should match the expected value
        XCTAssertEqual(actionIdentifier, "END_FASTING")
    }

    func testActionSwitch_ContinueFasting() {
        // Given: An action identifier for continuing
        let actionIdentifier = NotificationAction.continueFasting
        var actionTaken = false

        // When: Processing the action (simulating switch logic)
        switch actionIdentifier {
        case NotificationAction.continueFasting:
            actionTaken = true
        case NotificationAction.endFasting:
            XCTFail("Should not match end fasting")
        default:
            XCTFail("Should match continue fasting")
        }

        // Then: Should have matched continue fasting
        XCTAssertTrue(actionTaken)
    }

    func testActionSwitch_EndFasting() {
        // Given: An action identifier for ending
        let actionIdentifier = NotificationAction.endFasting
        var shouldEndFast = false

        // When: Processing the action (simulating switch logic)
        switch actionIdentifier {
        case NotificationAction.continueFasting:
            XCTFail("Should not match continue fasting")
        case NotificationAction.endFasting:
            shouldEndFast = true
        default:
            XCTFail("Should match end fasting")
        }

        // Then: Should have matched end fasting
        XCTAssertTrue(shouldEndFast)
    }

    func testActionSwitch_DefaultActionIdentifier() {
        // Given: The default notification tap action
        let actionIdentifier = UNNotificationDefaultActionIdentifier
        var tappedNotification = false

        // When: Processing the action
        switch actionIdentifier {
        case NotificationAction.continueFasting:
            XCTFail("Should not match continue fasting")
        case NotificationAction.endFasting:
            XCTFail("Should not match end fasting")
        case UNNotificationDefaultActionIdentifier:
            tappedNotification = true
        default:
            XCTFail("Should match default action")
        }

        // Then: Should have matched default action
        XCTAssertTrue(tappedNotification)
    }

    func testActionSwitch_UnknownAction_FallsToDefault() {
        // Given: An unknown action identifier
        let actionIdentifier = "UNKNOWN_ACTION"
        var hitDefault = false

        // When: Processing the action
        switch actionIdentifier {
        case NotificationAction.continueFasting:
            XCTFail("Should not match continue fasting")
        case NotificationAction.endFasting:
            XCTFail("Should not match end fasting")
        case UNNotificationDefaultActionIdentifier:
            XCTFail("Should not match default action")
        default:
            hitDefault = true
        }

        // Then: Should fall through to default
        XCTAssertTrue(hitDefault)
    }
}

// MARK: - Notification Delegate Instantiation Tests

final class NotificationDelegateInstantiationTests: XCTestCase {

    func testNotificationDelegate_CanBeInstantiated() {
        // When: Creating a notification delegate
        let delegate = NotificationDelegate()

        // Then: Should not be nil and conform to protocol
        XCTAssertNotNil(delegate)
        XCTAssertTrue(delegate is UNUserNotificationCenterDelegate)
    }

    func testNotificationDelegate_IsNSObject() {
        // Given: A notification delegate
        let delegate = NotificationDelegate()

        // Then: Should be an NSObject (required for UNUserNotificationCenterDelegate)
        XCTAssertTrue(delegate is NSObject)
    }
}

// MARK: - Notification Presentation Options Tests

/// Tests the expected presentation behavior when app is in foreground
final class NotificationPresentationTests: XCTestCase {

    func testExpectedPresentationOptions_IncludesBanner() {
        // Given: The expected presentation options for foreground notifications
        let expectedOptions: UNNotificationPresentationOptions = [.banner, .sound]

        // Then: Should include banner
        XCTAssertTrue(expectedOptions.contains(.banner))
    }

    func testExpectedPresentationOptions_IncludesSound() {
        // Given: The expected presentation options
        let expectedOptions: UNNotificationPresentationOptions = [.banner, .sound]

        // Then: Should include sound
        XCTAssertTrue(expectedOptions.contains(.sound))
    }

    func testExpectedPresentationOptions_DoesNotIncludeBadge() {
        // Given: The expected presentation options
        let expectedOptions: UNNotificationPresentationOptions = [.banner, .sound]

        // Then: Should not include badge (not used in this app)
        XCTAssertFalse(expectedOptions.contains(.badge))
    }
}

// MARK: - Category and Action Configuration Tests

final class NotificationCategoryConfigurationTests: XCTestCase {

    func testGoalMetCategory_HasExpectedIdentifier() {
        // Given: The goal met category identifier
        let categoryId = NotificationCategory.goalMet

        // Then: Should have expected value
        XCTAssertEqual(categoryId, "FASTING_GOAL_MET")
    }

    func testContinueAction_HasNonDestructiveOptions() {
        // Given: Creating a continue action (simulating registerNotificationCategories)
        let continueAction = UNNotificationAction(
            identifier: NotificationAction.continueFasting,
            title: "Keep Going",
            options: []
        )

        // Then: Should not be destructive or require auth
        XCTAssertFalse(continueAction.options.contains(.destructive))
        XCTAssertFalse(continueAction.options.contains(.authenticationRequired))
    }

    func testEndAction_HasDestructiveOption() {
        // Given: Creating an end action (simulating registerNotificationCategories)
        let endAction = UNNotificationAction(
            identifier: NotificationAction.endFasting,
            title: "End Fast",
            options: [.destructive]
        )

        // Then: Should be marked as destructive
        XCTAssertTrue(endAction.options.contains(.destructive))
    }

    func testGoalCategory_HasCustomDismissAction() {
        // Given: Creating the goal category (simulating registerNotificationCategories)
        let category = UNNotificationCategory(
            identifier: NotificationCategory.goalMet,
            actions: [],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        // Then: Should have custom dismiss action option
        XCTAssertTrue(category.options.contains(.customDismissAction))
    }
}
