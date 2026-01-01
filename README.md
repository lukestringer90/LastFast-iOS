# LastFast - Xcode Project Setup Guide

## Project Structure

```
LastFast/
├── LastFast/                    # iOS App Target
│   ├── LastFastApp.swift        # App entry point
│   ├── ContentView.swift              # Main iOS UI
│   └── FastingIntents.swift           # Siri App Intents
├── LastFastWatch/               # watchOS App Target  
│   ├── LastFastWatchApp.swift   # Watch app entry point
│   └── WatchContentView.swift         # Watch UI
├── LastFastWidget/                    # iOS Widget Extension
│   └── LastFastWidget.swift           # Home Screen widgets
├── LastFastWatchWidget/               # watchOS Widget Extension
│   └── LastFastWatchWidget.swift      # Watch complications
└── Shared/                            # Shared Code
    └── FastingSession.swift           # SwiftData model
```

## Xcode Project Setup

### 1. Create New Project
1. Open Xcode 16.2
2. File → New → Project
3. Select "App" under iOS
4. Product Name: `LastFast`
5. Team: Your development team
6. Organization Identifier: `com.yourname`
7. Interface: SwiftUI
8. Storage: SwiftData
9. Check "Include Tests" if desired

### 2. Add watchOS Target
1. File → New → Target
2. Select "App" under watchOS
3. Product Name: `LastFastWatch`
4. Embed in: LastFast

### 3. Add Widget Extension (iOS)
1. File → New → Target
2. Select "Widget Extension" under iOS
3. Product Name: `LastFastWidget`
4. Uncheck "Include Configuration Intent" (we use static config)
5. Replace generated code with LastFastWidget.swift content

### 4. Add Widget Extension (watchOS)
1. File → New → Target
2. Select "Widget Extension" under watchOS
3. Product Name: `LastFastWatchWidget`
4. Uncheck "Include Configuration Intent"
5. Replace generated code with LastFastWatchWidget.swift content

### 5. Configure App Groups
All targets need access to shared data:

1. Select LastFast target → Signing & Capabilities
2. Click "+ Capability" → App Groups
3. Add group: `group.com.fastingtracker.shared`
4. Repeat for LastFastWatch target
5. Repeat for LastFastWidget target

### 5. Add Shared Files
1. Create a "Shared" group in your project
2. Add `FastingSession.swift` to the Shared group
3. In File Inspector, check all targets for Target Membership:
   - LastFast
   - LastFastWatch
   - LastFastWidgetExtension

### 6. Configure Siri Support
1. Select LastFast target → Signing & Capabilities
2. Click "+ Capability" → Siri
3. In Info.plist, add:
   - `NSSiriUsageDescription`: "Allows you to start and stop fasting with your voice"

## Required Capabilities

### iOS Target
- App Groups: `group.com.fastingtracker.shared`
- Siri

### watchOS Target  
- App Groups: `group.com.fastingtracker.shared`

### iOS Widget Extension
- App Groups: `group.com.fastingtracker.shared`

### watchOS Widget Extension
- App Groups: `group.com.fastingtracker.shared`

## Info.plist Entries

### iOS App
```xml
<key>NSSiriUsageDescription</key>
<string>Allows you to start and stop fasting with your voice</string>
<key>CFBundleDisplayName</key>
<string>Last Fast</string>
```

## Build Settings

### Deployment Targets (Xcode 16.2)
- iOS: 18.0
- watchOS: 11.0

### Swift Version
- Swift 5.9 or 6.0

## Widget Setup

The widget extension provides two sizes:
- **Small**: Shows current fast duration or last fast duration
- **Medium**: Shows timer with remaining time and finish time

To refresh the widget when fasting state changes, add this to your main app where you start/stop fasts:

```swift
import WidgetKit

// After starting or stopping a fast:
WidgetCenter.shared.reloadAllTimelines()
```

## Testing Siri Commands

After installing on device:
1. "Hey Siri, start fasting in Last Fast"
2. "Hey Siri, how long have I been fasting"
3. "Hey Siri, stop my fast"

Or add shortcuts manually in the Shortcuts app.

## Features Summary

### iOS App
- ✅ Large timer display showing current fast duration
- ✅ Start/Stop button with confirmation
- ✅ Customizable fasting goals
- ✅ Time remaining and finish time display
- ✅ Complete fasting history with goal tracking
- ✅ Swipe to delete past fasts
- ✅ Data persists between app launches

### watchOS App
- ✅ Simple timer display
- ✅ Start/Stop button
- ✅ Syncs with iOS app via App Groups

### Widget Extension
- ✅ Small widget: Current or last fast duration
- ✅ Medium widget: Timer with time remaining and finish time
- ✅ Updates every minute when fasting
- ✅ Tap to open app

### Siri Integration
- ✅ "Start fasting" - begins a new fast
- ✅ "Stop fasting" - ends current fast, reports duration
- ✅ "Check fasting status" - reports current fast duration

## Customization Ideas

- Add Live Activities for lock screen
- Add fasting streak tracking
- Add notifications when reaching goal
- Add complications for Watch face
- Add HealthKit integration
- Add statistics/charts for fasting trends
