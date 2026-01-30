//
//  LiveActivityManager.swift
//  LastFast
//
//  Manages Live Activity lifecycle and updates
//

import Foundation
import ActivityKit

// MARK: - Live Activity Feature Flag

/// Set to `true` to enable Live Activities, `false` to disable
let liveActivityEnabled = false

// MARK: - Live Activity Manager

struct LiveActivityManager {
    
    // MARK: - Start
    
    /// Starts a new Live Activity for the fasting session
    /// - Parameters:
    ///   - startTime: When the fast started
    ///   - goalMinutes: The goal duration in minutes
    static func start(startTime: Date, goalMinutes: Int) {
        guard liveActivityEnabled else { return }
        
        let authInfo = ActivityAuthorizationInfo()
        
        print("Live Activity Debug:")
        print("  - areActivitiesEnabled: \(authInfo.areActivitiesEnabled)")
        print("  - frequentPushesEnabled: \(authInfo.frequentPushesEnabled)")
        
        guard authInfo.areActivitiesEnabled else {
            print("  - Live Activities are NOT enabled!")
            return
        }
        
        let attributes = LastFastWidgetAttributes(
            startTime: startTime,
            goalMinutes: goalMinutes
        )
        
        let initialState = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: Int(Date().timeIntervalSince(startTime)),
            goalMet: false
        )
        
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            print("  - Live Activity started successfully! ID: \(activity.id)")
        } catch {
            print("  - Failed to start Live Activity: \(error)")
        }
    }
    
    // MARK: - Update
    
    /// Updates all active Live Activities with current state
    /// - Parameters:
    ///   - startTime: When the fast started
    ///   - goalMinutes: The goal duration in minutes (optional)
    static func update(startTime: Date, goalMinutes: Int?) {
        guard liveActivityEnabled else { return }
        
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let goalMet = goalMinutes.map { elapsed >= $0 * 60 } ?? false
        
        let updatedState = LastFastWidgetAttributes.ContentState(
            elapsedSeconds: elapsed,
            goalMet: goalMet
        )
        
        let content = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            for activity in Activity<LastFastWidgetAttributes>.activities {
                await activity.update(content)
            }
        }
    }
    
    // MARK: - End
    
    /// Ends all active Live Activities
    static func end() {
        guard liveActivityEnabled else { return }
        
        Task {
            for activity in Activity<LastFastWidgetAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
    
    // MARK: - Resume
    
    /// Resumes Live Activity if there's an active fast but no Live Activity
    /// - Parameters:
    ///   - startTime: When the fast started (nil if no active fast)
    ///   - goalMinutes: The goal duration in minutes
    static func resumeIfNeeded(startTime: Date?, goalMinutes: Int) {
        guard liveActivityEnabled else { return }
        
        guard let startTime = startTime else {
            // No active fast, end any stale activities
            end()
            return
        }
        
        // Check if there's already an active Live Activity
        if Activity<LastFastWidgetAttributes>.activities.isEmpty {
            // Start a new Live Activity for the existing fast
            start(startTime: startTime, goalMinutes: goalMinutes)
        }
        
        // Update immediately
        update(startTime: startTime, goalMinutes: goalMinutes)
    }
    
    // MARK: - Status
    
    /// Returns whether Live Activities are enabled on the device
    static var areActivitiesEnabled: Bool {
        ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    /// Returns the number of currently active Live Activities
    static var activeCount: Int {
        Activity<LastFastWidgetAttributes>.activities.count
    }
}
