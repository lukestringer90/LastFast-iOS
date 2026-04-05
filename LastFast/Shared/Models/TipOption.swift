//
//  TipOption.swift
//  LastFast
//
//  Tip jar tier definitions
//

import SwiftUI

enum TipOption: CaseIterable, Identifiable {
    case small, nice, big

    var id: Self { self }

    var name: String {
        switch self {
        case .small: return "Kind Tip"
        case .nice: return "Generous Tip"
        case .big: return "Amazing Tip"
        }
    }

    var price: String {
        switch self {
        case .small: return "$0.99"
        case .nice: return "$2.99"
        case .big: return "$4.99"
        }
    }

    var systemImage: String {
        switch self {
        case .small: return "cup.and.saucer.fill"
        case .nice: return "heart.fill"
        case .big: return "star.fill"
        }
    }

    var color: Color {
        switch self {
        case .small: return .blue
        case .nice: return .green
        case .big: return Color(red: 0.83, green: 0.68, blue: 0.21)
        }
    }

    /// Placeholder product ID for future StoreKit integration
    var productID: String {
        switch self {
        case .small: return "dev.stringer.lastfast.tip.small"
        case .nice: return "dev.stringer.lastfast.tip.nice"
        case .big: return "dev.stringer.lastfast.tip.big"
        }
    }
}
