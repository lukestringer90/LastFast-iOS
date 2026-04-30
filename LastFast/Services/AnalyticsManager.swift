//
//  AnalyticsManager.swift
//  LastFast
//

import FirebaseAnalytics

struct AnalyticsManager {
    /// Enables analytics collection. Call this at app launch.
    static func initialize() {
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
