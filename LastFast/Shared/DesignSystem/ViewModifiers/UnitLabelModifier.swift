//
//  UnitLabelModifier.swift
//  LastFast
//
//  ViewModifier for time unit labels (h, m)
//

import SwiftUI

// MARK: - Unit Label Modifier

struct UnitLabelModifier: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.system(size: 36, weight: .medium, design: .rounded))
            .foregroundStyle(color.opacity(0.7))
    }
}

// MARK: - View Extension

extension View {
    func unitLabel(color: Color) -> some View {
        modifier(UnitLabelModifier(color: color))
    }
}
