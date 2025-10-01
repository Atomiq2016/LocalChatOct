//
//  UserManager.swift
//  LocaChat
//
//  Purpose: Manages user identity, creation, persistence, and loading with secure Keychain for privateKey and JSON UserDefaults for other data.
//  Updated: October 1, 2025 - Added Keychain for privateKey, logout, avatar param; fixed realName ternary.
//

import Foundation
import CryptoKit
import SwiftUI  // For ObservableObject
import Security  // For Keychain

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var user: User?
    private let keychainKey = "LocaChatPrivateKey"
    
    private init() {
        loadUser()
    }
    
    func createUser(username: String, realName: String?, phone: String, avatarData: Data? = nil, completion: @escaping (Bool) -> Void) {
        P2PManager.shared.checkUsernameAvailability(username) { isTaken in
            if isTaken {
                completion(false)
                return
            }
            let privateKey = Curve25519.Signing.PrivateKey()
            self.user = User(
                username: username,
                realName: realName?.isEmpty ?? true ? nil : realName,
                phone: phone,
                privateKey: privateKey.rawRepresentation,
                publicKey: privateKey.publicKey.rawRepresentation,
                avatarData: avatarData
            )
            self.saveUser()
            completion(true)
            print("Created user: \(username)")
        }
    }
    
    func logout() {
        user = nil
        UserDefaults.standard.removeObject(forKey: "user")
        deletePrivateKeyFromKeychain()
        print("Logged out and cleared data")
    }
    
    private func saveUser() {
        guard let user = user else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(user)
            UserDefaults.standard.set(data, forKey: "user")
            savePrivateKeyToKeychain(user.privateKey)
            print("Saved user to UserDefaults as JSON Data and Keychain")
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    private func loadUser() {
        guard let data = UserDefaults.standard.data(forKey: "user") else { return }
        do {
            let decoder = JSONDecoder()
            var loadedUser = try decoder.decode(User.self, from: data)
            if let privateKey = loadPrivateKeyFromKeychain() {
                loadedUser.privateKey = privateKey
                user = loadedUser
                if let username = user?.username {
                    print("Loaded user: \(username)")
                }
            } else {
                print("Failed to load private key from Keychain")
            }
        } catch {
            print("Failed to load user: \(error)")
        }
    }
    
    private func savePrivateKeyToKeychain(_ keyData: Data) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecValueData as String: keyData
        ]
        SecItemDelete(query as CFDictionary)  // Delete old if exists
        let status = SecItemAdd(query as CFDictionary, nil)
        if status != errSecSuccess {
            print("Failed to save private key to Keychain: \(status)")
        }
    }
    
    private func loadPrivateKeyFromKeychain() -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey,
            kSecReturnData as String: kCFBooleanTrue as Any,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        if status == errSecSuccess {
            return item as? Data
        } else {
            print("Failed to load private key from Keychain: \(status)")
            return nil
        }
    }
    
    private func deletePrivateKeyFromKeychain() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keychainKey
        ]
        SecItemDelete(query as CFDictionary)
    }
}
