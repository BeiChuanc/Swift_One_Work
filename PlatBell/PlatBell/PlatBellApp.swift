import SwiftUI

@main
struct PlatBellApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView_platbell()
                .hudOverlay_platbell()
                .toastOverlay_platbell()
        }
    }
}
