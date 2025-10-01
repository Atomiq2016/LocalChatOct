//
//  Models.swift
//  LocaChat
//
//  Purpose: Data structures for users and messages, with crypto and role/avatar support.
//  Updated: October 1, 2025 - Changed privateKey to var for mutable load from Keychain.
//

import Foundation
import CryptoKit

enum Role: String, Codable, Identifiable {
    case host, moderator, voiced, regular
    var id: String { self.rawValue }
}

struct Participant: Identifiable, Codable {
    var id: String
    var nick: String
    var role: Role
    var avatarData: Data?  // Custom avatar
}

struct User: Codable {
    let username: String
    let realName: String?
    let phone: String
    var privateKey: Data  // Changed to var for mutable load
    let publicKey: Data
    var avatarData: Data?  // Added for custom avatar
    var publicKeyBase64: String {
        publicKey.base64EncodedString()
    }
}

struct Message: Identifiable, Codable {
    let id: UUID
    let roomName: String
    let authorPublicKey: String
    let text: String?
    let imageData: Data?
    let timestamp: Date
}

extension String {
    var truncatedPublicKey: String {
        if count < 16 { return self }
        return String(prefix(8)) + "..." + String(suffix(8))
    }
}
