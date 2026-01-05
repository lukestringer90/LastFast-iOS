# LastFast - Fasting Timer App

## Overview

LastFast is an intermittent fasting timer app for Apple platforms. It allows users to track fasting sessions with customizable goals, view history, and monitor progress through widgets and a companion watch app.

## Technical Stack

### Languages & Frameworks
- **Swift** (100% Swift codebase)
- **SwiftUI** for all UI
- **SwiftData** for persistence (Apple's modern data framework, successor to Core Data)
- **WidgetKit** for home screen and lock screen widgets
- **ActivityKit** for Live Activities (Dynamic Island and lock screen live updates)
- **App Intents** for Siri integration and Shortcuts support
- **WatchConnectivity** would be needed for phone-watch sync (not yet implemented)

### Supported Platforms
- **iOS 17.0+**
- **watchOS 10.0+**
- **Xcode 15+** (required for SwiftData and iOS 17 features)

### Project Structure
```
LastFast/
├── LastFast/                    # Main iOS app
├── LastFastWidget/              # iOS widget extension
├── LastFastWatch Watch App/     # watchOS app
├── LastFastWatchWidget/         # watchOS widget extension
├── LastFastTests/               # Unit tests
├── LastFastUITests/             # UI tests
└── Shared/                      # Shared model files
```

---

## Core Data Model

### FastingSession (SwiftData @Model)
Located in `Shared/FastingSession.swift` and `LastFast/Shared/FastingSession.swift`

```swift
@Model
class FastingSession {
    var startTime: Date
    var endTime: Date?           // nil = currently active
    var goalMinutes: Int?        // fasting goal in minutes
    
    var isActive: Bool           // computed: endTime == nil
    var duration: TimeInterval   // computed: time from start to end (or now if active)
    var goalMet: Bool           // computed: duration >= goal
}
```

Data is stored using SwiftData with an App Group (`group.com.xxx.LastFast`) to share data between the main app and widget extensions.

---

## Main iOS App Features

### ContentView.swift
The main view with two states:

**Not Fasting State:**
- Goal setter (tappable card showing current goal and estimated finish time)
- "Start Fast" button
- Last fast card (shows most recent completed fast with duration, date, goal status)
- History button

**Active Fasting State:**
- Large circular timer display showing hours:minutes
- Circular progress ring (orange, turns green when goal met)
- Goal and start time info
- "Stop Fast" button
- Last fast card
- History button

**Feature Flag:**
- `useGraphHistoryView` (Bool) - controls whether history view shows graph or list style

### GoalPickerView.swift
Modal sheet for setting fasting goals with two modes:

1. **Duration Mode**: Steppers for hours (0-72) and minutes (0-59)
2. **End Time Mode**: DatePicker to select target completion time, calculates minutes automatically

Values sync when switching between modes.

### HistoryView.swift
Displays fasting history with graph visualization:

- Bar chart showing last 5 fasts
- Duration labels above each bar (e.g., "16h30m")
- Date labels below (dd/MM format)
- Goal line overlay (white/black depending on appearance) connecting goal points
- Bars colored green (goal met) or orange (goal not met)
- Tappable bars show expanded session details
- Swipe-to-delete on selected session card
- "View All Fasts" button opens full list view
- Statistics card (total fasts, goals met, average duration)

### HistoryListView.swift
Traditional list view of all fasts with swipe-to-delete.

### TimerDisplayView.swift
Reusable circular timer component with:
- Large time display (hours:minutes)
- Circular progress ring
- Color changes (orange → green) when goal met
- Checkmark icon when goal achieved

### Supporting Files
- **DurationFormatting.swift**: Helper functions for time formatting (`formatDuration`, `hoursAndMinutes`, `format24HourTime`)
- **NotificationManager.swift**: Local notification scheduling for goal completion (no badge, just alert + sound)
- **LiveActivityManager.swift**: Manages Live Activity for active fasts
- **FastingIntents.swift**: App Intents for Siri ("Start fasting", "Stop fasting", "How long have I been fasting?")
- **FastingHistoryRow.swift**: Row component for history list

---

## iOS Widgets (LastFastWidget/)

### Widget Types Available

**Medium Home Screen Widget:**
- Active state: Countdown timer, progress bar, elapsed time, start/end times
- Goal met state: Large green elapsed time with checkmark
- Inactive state: Bar chart of last 5 fasts (same style as HistoryView)

**Small End Time Widget:**
- Shows estimated fast end time
- Different states for active/inactive/goal met

**Lock Screen Widgets (various sizes):**
- Circular, rectangular, inline variants
- Show elapsed time, countdown, or progress

**Accessory Widgets:**
- Corner widget
- Rectangular widget for lock screen

### Widget Architecture

- **FastingEntry.swift**: Timeline entry data structure
- **FastingTimelineProvider.swift**: Provides widget data, reads from SwiftData via App Group
- **MediumWidgetView.swift**: Medium widget implementation
- **LockScreenWidgetViews.swift**: All lock screen widget variants
- **EndTimeWidget.swift**: Small end time widget
- **WidgetFormatting.swift**: Shared formatting helpers
- **WidgetBundle.swift**: Registers all widgets

### Data Structure for Widget History
```swift
struct FastHistoryData: Hashable {
    let startDate: Date
    let fastedHours: Double
    let goalHours: Double
    let goalMet: Bool
}
```

---

## watchOS App (LastFastWatch Watch App/)

### Features
- Mirror of iOS app functionality
- Start/stop fasting
- View current fast progress
- Circular timer display
- Goal setting

### Watch Widgets (LastFastWatchWidget/)
- Accessory widgets for watch faces
- Shows fasting status and elapsed time

---

## Live Activity

Implemented in `LastFastWidgetLiveActivity.swift`:
- Shows on Dynamic Island (compact and expanded views)
- Lock screen live activity
- Updates countdown/elapsed time
- Displays goal progress

---

## App Intents (Siri Integration)

Three intents in `FastingIntents.swift`:

1. **StartFastingIntent**: "Start fasting" - begins a new fast
2. **StopFastingIntent**: "Stop fasting" - ends current fast
3. **FastingStatusIntent**: "How long have I been fasting?" - reports current status

---

## Key Implementation Details

### App Group
`group.com.xxx.LastFast` - Used to share SwiftData store between main app and extensions.

### Timeline Updates
Widgets use `TimelineReloadPolicy.after(date)` with 15-minute intervals for inactive state, more frequent updates during active fasts.

### Graph Rendering
Both HistoryView and MediumWidgetView use the same visual approach:
- GeometryReader for dynamic sizing
- Bars and goal line share identical Y-axis calculation: `(value / maxValue) * areaHeight`
- ZStack with bottom alignment for bar/line overlay
- Path for goal line, positioned Circle for dots

### Color Scheme
- Orange: Active fast, goal not met
- Green: Goal met
- Primary (white/black): Goal line (adapts to light/dark mode)
- Secondary: Date labels, helper text

---

## Test Suite

Located in `LastFastTests/`:
- **FastingSessionTests.swift**: Model tests
- **TimeFormattingTests.swift**: Formatting function tests
- **GoalCalculationTests.swift**: Goal logic tests
- **FastingWorkflowTests.swift**: Integration tests
- **ConstantsTests.swift**: Constants validation
- **TestMocks.swift**: Mock objects for testing

~70 test methods total.

---

## Known Limitations / Future Work

1. **No Phone-Watch Sync**: Watch app has independent data store; WatchConnectivity not implemented
2. **No CloudKit Sync**: Data is local only
3. **No Widgets for Large Size**: Large home screen widget was removed
4. **No iPad Optimization**: Works but not optimized for larger screens
5. **No Localization**: English only, date formats hardcoded

---

## File Locations Summary

| Component | Path |
|-----------|------|
| Main App Entry | `LastFast/LastFastApp.swift` |
| Main UI | `LastFast/ContentView.swift` |
| Data Model | `Shared/FastingSession.swift` |
| Widgets | `LastFastWidget/*.swift` |
| Watch App | `LastFastWatch Watch App/*.swift` |
| Tests | `LastFastTests/*.swift` |
| Project File | `LastFast.xcodeproj` |

---

## Building & Running

1. Open `LastFast.xcodeproj` in Xcode 15+
2. Select appropriate scheme (LastFast for iOS, LastFastWatch for watchOS)
3. Build and run on simulator or device
4. For widgets: Run once, then add widget from home screen
5. For Live Activity: Start a fast to see it appear

**Note**: Info.plist files are managed by Xcode and excluded from version control exports.
