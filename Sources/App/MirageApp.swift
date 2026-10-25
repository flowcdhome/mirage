import SwiftUI

@main
struct MirageApp: App {
    var body: some Scene {
        WindowGroup {
            DeviceShell()
                .preferredColorScheme(.dark)
                .statusBarHidden(true)
        }
    }
}
