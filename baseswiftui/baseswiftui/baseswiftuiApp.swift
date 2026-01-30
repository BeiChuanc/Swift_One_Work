import SwiftUI

// MARK: - 应用入口

@main
struct baseswiftuiApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView_baseswiftui()
                .hudOverlay_baseswiftui()
                .toastOverlay_baseswiftui()
        }
    }
}
