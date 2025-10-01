//
//  SignupView.swift
//  LocaChat
//
//  Purpose: Professional signup screen with themed UI, validation, and integration with UserManager.
//  Updated: September 30, 2025 - Applied global theme for MSN aesthetic; added modular components.
//

import SwiftUI

struct SignupView: View {
    @State private var phone: String = ""
    @State private var username: String = ""
    @State private var realName: String = ""
    @State private var isChecking: Bool = false
    @State private var errorMessage: String = ""
    @State private var showAlert = false
    @State private var isSignupDisabled: Bool = false // Prevent multiple taps
    
    @Environment(\.theme) var theme  // Use global theme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up for LocaChat")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(theme.colors.accent)  // Purple-like accent for title
            
            ThemedTextField(placeholder: "Phone Number (e.g., +1-555-1234)", text: $phone)
                .keyboardType(.phonePad)
            
            ThemedTextField(placeholder: "Username", text: $username)
            
            ThemedTextField(placeholder: "Real Name (optional)", text: $realName)
            
            if isChecking {
                ProgressView("Checking username availability...")
                    .progressViewStyle(CircularProgressViewStyle(tint: theme.colors.accent))
            }
            
            Button(action: signup) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((isChecking || username.isEmpty || phone.isEmpty || isSignupDisabled) ? Color.gray : theme.colors.accent)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isChecking || username.isEmpty || phone.isEmpty || isSignupDisabled)
            
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Text("Mock Mode: Use any phone like +1-555-1234. Username 'test' is available.")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .padding(.vertical)
        .background(theme.colors.background)  // System background for clean look
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Signup Failed"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    private func signup() {
        guard !isSignupDisabled else {
            print("Signup already in progress, ignoring tap")
            return
        }
        isChecking = true
        isSignupDisabled = true
        errorMessage = ""
        print("Starting signup for username: \(username), phone: \(phone)")
        if phone.isEmpty {
            isChecking = false
            isSignupDisabled = false
            errorMessage = "Phone number is required"
            return
        }
        // Re-enable P2P check for uniqueness
        P2PManager.shared.checkUsernameAvailability(username) { isTaken in
            if isTaken {
                self.isChecking = false
                self.isSignupDisabled = false
                self.errorMessage = "Username is taken"
                return
            }
            UserManager.shared.createUser(username: username, realName: realName, phone: phone) { success in
                DispatchQueue.main.async {
                    self.isChecking = false
                    self.isSignupDisabled = false
                    if !success {
                        self.errorMessage = "Failed to create user. An error occurred."
                        self.showAlert = true
                        print("Signup failed for username: \(self.username)")
                    } else {
                        print("Signup successful, transitioning to ContentView for username: \(self.username)")
                    }
                }
            }
        }
    }
}

// MARK: - Modular Component for Themed TextField
struct ThemedTextField: View {
    let placeholder: String
    @Binding var text: String
    
    @Environment(\.theme) var theme
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal)
            .background(theme.colors.pane)
            .foregroundColor(.black)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview
struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
            .environment(\.theme, Theme())
            .preferredColorScheme(.light)
        SignupView()
            .environment(\.theme, Theme())
            .preferredColorScheme(.dark)
    }
}
