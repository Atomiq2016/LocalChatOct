//
//  Theme.swift
//  LocaChat
//
//  Purpose: Defines a global theme for LocaChat with reusable colors, typography, and modifiers,
//           aligning with the MSN-inspired aesthetic from the ChannelView mockup (vibrant, professional).
//  Updated: September 30, 2025 - Removed erroneous UserManager declaration; fixed color initializer.
//

import SwiftUI

// MARK: - Color Tokens
struct ColorTheme {
    static let accent = color(hex: 0x00AA66) // Green accent for system lines
    static let defaultUser = Color.gray
    static let operatorRole = Color.red
    static let moderatorRole = Color.yellow
    static let voiceRole = Color.blue
    static let systemText = Color.green
    static let link = Color.red
    static let background = Color(.systemBackground)
    static let pane = Color(.secondarySystemBackground)
    
    // Utility to convert hex to Color (iOS 11+ compatible)
    static func color(hex: Int, opacity: Double = 1.0) -> Color {
        Color(red: Double((hex >> 16) & 0xFF) / 255,
              green: Double((hex >> 8) & 0xFF) / 255,
              blue: Double(hex & 0xFF) / 255,
              opacity: opacity)
    }
}

// MARK: - Typography Tokens
struct FontTheme {
    static let body = Font.system(size: 17, design: .default)
    static let caption = Font.system(size: 13, design: .default)
    static let timestamp = Font.system(size: 11, design: .default)
    static let topic = Font.system(size: 15, weight: .semibold, design: .default)
    static let monospace = Font.monospaced(.body)()
}

// MARK: - Modifiers
struct BubbleStyle: ViewModifier {
    var isOwn: Bool = false
    func body(content: Content) -> some View {
        content
            .padding(8)
            .background(isOwn ? ColorTheme.accent.opacity(0.8) : ColorTheme.pane)
            .foregroundColor(.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct AvatarCircle: ViewModifier {
    var size: CGFloat = 24
    func body(content: Content) -> some View {
        content
            .frame(width: size, height: size)
            .background(Color.randomTint)
            .foregroundColor(.white)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
    }
}

struct SystemRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(6)
            .background(ColorTheme.pane)
            .foregroundColor(ColorTheme.systemText)
            .cornerRadius(8)
    }
}

// MARK: - Environment and Extension
struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = Theme()
}

extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

struct Theme {
    let colors = ColorTheme.self
    let fonts = FontTheme.self
}

// MARK: - View Extensions for Modifiers
extension View {
    func bubbleStyle(isOwn: Bool = false) -> some View {
        modifier(BubbleStyle(isOwn: isOwn))
    }
    
    func avatarCircle(size: CGFloat = 24) -> some View {
        modifier(AvatarCircle(size: size))
    }
    
    func systemRowStyle() -> some View {
        modifier(SystemRowStyle())
    }
}

// MARK: - Color Extension for Random Tints
extension Color {
    static var randomTint: Color {
        let hues: [Color] = [ColorTheme.operatorRole, ColorTheme.moderatorRole, ColorTheme.voiceRole]
        return hues.randomElement() ?? ColorTheme.defaultUser
    }
}

// MARK: - Preview
struct ThemePreview: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("Sample Message")
                .bubbleStyle(isOwn: true)
            Text("System: * Joined #myradio")
                .systemRowStyle()
            Image(systemName: "person.circle.fill")
                .avatarCircle(size: 32)
            Text("Topic: Welcome to LocaChat")
                .font(FontTheme.topic)
                .foregroundColor(ColorTheme.systemText)
            Spacer()
        }
        .padding()
        .background(ColorTheme.background)
        .environment(\.theme, Theme())
        .previewDisplayName("Theme Preview")
    }
}

struct ThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        ThemePreview()
            .preferredColorScheme(.light)
        ThemePreview()
            .preferredColorScheme(.dark)
    }
}
