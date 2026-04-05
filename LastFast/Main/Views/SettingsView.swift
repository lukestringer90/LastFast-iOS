//
//  SettingsView.swift
//  LastFast
//
//  Settings, about, and tip jar sheet
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("goalNotificationsEnabled") private var goalNotificationsEnabled = true
    @State private var showOneHourReminder = true
    @AppStorage("oneHourReminderEnabled") private var oneHourReminderEnabled = true
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @AppStorage("showOnboarding") private var showOnboarding = false

    @State private var showingOnboarding = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - Notifications
                Section("Notifications") {
                    Toggle(isOn: $goalNotificationsEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Goal Reached")
                                Text("Notify me when my fasting goal is met")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .onChange(of: goalNotificationsEnabled) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showOneHourReminder = newValue
                        }
                    }

                    if showOneHourReminder {
                        Toggle(isOn: $oneHourReminderEnabled) {
                            Label {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("1 Hour Reminder")
                                    Text("Notify me 1 hour before my fast ends")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            } icon: {
                                Image(systemName: "bell.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                    }
                }

                // MARK: - General
                Section {
                    Button {
                        showingOnboarding = true
                    } label: {
                        Label("Show App Introduction", systemImage: "hand.wave")
                    }
                }

                // MARK: - Tip Jar
                Section() {
                    VStack(spacing: 4) {
                        Text("Support Last Fast")
                            .font(.headline)
                        Text("If you enjoy the app, consider leaving a tip to support development.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)

                    ForEach(TipOption.allCases) { option in
                        Button {
                            purchaseTip(option)
                        } label: {
                            HStack(spacing: 12) {
                                Text(option.emoji)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(option.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                    Text(option.price)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }

                // MARK: - About
                Section {
                    Link(destination: URL(string: "https://lastfast.app")!) {
                        HStack {
                            Text("Website")
                            Spacer()
                            Text("lastfast.app")
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .fullScreenCover(isPresented: $showingOnboarding) {
            OnboardingView {
                showingOnboarding = false
            }
        }
        .onAppear {
            showOneHourReminder = goalNotificationsEnabled
            AnalyticsManager.logEvent("view_settings")
        }
    }

    private func purchaseTip(_ option: TipOption) {
        // TODO: Implement StoreKit purchase for option.productID
        print("Tip tapped: \(option.name) — \(option.productID)")
    }
}

#Preview {
    SettingsView()
}
