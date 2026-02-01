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
        SmallSystemWidget() // home screen
        AccessoryWidget() // lock screen / control center
    }
}
