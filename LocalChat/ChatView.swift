import SwiftUI
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
    var selectedImageData: (Data?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.jpegData(compressionQuality: 0.7) {
                parent.selectedImageData(data)
            } else {
                parent.selectedImageData(nil)
            }
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.selectedImageData(nil)
        }
    }
}

struct ChatView: View {
    let roomName: String
    @State private var messages: [Message] = []
    @State private var newMessage: String = ""
    @State private var isShowingImagePicker = false
    @State private var imageData: Data?
    @StateObject private var p2pManager = P2PManager.shared
    @State private var users: [String] = ["Garret", "User1", "User2"] // Mock user list
    @State private var isUserListExpanded = false

    var body: some View {
        HStack(spacing: 0) {
            // Chat Message Area (Expanded space)
            VStack {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 5) {
                        ForEach(messages.prefix(100)) { message in
                            HStack {
                                Image(systemName: "person.circle.fill") // MSN avatar placeholder
                                    .foregroundColor(.blue)
                                    .frame(width: 30, height: 30)
                                VStack(alignment: .leading) {
                                    Text(message.authorPublicKey.truncatedPublicKey)
                                        .font(.caption)
                                        .foregroundColor(.purple)
                                    if let text = message.text {
                                        Text(text)
                                            .font(Font.monospaced(.body)())
                                            .foregroundColor(.white)
                                    } else if let data = message.imageData, let uiImage = UIImage(data: data) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(maxWidth: UIScreen.main.bounds.width * 0.4, maxHeight: 150)
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                            .background(Color.black.opacity(0.8))
                            .cornerRadius(5)
                        }
                    }
                    .padding()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.blue.opacity(0.3))

                // Input Area
                HStack {
                    TextField("Type a message...", text: $newMessage)
                        .textFieldStyle(.roundedBorder)
                        .foregroundColor(.black)
                    Button(action: { isShowingImagePicker = true }) {
                        Image(systemName: "photo")
                            .foregroundColor(.green)
                    }
                    .sheet(isPresented: $isShowingImagePicker) {
                        ImagePicker(selectedImageData: { data in
                            if let data = data {
                                imageData = data
                                sendImageMessage(data: data)
                            }
                            isShowingImagePicker = false
                        })
                    }
                    Button("Send") {
                        sendTextMessage()
                    }
                    .disabled(newMessage.isEmpty)
                    .padding(8)
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // User List (Thin icon-only view, expandable)
            VStack {
                Text("Users")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                if isUserListExpanded {
                    List(users, id: \.self) { user in
                        HStack {
                            Image(systemName: "circle.fill") // Avatar placeholder
                                .foregroundColor(.randomColor)
                                .frame(width: 20, height: 20)
                            Text(user)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 2)
                    }
                    .frame(width: 150)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                    .onTapGesture {
                        isUserListExpanded = false
                    }
                } else {
                    ScrollView {
                        ForEach(users, id: \.self) { user in
                            Image(systemName: "circle.fill") // Icon only
                                .foregroundColor(.randomColor)
                                .frame(width: 40, height: 40)
                                .padding(.vertical, 2)
                        }
                    }
                    .frame(width: 40)
                    .background(Color.blue.opacity(0.5))
                    .cornerRadius(10)
                    .onTapGesture {
                        isUserListExpanded = true
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .navigationTitle(roomName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            DatabaseManager.shared.addRoom(roomName)
            messages = DatabaseManager.shared.getMessages(for: roomName).prefix(100).map { $0 }
            print("Loaded \(messages.count) messages for room: \(roomName)")
        }
    }

    private func sendTextMessage() {
        guard let user = UserManager.shared.user else {
            print("No user logged in")
            return
        }
        let message = Message(
            id: UUID(),
            roomName: roomName,
            authorPublicKey: user.publicKeyBase64,
            text: newMessage,
            imageData: nil,
            timestamp: Date()
        )
        DatabaseManager.shared.addMessage(message)
            p2pManager.send(message: message)
            messages = DatabaseManager.shared.getMessages(for: roomName).prefix(100).map { $0 }
            newMessage = ""
            print("Sent text message in room: \(roomName)")
    }

    private func sendImageMessage(data: Data) {
        guard let user = UserManager.shared.user else {
            print("No user logged in")
            return
        }
        if let compressedData = UIImage(data: data)?.jpegData(compressionQuality: 0.7) {
            let message = Message(
                id: UUID(),
                roomName: roomName,
                authorPublicKey: user.publicKeyBase64,
                text: nil,
                imageData: compressedData,
                timestamp: Date()
            )
            DatabaseManager.shared.addMessage(message)
            p2pManager.send(message: message)
            messages = DatabaseManager.shared.getMessages(for: roomName).prefix(100).map { $0 }
            print("Sent image message in room: \(roomName)")
        }
    }
}

struct MessageRow: View {
    let message: Message

    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
                .foregroundColor(.blue)
                .frame(width: 30, height: 30)
            VStack(alignment: .leading) {
                Text(message.authorPublicKey.truncatedPublicKey)
                    .font(.caption)
                    .foregroundColor(.purple)
                if let text = message.text {
                    Text(text)
                        .font(Font.monospaced(.body)())
                        .foregroundColor(.white)
                } else if let data = message.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.4, maxHeight: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
        }
        .padding(.vertical, 2)
        .background(Color.black.opacity(0.8))
        .cornerRadius(5)
    }

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Color {
    static var randomColor: Color {
        Color(red: Double.random(in: 0...1),
              green: Double.random(in: 0...1),
              blue: Double.random(in: 0...1))
    }
}
