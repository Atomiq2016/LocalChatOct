import SwiftUI

struct ContentView: View {
    @ObservedObject private var userManager = UserManager.shared

    var body: some View {
        if userManager.user != nil {
            ChatroomListView()
        } else {
            SignupView()
        }
    }
}
