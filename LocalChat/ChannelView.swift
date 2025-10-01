//
//  ChannelView.swift
//  LocaChat
//
//  Purpose: Single-channel chat view with IRC-style affordances per mockup (header, transcript, composer, right rail).
//  Updated: October 1, 2025 - Made RightRail always visible (fixed width); tapping role opens list, tapping user opens detail sheet; fixed image stretching in RoleIcon with .aspectRatio(.fit).
//

import SwiftUI

struct ChannelView: View {
    let roomName: String
    
    @Environment(\.theme) var theme
    @State private var selectedRole: Role? = nil  // For role list sheet
    @State private var selectedUser: Participant? = nil  // For user detail sheet
    
    // Mock data for roles/active (replace with real from P2P/DB in later chunks)
    @State private var roleCounts: [Role: Int] = [.host: 1, .moderator: 3, .voiced: 5, .regular: 10]
    @State private var activeUsers: [Participant] = [Participant(id: "1", nick: "User1", role: .regular, avatarData: nil),
                                                     Participant(id: "2", nick: "Mod2", role: .moderator, avatarData: nil)]
    
    var body: some View {
        ZStack {
            HStack(spacing: 0) {
                // LEFT: Main column
                VStack(spacing: 0) {
                    HeaderTabView(roomName: roomName)
                    TopicStackOrSystemBanner()
                    TranscriptListView()
                    ComposerView()
                }
                .frame(maxWidth: .infinity)
                
                // RIGHT: Always visible rail (fixed narrow width)
                RightRailView(roleCounts: roleCounts, activeUsers: activeUsers) { role in
                    selectedRole = role
                } onUserTap: { user in
                    selectedUser = user
                }
                .frame(width: 60)  // Thin for icon width; compact mobile UI
            }
            
            // Floating affordances
            JumpToLatestFAB()
            ConnectionBanner()
        }
        .background(theme.colors.background)
        .navigationTitle(roomName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selectedRole) { role in
            RoleListView(role: role, users: activeUsers.filter { $0.role == role })  // Mock users per role
        }
        .sheet(item: $selectedUser) { user in
            UserDetailView(user: user)  // Short profile with expand
        }
    }
}

// MARK: - RightRailView (Thin with Icons/Counts/Active List - Icons Only)
struct RightRailView: View {
    let roleCounts: [Role: Int]
    let activeUsers: [Participant]
    let onRoleTap: (Role) -> Void
    let onUserTap: (Participant) -> Void
    
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack(spacing: 0) {
            // Top half: Role icons with counts (clickable)
            VStack(spacing: 4) {  // Tighter spacing for thin rail
                RoleIcon(role: .host, count: roleCounts[.host] ?? 0, onTap: onRoleTap)
                RoleIcon(role: .moderator, count: roleCounts[.moderator] ?? 0, onTap: onRoleTap)
                RoleIcon(role: .voiced, count: roleCounts[.voiced] ?? 0, onTap: onRoleTap)
                RoleIcon(role: .regular, count: roleCounts[.regular] ?? 0, onTap: onRoleTap)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 10)
            
            Divider()
            
            // Bottom half: Scrollable active users (icons only, clickable)
            ScrollView {
                VStack(spacing: 4) {
                    Text("Active")
                        .font(FontTheme.timestamp)
                        .foregroundColor(.gray)
                    ForEach(activeUsers) { user in
                        Button(action: { onUserTap(user) }) {
                            UserAvatarView(user: user)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
            }
        }
        .background(theme.colors.pane)
        .shadow(radius: 4)
    }
}

// MARK: - RoleIcon Component
struct RoleIcon: View {
    let role: Role
    let count: Int
    let onTap: (Role) -> Void
    
    var iconName: String {
        switch role {
        case .host: "hostIcon"  // From Assets.xcassets
        case .moderator: "modIcon"
        case .voiced: "voicedIcon"
        case .regular: "regularIcon"
        }
    }
    
    var body: some View {
        Button(action: { onTap(role) }) {
            VStack(spacing: 2) {  // Tight for thin rail
                Text("\(count)")
                    .font(FontTheme.timestamp)
                    .foregroundColor(.white)
                    .background(Circle().fill(Color.black.opacity(0.5)).frame(width: 16, height: 16))
                Image(iconName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)  // Fix stretching; preserve aspect
                    .frame(width: 32, height: 32)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - UserAvatarView Component (Icon Only for Thin Rail)
struct UserAvatarView: View {
    let user: Participant
    
    var body: some View {
        if let data = user.avatarData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .avatarCircle(size: 32)
        } else {
            Image("regularIcon")  // Default to regular user icon
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
        }
    }
}

// MARK: - RoleListView (Expansion Sheet)
struct RoleListView: View {
    let role: Role
    let users: [Participant]
    
    var body: some View {
        List(users) { user in
            HStack {
                UserAvatarView(user: user)
                Text(user.nick)
                    .font(FontTheme.caption)
            }
            .padding()
        }
        .navigationTitle("\(role.rawValue.capitalized)s")
    }
}

// MARK: - UserDetailView (Short Profile with Expand)
struct UserDetailView: View {
    let user: Participant
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 16) {
            UserAvatarView(user: user)
                .avatarCircle(size: 64)
            
            Text(user.nick)
                .font(FontTheme.body.bold())
            
            Text("Role: \(user.role.rawValue.capitalized)")
                .font(FontTheme.caption)
                .foregroundColor(.gray)
            
            Button(isExpanded ? "Minimize" : "More Info") {
                withAnimation {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                VStack(spacing: 8) {
                    Text("Phone: [Masked]")
                    Button("Direct Message") { /* DM logic */ }
                    Button("Block") { /* Block logic */ }
                }
                .transition(.opacity)
            }
        }
        .padding()
        .compatDetents()
    }
}

// MARK: - Compat Extension for presentationDetents
extension View {
    func compatDetents() -> some View {
        if #available(iOS 16.0, *) {
            return AnyView(self.presentationDetents([.medium, .large]))
        } else {
            return AnyView(self)
        }
    }
}

// MARK: - Other Subviews (Placeholders)
struct HeaderTabView: View {
    let roomName: String
    var body: some View {
        Text("#\(roomName)")
            .font(FontTheme.body)
            .padding(8)
            .background(ColorTheme.pane)
            .cornerRadius(20)
            .onTapGesture {
                // Open channel switcher sheet
            }
    }
}

struct TopicStackOrSystemBanner: View {
    var body: some View {
        Text("Topic placeholder - Tap to expand")
            .font(FontTheme.topic)
            .foregroundColor(ColorTheme.systemText)
            .padding(8)
            .background(ColorTheme.pane)
            .onTapGesture {
                // Expand/rotate
            }
    }
}

struct TranscriptListView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<5) { _ in
                    Text("Message placeholder")
                        .bubbleStyle()
                }
            }
            .padding()
        }
        .frame(maxHeight: .infinity)
    }
}

struct ComposerView: View {
    var body: some View {
        HStack {
            TextField("Message...", text: .constant(""))
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Send") { }
                .buttonStyle(.borderedProminent)
        }
        .padding(8)
        .background(ColorTheme.pane)
    }
}

struct JumpToLatestFAB: View {
    var body: some View {
        Button("↓") { }
            .padding(12)
            .background(ColorTheme.accent)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(radius: 4)
            .position(x: UIScreen.main.bounds.width - 40, y: UIScreen.main.bounds.height - 100)
    }
}

struct ConnectionBanner: View {
    var body: some View {
        Text("Connecting...")
            .padding(8)
            .background(Color.red)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .position(x: UIScreen.main.bounds.width / 2, y: 40)
    }
}

// MARK: - Preview
struct ChannelView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChannelView(roomName: "myradio")
                .environment(\.theme, Theme())
        }
        .preferredColorScheme(.light)
    }
}
