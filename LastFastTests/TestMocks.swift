//
//  TestMocks.swift
//  LastFastTests
//
//  Shared mock dependencies for testing
//

import Foundation

/// Mock UserDefaults for testing without affecting real storage
final class MockUserDefaults {
    private var storage: [String: Any] = [:]
    
    func set(_ value: Any?, forKey key: String) {
        storage[key] = value
    }
    
    func object(forKey key: String) -> Any? {
        return storage[key]
    }
    
    func double(forKey key: String) -> Double {
        return storage[key] as? Double ?? 0
    }
    
    func integer(forKey key: String) -> Int {
        return storage[key] as? Int ?? 0
    }
    
    func bool(forKey key: String) -> Bool {
        return storage[key] as? Bool ?? false
    }
    
    func removeObject(forKey key: String) {
        storage.removeValue(forKey: key)
    }
    
    func reset() {
        storage.removeAll()
    }
}

/// Mock Date provider for deterministic testing
struct MockDateProvider {
    static var currentDate: Date = Date()
    
    static func now() -> Date {
        return currentDate
    }
    
    static func reset() {
        currentDate = Date()
    }
    
    static func setDate(_ date: Date) {
        currentDate = date
    }
    
    static func advanceBy(seconds: TimeInterval) {
        currentDate = currentDate.addingTimeInterval(seconds)
    }
    
    static func advanceBy(minutes: Int) {
        advanceBy(seconds: TimeInterval(minutes * 60))
    }
    
    static func advanceBy(hours: Int) {
        advanceBy(seconds: TimeInterval(hours * 3600))
    }
}
