//
//  SettingsView.swift
//  LastFast
//
//  Settings, about, and tip jar sheet
//

import SwiftUI

struct SettingsView: View {
    let showSupport = false
    
    @Environment(\.dismiss) private var dismiss

    @AppStorage("goalNotificationsEnabled") private var goalNotificationsEnabled = true
    @State private var showOneHourReminder = true
    @AppStorage("oneHourReminderEnabled") private var oneHourReminderEnabled = true

    @State private var showingOnboarding = false
    @State private var showingTipJar = false

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }

    var body: some View {
        NavigationStack {
            List {
                // MARK: - General
                Section("General") {
                    AppIntroductionRow(action: { showingOnboarding = true })
                }
                
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
                    .tint(.green)
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
                        .tint(.green)
                    }
                }
                
                if (showSupport) {
                    // MARK: - Support
                    Section("Support") {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Tip Jar")
                                Text("If you enjoy Last Fast, consider leaving a tip to support development.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "heart.fill")
                                .foregroundStyle(.pink)
                        }

                        Button {
                            showingTipJar = true
                        } label: {
                            Label("Leave a Tip", systemImage: "gift")
                        }
                        .tint(.primary)
                    }
                }
                

                // MARK: - About
                Section("About") {
                    Link(destination: URL(string: "https://lastfast.app")!) {
                        HStack {
                            Label("Website", systemImage: "globe")
                            Spacer()
                            Text("lastfast.app")
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.up.forward.square")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .tint(.primary)

                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .sheet(isPresented: $showingTipJar) {
            TipJarView()
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

}

#Preview {
    SettingsView()
}
