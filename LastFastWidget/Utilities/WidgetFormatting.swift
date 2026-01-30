//
//  WidgetFormatting.swift
//  LastFastWidget
//
//  Shared formatting functions for widgets
//

import Foundation

func formatWidgetDuration(hours: Int, minutes: Int) -> String {
    if hours > 0 && minutes > 0 {
        return "\(hours)h \(minutes)m"
    } else if hours > 0 {
        return "\(hours)h"
    } else {
        return "\(minutes)m"
    }
}
