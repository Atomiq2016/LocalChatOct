import SwiftUI

struct MainView: View {
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        NavigationView {
            ContentView()
        }
        .onChange(of: scenePhase) { newPhase in // iOS 14+ compatible
            if newPhase == .active {
                P2PManager.shared.start()
            } else if newPhase == .inactive || newPhase == .background {
                P2PManager.shared.stop()
            }
        }
    }
}
