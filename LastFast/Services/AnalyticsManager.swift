//
//  AnalyticsManager.swift
//  LastFast
//

import AppTrackingTransparency
import FirebaseAnalytics

struct AnalyticsManager {
    static func requestTrackingPermission() {
        if #available(iOS 14, *) {
            print("AnalyticsManager: Requesting tracking permission...")
            print("AnalyticsManager: Current tracking authorization status: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)") // Raw value for easier debugging
            ATTrackingManager.requestTrackingAuthorization { status in
                print("AnalyticsManager: ATTrackingManager.requestTrackingAuthorization completion handler. Status: \(status.rawValue)") // Raw value for easier debugging
                switch status {
                case .authorized:
                    // Tracking authorized
                    Analytics.setAnalyticsCollectionEnabled(true)
                    print("AnalyticsManager: Analytics collection enabled.")
                case .denied:
                    // Tracking denied
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (denied).")
                case .notDetermined:
                    // Tracking not determined
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (notDetermined).")
                case .restricted:
                    // Tracking restricted
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (restricted).")
                @unknown default:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (unknown default).")
                }
            }
        } else {
            print("AnalyticsManager: iOS version is below 14. Tracking permission not requested.")
        }
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
