//
//  ChatroomListView.swift
//  LocaChat
//
//  Purpose: Professional channel list screen with themed UI, room addition, and navigation to ChannelView.
//  Updated: September 30, 2025 - Applied global theme for MSN aesthetic; modular list cells.
//

import SwiftUI

struct ChatroomListView: View {
    @State private var rooms: [String] = []
    @State private var newRoomName: String = ""
    
    @Environment(\.theme) var theme  // Use global theme
    
    var body: some View {
        VStack {
            Text("Chatrooms")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.accent)  // Purple-like accent
                .padding()
                .background(theme.colors.pane)
                .cornerRadius(10)
            
            if rooms.isEmpty {
                Text("No chatrooms yet. Create one below!")
                    .font(FontTheme.caption)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(rooms, id: \.self) { room in
                    NavigationLink(destination: ChannelView(roomName: room)) {
                        RoomCell(room: room)
                    }
                }
                .listStyle(.plain)
                .background(theme.colors.background)
            }
            
            HStack {
                ThemedTextField(placeholder: "New Room Name", text: $newRoomName)
                
                Button("Join/Create") {
                    if !newRoomName.isEmpty {
                        DatabaseManager.shared.addRoom(newRoomName)
                        rooms = DatabaseManager.shared.getRooms().sorted()
                        newRoomName = ""
                        print("Created/Joined room: \(newRoomName)")
                    }
                }
                .disabled(newRoomName.isEmpty)
                .padding()
                .background(newRoomName.isEmpty ? Color.gray : theme.colors.accent)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
        }
        .background(theme.colors.background)
        .onAppear {
            rooms = DatabaseManager.shared.getRooms().sorted()
            print("Loaded \(rooms.count) rooms")
        }
        .navigationTitle("Channels")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Modular RoomCell
struct RoomCell: View {
    let room: String
    
    @Environment(\.theme) var theme
    
    var body: some View {
        HStack {
            Image(systemName: "number")
                .avatarCircle(size: 32)
            Text(room)
                .font(FontTheme.body)
                .foregroundColor(.black)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Preview
struct ChatroomListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ChatroomListView()
                .environment(\.theme, Theme())
        }
        .preferredColorScheme(.light)
        
        NavigationView {
            ChatroomListView()
                .environment(\.theme, Theme())
        }
        .preferredColorScheme(.dark)
    }
}
