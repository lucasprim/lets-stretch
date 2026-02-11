import ServiceManagement
import SwiftUI

struct SettingsView: View {
    @Bindable var preferences: UserPreferences

    var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            sessionTab
                .tabItem {
                    Label("Sessions", systemImage: "figure.cooldown")
                }
        }
        .frame(width: 380, height: 280)
    }

    // MARK: - General Tab

    private var generalTab: some View {
        Form {
            Section("Reminders") {
                Picker("Remind me every", selection: $preferences.reminderIntervalMinutes) {
                    Text("15 minutes").tag(15)
                    Text("30 minutes").tag(30)
                    Text("45 minutes").tag(45)
                    Text("60 minutes").tag(60)
                    Text("90 minutes").tag(90)
                    Text("120 minutes").tag(120)
                }

                Picker("Snooze for", selection: $preferences.snoozeIntervalMinutes) {
                    Text("5 minutes").tag(5)
                    Text("10 minutes").tag(10)
                    Text("15 minutes").tag(15)
                }
            }

            Section("Stretch Categories") {
                Toggle("Desk-friendly stretches", isOn: categoryBinding(for: .deskFriendly))
                Toggle("Mat stretches", isOn: categoryBinding(for: .matRequired))
            }

            Section("Startup") {
                Toggle("Launch at login", isOn: launchAtLoginBinding)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Session Tab

    private var sessionTab: some View {
        Form {
            Section("Auto-Play Session") {
                Picker("Stretch duration", selection: $preferences.stretchDurationSeconds) {
                    Text("15 seconds").tag(15)
                    Text("20 seconds").tag(20)
                    Text("30 seconds").tag(30)
                    Text("45 seconds").tag(45)
                    Text("60 seconds").tag(60)
                }

                Picker("Rest between stretches", selection: $preferences.restIntervalSeconds) {
                    Text("3 seconds").tag(3)
                    Text("5 seconds").tag(5)
                    Text("10 seconds").tag(10)
                }

                Picker("Stretches per session", selection: $preferences.stretchesPerSession) {
                    Text("3 stretches").tag(3)
                    Text("5 stretches").tag(5)
                    Text("7 stretches").tag(7)
                    Text("10 stretches").tag(10)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    // MARK: - Bindings

    private func categoryBinding(for category: StretchCategory) -> Binding<Bool> {
        Binding(
            get: { preferences.enabledCategories.contains(category) },
            set: { isEnabled in
                if isEnabled {
                    preferences.enabledCategories.insert(category)
                } else {
                    // Ensure at least one category is always enabled
                    if preferences.enabledCategories.count > 1 {
                        preferences.enabledCategories.remove(category)
                    }
                }
            }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { preferences.launchAtLogin },
            set: { newValue in
                preferences.launchAtLogin = newValue
                updateLaunchAtLogin(newValue)
            }
        )
    }

    private func updateLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            // Silently fail - the preference is saved regardless
        }
    }
}
