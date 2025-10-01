import Foundation
import Combine

struct PhonePeer {
    let phoneNumber: String
    let publicKey: String
}

class P2PManager: NSObject, ObservableObject {
    static let shared = P2PManager()
    
    @Published private var peers: [PhonePeer] = []
    private let mockServerURL = URL(string: "https://mock-server.local")! // Replace with real cellular API

    override init() {
        super.init()
        // Mock initial peers (replace with server fetch)
        peers = [PhonePeer(phoneNumber: "+44784523084", publicKey: "mockPublicKey1")]
    }

    func start() {
        print("Started phone number-based networking")
        fetchPeers()
    }

    func stop() {
        print("Stopped phone number-based networking")
    }

    func checkUsernameAvailability(_ username: String, completion: @escaping (Bool) -> Void) {
        // Mock phone number check (replace with server call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let isTaken = self.peers.contains { $0.phoneNumber == username }
            completion(isTaken)
        }
    }

    func send(message: Message) {
        guard let user = UserManager.shared.user else { return }
        let phonePeer = PhonePeer(phoneNumber: user.phone, publicKey: user.publicKeyBase64)
        // Mock send to server via cellular
        var request = URLRequest(url: mockServerURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let messageData = ["phone": phonePeer.phoneNumber, "message": message.text ?? "Image", "room": message.roomName]
        if let jsonData = try? JSONSerialization.data(withJSONObject: messageData, options: []) {
            request.httpBody = jsonData
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Failed to send message: \(error)")
                    return
                }
                print("Sent message to \(phonePeer.phoneNumber) in room \(message.roomName)")
            }.resume()
        }
    }

    private func fetchPeers() {
        // Mock server fetch for phone-based peers
        var request = URLRequest(url: mockServerURL)
        request.httpMethod = "GET"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to fetch peers: \(error)")
                return
            }
            // Parse and update peers (mock for now)
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let peerList = json["peers"] as? [[String: String]] {
                DispatchQueue.main.async {
                    self.peers = peerList.map { PhonePeer(phoneNumber: $0["phoneNumber"] ?? "", publicKey: $0["publicKey"] ?? "") }
                }
            }
            print("Fetched peers: \(self.peers.count)")
        }.resume()
    }
}
