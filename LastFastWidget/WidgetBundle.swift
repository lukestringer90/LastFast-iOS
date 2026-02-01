//
//  WidgetBundle.swift
//  LastFastWidget
//
//  Widget bundle registration
//

import SwiftUI
import WidgetKit

@main
struct LastFastWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockScreenAccessoryWidget() // home screen
        HomeScreenSmallWidget() // lock screen / control center
    }
}
