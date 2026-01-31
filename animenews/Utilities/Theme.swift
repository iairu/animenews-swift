import SwiftUI

struct Theme {
    static let background = Color.shadcn.background
    static let foreground = Color.shadcn.foreground
    
    static let card = Color.shadcn.card
    static let cardForeground = Color.shadcn.cardForeground
    
    static let border = Color.shadcn.border
    
    static let primary = Color.shadcn.primary
    static let primaryForeground = Color.shadcn.primaryForeground
    
    static let muted = Color.shadcn.muted
    static let mutedForeground = Color.shadcn.mutedForeground
    
    static let accent = Color.shadcn.accent
    static let accentForeground = Color.shadcn.accentForeground
}

extension Color {
    static let shadcn = (
        background: Color(hex: "#020817"), // slate-950
        foreground: Color(hex: "#f8fafc"), // slate-50

        card: Color(hex: "#0f172a"), // slate-900
        cardForeground: Color(hex: "#f8fafc"), // slate-50

        popover: Color(hex: "#020817"),
        popoverForeground: Color(hex: "#f8fafc"),

        primary: Color(hex: "#f8fafc"), // slate-50
        primaryForeground: Color(hex: "#020817"), // slate-950

        secondary: Color(hex: "#1e293b"), // slate-800
        secondaryForeground: Color(hex: "#f8fafc"), // slate-50

        muted: Color(hex: "#334155"), // slate-700
        mutedForeground: Color(hex: "#94a3b8"), // slate-400

        accent: Color(hex: "#2563eb"), // blue-600
        accentForeground: Color(hex: "#dbeafe"), // blue-200

        destructive: Color(hex: "#7f1d1d"), // red-800
        destructiveForeground: Color(hex: "#fef2f2"), // red-100
        
        border: Color(hex: "#1e293b"), // slate-800
        input: Color(hex: "#1e293b"), // slate-800
        ring: Color(hex: "#2563eb") // blue-600
    )
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}