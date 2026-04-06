//
//  AnalyticsManager.swift
//  LastFast
//

import AppTrackingTransparency
import FirebaseAnalytics

struct AnalyticsManager {
    /// Requests ATT tracking permission from the user.
    /// - Parameter completion: Called on the main thread once the user has responded to the permission alert.
    static func requestTrackingPermission(completion: @escaping () -> Void = {}) {
        if #available(iOS 14, *) {
            print("AnalyticsManager: Requesting tracking permission...")
            print("AnalyticsManager: Current tracking authorization status: \(ATTrackingManager.trackingAuthorizationStatus.rawValue)")
            ATTrackingManager.requestTrackingAuthorization { status in
                print("AnalyticsManager: ATTrackingManager.requestTrackingAuthorization completion handler. Status: \(status.rawValue)")
                switch status {
                case .authorized:
                    Analytics.setAnalyticsCollectionEnabled(true)
                    print("AnalyticsManager: Analytics collection enabled.")
                case .denied:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (denied).")
                case .notDetermined:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (notDetermined).")
                case .restricted:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (restricted).")
                @unknown default:
                    Analytics.setAnalyticsCollectionEnabled(false)
                    print("AnalyticsManager: Analytics collection disabled (unknown default).")
                }
                DispatchQueue.main.async { completion() }
            }
        } else {
            print("AnalyticsManager: iOS version is below 14. Tracking permission not requested.")
            completion()
        }
    }

    static func logEvent(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }
}
