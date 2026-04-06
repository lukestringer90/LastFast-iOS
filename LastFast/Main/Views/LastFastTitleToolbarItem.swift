//
//  LastFastTitleToolbarItem.swift
//  LastFast
//
//  Reusable toolbar item showing the app icon and "Last Fast" title.
//  Pass an action to make it a tappable button (e.g. to open Settings).
//

import SwiftUI

struct LastFastTitleToolbarItem: ToolbarContent {
    var action: (() -> Void)? = nil

    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            let label = HStack(spacing: 6) {
                Image("AppIconDisplay")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                Text("Last Fast")
                    .font(.headline)
            }

            if let action {
                Button(action: action) { label }
                    .tint(.primary)
                    .accessibilityLabel("Settings")
            } else {
                label
            }
        }
    }
}
