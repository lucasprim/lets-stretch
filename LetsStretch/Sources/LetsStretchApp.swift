import SwiftUI

@main
struct LetsStretchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        // Settings window is managed directly by AppDelegate
        Settings { EmptyView() }
    }
}
