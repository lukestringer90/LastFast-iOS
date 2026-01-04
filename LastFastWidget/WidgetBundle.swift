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
        // Home Screen Widgets
        LastFastWidget()
        EndTimeWidget()
        
        // Lock Screen Circular Widgets
        CircularEndTimeWidget()
        
        // Lock Screen Rectangular Widgets
        RectangularCombinedWidget()
        RectangularCombinedRightWidget()
        RectangularCombinedCenterWidget()
        
        // Spacer Widgets
        SpacerWidget()
        RectangularSpacerWidget()
        
        // Live Activity
        LastFastWidgetLiveActivity()
    }
}
