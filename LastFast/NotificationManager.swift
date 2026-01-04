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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    
    // MARK: - Goal Notification
    
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
        content.title = "Goal Achieved - \(goalText)"
        content.body = "\(startTimeText) → \(endTimeText)"
        content.sound = UNNotificationSound.defaultCritical
        content.badge = 1
        
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
        center.removePendingNotificationRequests(withIdentifiers: [NotificationIdentifier.goalMet])
        center.removeDeliveredNotifications(withIdentifiers: [NotificationIdentifier.goalMet])
        
        // Also clear badge
        center.setBadgeCount(0) { error in
            if let error = error {
                print("Error clearing badge: \(error)")
            }
        }
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
}
