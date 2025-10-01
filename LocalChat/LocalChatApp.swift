import SwiftUI

@main
struct LocalChatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
                .edgesIgnoringSafeArea(.top) // Handle notch on iPhone X
        }
    }
}
