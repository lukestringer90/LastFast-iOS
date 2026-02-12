// LastFastApp.swift
// LastFast
// iOS 18 Intermittent Last Fast (Xcode 16.2)

import SwiftUI
import SwiftData
import BackgroundTasks
import ActivityKit
import FirebaseCore
import AppTrackingTransparency

// Note: liveActivityEnabled is defined in FastingView.swift

@main
struct LastFastApp: App {
    @Environment(\.scenePhase) private var scenePhase
    
    // Notification delegate to handle action buttons
    private let notificationDelegate = NotificationDelegate()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([FastingSession.self])

        // CloudKit-enabled configuration for iCloud sync
        let cloudConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .private("iCloud.dev.stringer.lastfast")
        )

        do {
            return try ModelContainer(for: schema, configurations: [cloudConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        FirebaseApp.configure()
        // Set notification delegate
        UNUserNotificationCenter.current().delegate = notificationDelegate
        
        // Register background task (only if Live Activity is enabled)
        if liveActivityEnabled {
            BGTaskScheduler.shared.register(forTaskWithIdentifier: "dev.stringer.lastfast.refresh", using: nil) { task in
                Self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            FastingView()
                .onAppear {
                    Task {
                        try? await Task.sleep(nanoseconds:500_000_000) // 0.5 seconds
                        AnalyticsManager.requestTrackingPermission()
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .background && liveActivityEnabled {
                Self.scheduleAppRefresh()
            }
        }
    }
    
    static func scheduleAppRefresh() {
        guard liveActivityEnabled else { return }
        
        let request = BGAppRefreshTaskRequest(identifier: "dev.stringer.lastfast.refresh")
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60) // Request refresh in 1 minute
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("Background refresh scheduled")
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    static func handleAppRefresh(task: BGAppRefreshTask) {
        guard liveActivityEnabled else {
            task.setTaskCompleted(success: true)
            return
        }
        
        // Schedule the next refresh
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        // Update Live Activity
        updateLiveActivityInBackground()
        
        task.setTaskCompleted(success: true)
    }
    
    static func updateLiveActivityInBackground() {
        guard liveActivityEnabled else { return }
        
        // Get active fast from UserDefaults (shared with widgets)
        let defaults = UserDefaults(suiteName: "group.dev.stringer.lastfast.shared")
        
        guard let startTimeInterval = defaults?.object(forKey: "fastingStartTime") as? TimeInterval else {
            return
        }
        
        let startTime = Date(timeIntervalSince1970: startTimeInterval)
        let goalMinutes = defaults?.integer(forKey: "fastingGoalMinutes") ?? 480
        let elapsed = Int(Date().timeIntervalSince(startTime))
        let goalMet = elapsed >= goalMinutes * 60
        
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
}
