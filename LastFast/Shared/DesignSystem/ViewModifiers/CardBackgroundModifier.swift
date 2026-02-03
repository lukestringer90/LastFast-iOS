//
//  CardBackgroundModifier.swift
//  LastFast
//
//  ViewModifier for card-style backgrounds
//

import SwiftUI

// MARK: - Card Background Modifier

struct CardBackgroundModifier: ViewModifier {
    var cornerRadius: CGFloat = 12
    var padding: CGFloat = 16

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(uiColor: .secondarySystemBackground))
            )
    }
}

// MARK: - View Extension

extension View {
    func cardBackground(cornerRadius: CGFloat = 12, padding: CGFloat = 16) -> some View {
        modifier(CardBackgroundModifier(cornerRadius: cornerRadius, padding: padding))
    }
}
