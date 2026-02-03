//
//  LargeTimerFontModifier.swift
//  LastFast
//
//  ViewModifier for the large timer display font
//

import SwiftUI

// MARK: - Large Timer Font Modifier

struct LargeTimerFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 96, weight: .bold, design: .rounded))
    }
}

// MARK: - View Extension

extension View {
    func largeTimerFont() -> some View {
        modifier(LargeTimerFontModifier())
    }
}
