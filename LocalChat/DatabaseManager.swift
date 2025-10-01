import Foundation
import SQLite

class DatabaseManager {
    static let shared = DatabaseManager()

    private let db: Connection

    private let messages = SQLite.Table("messages")
    private let id = SQLite.Expression<UUID>("id")
    private let roomNameExp = SQLite.Expression<String>("roomName")
    private let authorPublicKey = SQLite.Expression<String>("authorPublicKey")
    private let text = SQLite.Expression<String?>("text")
    private let imageData = SQLite.Expression<Data?>("imageData")
    private let timestamp = SQLite.Expression<Date>("timestamp")

    private let chatrooms = SQLite.Table("chatrooms")
    private let name = SQLite.Expression<String>("name")

    private let blockedUsers = SQLite.Table("blockedUsers")
    private let publicKey = SQLite.Expression<String>("publicKey")

    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            db = try Connection("\(path)/localchat.sqlite3")

            try db.run(messages.create(ifNotExists: true) { t in
                t.column(id, primaryKey: true)
                t.column(roomNameExp)
                t.column(authorPublicKey)
                t.column(text)
                t.column(imageData)
                t.column(timestamp)
            })

            try db.run(chatrooms.create(ifNotExists: true) { t in
                t.column(name, primaryKey: true)
            })

            try db.run(blockedUsers.create(ifNotExists: true) { t in
                t.column(publicKey, primaryKey: true)
            })
        } catch {
            print("Database initialization failed: \(error)")
            fatalError("Cannot proceed without database")
        }
    }

    func addRoom(_ name: String) {
        do {
            try db.run(chatrooms.insert(or: .ignore, self.name <- name))
            print("Added room: \(name)")
        } catch {
            print("Failed to add room: \(error)")
        }
    }

    func getRooms() -> [String] {
        var rooms: [String] = []
        do {
            for row in try db.prepare(chatrooms) {
                rooms.append(row[name])
            }
        } catch {
            print("Failed to fetch rooms: \(error)")
        }
        return rooms.sorted()
    }

    func addMessage(_ message: Message) {
        do {
            try db.run(messages.insert(or: .ignore,
                                       id <- message.id,
                                       roomNameExp <- message.roomName,
                                       authorPublicKey <- message.authorPublicKey,
                                       text <- message.text,
                                       imageData <- message.imageData,
                                       timestamp <- message.timestamp))
            print("Added message in room: \(message.roomName)")
        } catch {
            print("Failed to add message: \(error)")
        }
    }

    func getMessages(for room: String) -> [Message] {
        var messages: [Message] = []
        do {
            let query = self.messages.filter(roomNameExp == room).order(timestamp.asc)
            for row in try db.prepare(query) {
                if !isUserBlocked(row[authorPublicKey]) {
                    let message = Message(
                        id: row[id],
                        roomName: row[roomNameExp],
                        authorPublicKey: row[authorPublicKey],
                        text: row[text],
                        imageData: row[imageData],
                        timestamp: row[timestamp]
                    )
                    messages.append(message)
                }
            }
        } catch {
            print("Failed to fetch messages for \(room): \(error)")
        }
        return messages
    }

    func getAllMessages() -> [Message] {
        var messages: [Message] = []
        do {
            for row in try db.prepare(self.messages) {
                let message = Message(
                    id: row[id],
                    roomName: row[roomNameExp],
                    authorPublicKey: row[authorPublicKey],
                    text: row[text],
                    imageData: row[imageData],
                    timestamp: row[timestamp]
                )
                messages.append(message)
            }
        } catch {
            print("Failed to fetch all messages: \(error)")
        }
        return messages
    }

    func deleteOldMessages() {
        do {
            let oneDayAgo = Date(timeIntervalSinceNow: -86400)
            let count = try db.run(messages.filter(timestamp <= oneDayAgo).delete())
            print("Deleted \(count) old messages")
        } catch {
            print("Failed to delete old messages: \(error)")
        }
    }

    func blockUser(_ publicKey: String) {
        do {
            try db.run(blockedUsers.insert(or: .ignore, self.publicKey <- publicKey))
            print("Blocked user: \(publicKey)")
        } catch {
            print("Failed to block user: \(error)")
        }
    }

    func isUserBlocked(_ publicKey: String) -> Bool {
        do {
            return try db.scalar(blockedUsers.filter(self.publicKey == publicKey).count) > 0
        } catch {
            print("Failed to check block status: \(error)")
            return false
        }
    }
}
