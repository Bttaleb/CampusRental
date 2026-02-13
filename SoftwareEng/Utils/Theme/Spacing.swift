//
//  Spacing.swift
//  SoftwareEng
//
//  Consistent spacing constants for layout
//

import SwiftUI

/// Centralized spacing constants for consistent layout throughout the app
struct Spacing {
    /// Extra extra small - 4pt
    static let xxs: CGFloat = 4

    /// Extra small - 8pt
    static let xs: CGFloat = 8

    /// Small - 12pt
    static let sm: CGFloat = 12

    /// Medium - 16pt (default)
    static let md: CGFloat = 16

    /// Large - 20pt
    static let lg: CGFloat = 20

    /// Extra large - 24pt
    static let xl: CGFloat = 24

    /// Extra extra large - 32pt
    static let xxl: CGFloat = 32

    /// Triple extra large - 40pt
    static let xxxl: CGFloat = 40

    // MARK: - Specific Use Cases

    /// Standard card padding
    static let cardPadding: CGFloat = md

    /// Standard corner radius for cards
    static let cardCornerRadius: CGFloat = 12

    /// Standard corner radius for buttons
    static let buttonCornerRadius: CGFloat = 10

    /// Standard corner radius for text fields
    static let textFieldCornerRadius: CGFloat = 8

    /// Standard horizontal screen padding
    static let screenHorizontal: CGFloat = md

    /// Standard vertical screen padding
    static let screenVertical: CGFloat = lg

    /// Standard spacing between sections
    static let sectionSpacing: CGFloat = xl
}
