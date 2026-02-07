//
//  AnalyticsManager.swift
//  LastFast
//

import AppTrackingTransparency
import FirebaseAnalytics

struct AnalyticsManager {
    static func requestTrackingPermission() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .authorized:
                    // Tracking authorized
                    Analytics.setAnalyticsCollectionEnabled(true)
                case .denied:
                    // Tracking denied
                    Analytics.setAnalyticsCollectionEnabled(false)
                case .notDetermined:
                    // Tracking not determined
                    Analytics.setAnalyticsCollectionEnabled(false)
                case .restricted:
                    // Tracking restricted
                    Analytics.setAnalyticsCollectionEnabled(false)
                @unknown default:
                    Analytics.setAnalyticsCollectionEnabled(false)
                }
            }
        }
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
