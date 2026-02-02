//
//  NotificationDelegate.swift
//  LastFast
//
//  Handles notification actions and responses
//

import Foundation
import UserNotifications
import SwiftData
import WidgetKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // MARK: - Notification Actions
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        
        switch actionIdentifier {
        case NotificationAction.continueFasting:
            // User wants to continue fasting - just dismiss
            print("User chose to continue fasting")
            
        case NotificationAction.endFasting:
            // User wants to end the fast
            print("User chose to end fasting from notification")
            endActiveFast()
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body - open app
            print("User tapped notification")
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Presentation
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // MARK: - Helper Methods
    
    private func endActiveFast() {
        do {
            let schema = Schema([FastingSession.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                groupContainer: .identifier("group.dev.stringer.lastfast.shared")
            )
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let context = ModelContext(container)
            
            let descriptor = FetchDescriptor<FastingSession>(
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            let sessions = try context.fetch(descriptor)
            
            if let activeFast = sessions.first(where: { $0.isActive }) {
                activeFast.stop()
                try context.save()
                
                // Update shared UserDefaults
                let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
                defaults?.set(false, forKey: "isFasting")
                defaults?.removeObject(forKey: "fastingStartTime")
                
                // Reload widgets
                WidgetCenter.shared.reloadAllTimelines()
                
                // End Live Activity
                LiveActivityManager.end()
                
                print("Fast ended successfully from notification action")
            }
        } catch {
            print("Error ending fast from notification: \(error)")
        }
    }
}
