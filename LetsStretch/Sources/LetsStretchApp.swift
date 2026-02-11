import SwiftUI

@main
struct LetsStretchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(preferences: appDelegate.preferences)
        }
    }
}
