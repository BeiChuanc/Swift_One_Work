import SwiftUI

@main
struct BlissLinkApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView_baseswiftui()
                .hudOverlay_baseswiftui()
                .toastOverlay_baseswiftui()
        }
    }
}
