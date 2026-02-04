import SwiftUI

@main
struct LITEApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView_lite()
                .hudOverlay_lite()
                .toastOverlay_lite()
        }
    }
}
