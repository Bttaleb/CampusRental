//
//  Typography.swift
//  SoftwareEng
//
//  Text styles and typography system
//

import SwiftUI

/// View extension for consistent typography throughout the app
extension View {
    /// WSU large title style - for page titles
    /// - Returns: Modified view with large title styling
    func wsuTitle() -> some View {
        self
            .font(.system(size: 34, weight: .bold))
            .foregroundColor(ColorTheme.textPrimary)
    }

    /// WSU heading style - for section headings
    /// - Returns: Modified view with heading styling
    func wsuHeading() -> some View {
        self
            .font(.system(size: 22, weight: .semibold))
            .foregroundColor(ColorTheme.textPrimary)
    }

    /// WSU subheading style - for subsections
    /// - Returns: Modified view with subheading styling
    func wsuSubheading() -> some View {
        self
            .font(.system(size: 18, weight: .medium))
            .foregroundColor(ColorTheme.textPrimary)
    }

    /// WSU body text style - for main content
    /// - Returns: Modified view with body text styling
    func wsuBody() -> some View {
        self
            .font(.system(size: 16, weight: .regular))
            .foregroundColor(ColorTheme.textPrimary)
    }

    /// WSU caption style - for secondary/helper text
    /// - Returns: Modified view with caption styling
    func wsuCaption() -> some View {
        self
            .font(.system(size: 14, weight: .regular))
            .foregroundColor(ColorTheme.textSecondary)
    }

    /// WSU small caption style - for very small text
    /// - Returns: Modified view with small caption styling
    func wsuSmallCaption() -> some View {
        self
            .font(.system(size: 12, weight: .regular))
            .foregroundColor(ColorTheme.textSecondary)
    }

    /// WSU section header style - for section titles with WSU green
    /// - Returns: Modified view with section header styling
    func wsuSectionHeader() -> some View {
        self
            .font(.system(size: 18, weight: .semibold))
            .foregroundColor(ColorTheme.wsuGreen)
    }
}
