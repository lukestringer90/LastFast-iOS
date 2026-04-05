//
//  TipJarView.swift
//  LastFast
//
//  Tip jar sheet showing available tip options
//

import SwiftUI

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(TipOption.allCases) { option in
                    Button {
                        purchaseTip(option)
                    } label: {
                        HStack {
                            Label(option.name, systemImage: option.systemImage)
                                .foregroundStyle(option.color)
                            Spacer()
                            Text(option.price)
                                .fontWeight(.medium)
                                .foregroundStyle(option.color)
                        }
                    }
                    .tint(.primary)
                }
            }
            .navigationTitle("Leave a Tip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.height(280)])
    }

    private func purchaseTip(_ option: TipOption) {
        // TODO: Implement StoreKit purchase for option.productID
        print("Tip tapped: \(option.name) — \(option.productID)")
    }
}

#Preview {
    TipJarView()
}
