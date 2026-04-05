//
//  TipOption.swift
//  LastFast
//
//  Tip jar tier definitions
//

import Foundation

enum TipOption: CaseIterable, Identifiable {
    case small, nice, big

    var id: Self { self }

    var name: String {
        switch self {
        case .small: return "Small Tip"
        case .nice: return "Nice Tip"
        case .big: return "Big Tip"
        }
    }

    var price: String {
        switch self {
        case .small: return "$0.99"
        case .nice: return "$2.99"
        case .big: return "$4.99"
        }
    }

    var emoji: String {
        switch self {
        case .small: return "☕️"
        case .nice: return "🍕"
        case .big: return "🎉"
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
