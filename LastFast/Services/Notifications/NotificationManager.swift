//
//  NotificationManager.swift
//  LastFast
//
//  Handles local notification scheduling and management
//

import Foundation
import UserNotifications

// MARK: - Notification Manager

struct NotificationManager {
    
    // MARK: - Permission
    
    /// Requests notification permission from the user
    static func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
        
        // Register notification categories with actions
        registerNotificationCategories()
    }
    
    /// Registers notification categories with action buttons
    private static func registerNotificationCategories() {
        // Actions for goal notification
        let continueAction = UNNotificationAction(
            identifier: NotificationAction.continueFasting,
            title: "Keep Going 💪",
            options: []
        )
        let endAction = UNNotificationAction(
            identifier: NotificationAction.endFasting,
            title: "End Fast",
            options: [.destructive]
        )
        
        let goalCategory = UNNotificationCategory(
            identifier: NotificationCategory.goalMet,
            actions: [continueAction, endAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([goalCategory])
    }
    
    // MARK: - Goal Notification
    
    /// Schedules a notification for 1 hour before the goal is met
    /// - Parameters:
    ///   - startTime: When the fast started
    ///   - goalMinutes: The goal duration in minutes
    static func scheduleOneHourBeforeNotification(startTime: Date, goalMinutes: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Calculate when the goal will be met
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let oneHourBefore = goalTime.addingTimeInterval(-3600) // 1 hour before
        let timeUntilOneHourBefore = oneHourBefore.timeIntervalSinceNow
        
        // Only schedule if one hour before is in the future
        guard timeUntilOneHourBefore > 0 else { return }
        
        // Format the goal time
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let goalTimeText = timeFormatter.string(from: goalTime)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "⏰ One Hour to Go!"
        content.body = "You're almost there! Your goal will be complete at \(goalTimeText)"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        // Create trigger for 1 hour before goal
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilOneHourBefore, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: NotificationIdentifier.oneHourBefore, content: content, trigger: trigger)
        
        // Schedule notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling one hour notification: \(error)")
            } else {
                print("One hour notification scheduled for \(oneHourBefore)")
            }
        }
    }
    
    /// Schedules a notification for when the fasting goal is met
    /// - Parameters:
    ///   - startTime: When the fast started
    ///   - goalMinutes: The goal duration in minutes
    static func scheduleGoalNotification(startTime: Date, goalMinutes: Int) {
        let center = UNUserNotificationCenter.current()
        
        // Calculate when the goal will be met
        let goalTime = startTime.addingTimeInterval(TimeInterval(goalMinutes * 60))
        let timeUntilGoal = goalTime.timeIntervalSinceNow
        
        // Only schedule if goal is in the future
        guard timeUntilGoal > 0 else { return }
        
        // Format the goal duration for the title
        let goalText = formatGoalText(goalMinutes: goalMinutes)
        
        // Format times for the body
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let startTimeText = timeFormatter.string(from: startTime)
        let endTimeText = timeFormatter.string(from: goalTime)
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "🎉 Goal Achieved - \(goalText)"
        content.body = "Amazing work! You fasted from \(startTimeText) → \(endTimeText)"
        content.sound = UNNotificationSound.defaultCritical
        content.categoryIdentifier = NotificationCategory.goalMet
        content.interruptionLevel = .timeSensitive
        
        // Create trigger for when goal is met
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeUntilGoal, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(identifier: NotificationIdentifier.goalMet, content: content, trigger: trigger)
        
        // Schedule notification
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Goal notification scheduled for \(goalTime)")
            }
        }
    }
    
    /// Cancels any pending goal notifications
    static func cancelGoalNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ])
        center.removeDeliveredNotifications(withIdentifiers: [
            NotificationIdentifier.goalMet,
            NotificationIdentifier.oneHourBefore
        ])
    }
    
    // MARK: - Helpers
    
    private static func formatGoalText(goalMinutes: Int) -> String {
        let goalHours = goalMinutes / 60
        let goalMins = goalMinutes % 60
        
        if goalHours > 0 && goalMins > 0 {
            return "\(goalHours)h \(goalMins)m"
        } else if goalHours > 0 {
            return "\(goalHours)h"
        } else {
            return "\(goalMins)m"
        }
    }
}

// MARK: - Notification Identifiers

enum NotificationIdentifier {
    static let goalMet = "goalMet"
    static let oneHourBefore = "oneHourBefore"
}
// MARK: - Notification Categories

enum NotificationCategory {
    static let goalMet = "FASTING_GOAL_MET"
}

// MARK: - Notification Actions

enum NotificationAction {
    static let continueFasting = "CONTINUE_FASTING"
    static let endFasting = "END_FASTING"
}

