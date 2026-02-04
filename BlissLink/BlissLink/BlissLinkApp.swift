import SwiftUI

@main
struct BlissLinkApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView_blisslink()
                .hudOverlay_blisslink()
                .toastOverlay_blisslink()
        }
    }
}
