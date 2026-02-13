//
//  ColorTheme.swift
//  SoftwareEng
//
//  Wayne State University Brand Colors and Theme System
//

import SwiftUI
import UIKit

/// Centralized color theme system for Wayne State University branding
struct ColorTheme {

    // MARK: - WSU Brand Colors

    /// WSU Primary Green (#006633)
    static let wsuGreen = Color(hex: "006633")

    /// WSU Gold/Yellow (#FFCB05)
    static let wsuGold = Color(hex: "FFCB05")

    /// WSU Light Green (#00833E) - for backgrounds and lighter accents
    static let wsuLightGreen = Color(hex: "00833E")

    /// WSU Dark Green (#004D26) - for text emphasis and darker accents
    static let wsuDarkGreen = Color(hex: "004D26")

    /// Cream/Light Yellow (#FFF8DC) - subtle background tint
    static let cream = Color(hex: "FFF8DC")

    // MARK: - Semantic Colors

    /// Primary action color (WSU Green)
    static let primary = wsuGreen

    /// Accent color (WSU Gold)
    static let accent = wsuGold

    /// Success color (WSU Green)
    static let success = wsuGreen

    /// Warning color (WSU Gold)
    static let warning = wsuGold

    /// Error color (red)
    static let error = Color(hex: "DC3545")

    /// Info color (blue)
    static let info = Color(hex: "0066CC")

    // MARK: - Background Colors (Light Theme)

    /// App background color - off-white (#F8F9FA)
    static let background = Color(hex: "F8F9FA")

    /// Card/surface background - pure white
    static let cardBackground = Color.white

    /// Secondary background - very subtle gray
    static let secondaryBackground = Color(hex: "F5F5F5")

    // MARK: - Text Colors

    /// Primary text color - near black (#1A1A1A)
    static let textPrimary = Color(hex: "1A1A1A")

    /// Secondary text color - gray (#6C757D)
    static let textSecondary = Color(hex: "6C757D")

    /// Text on primary color backgrounds - white
    static let textOnPrimary = Color.white

    /// Text on accent color backgrounds - dark text for contrast
    static let textOnAccent = Color.black

    // MARK: - Border & Divider Colors

    /// Border color - light gray (#E5E7EB)
    static let border = Color(hex: "E5E7EB")

    /// Divider color (alias for border)
    static let divider = border

    // MARK: - Booking Status Colors

    /// Pending booking status - WSU Gold
    static let statusPending = wsuGold

    /// Confirmed booking status - WSU Green
    static let statusConfirmed = wsuGreen

    /// Cancelled booking status - red
    static let statusCancelled = error

    /// Completed booking status - light green
    static let statusCompleted = wsuLightGreen

    /// No show booking status - gray
    static let statusNoShow = Color(hex: "6C757D")

    // MARK: - Shadow

    /// Standard shadow color with opacity
    static let shadow = Color.black.opacity(0.1)

    /// Subtle shadow for cards
    static let cardShadow = Color.black.opacity(0.05)
}

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    /// - Parameter hex: Hex color string (e.g., "006633" or "#006633")
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

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - UIColor Extension for Navigation Bar

extension UIColor {
    /// WSU Green for UIKit components
    static let wsuGreen = UIColor(red: 0/255, green: 102/255, blue: 51/255, alpha: 1.0)

    /// WSU Gold for UIKit components
    static let wsuGold = UIColor(red: 255/255, green: 203/255, blue: 5/255, alpha: 1.0)
}
