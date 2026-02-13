//
//  ViewModifiers.swift
//  SoftwareEng
//
//  Reusable view modifiers for WSU branding and consistent styling
//

import SwiftUI

// MARK: - Card Modifier

struct WSUCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ColorTheme.cardBackground)
            .cornerRadius(Spacing.cardCornerRadius)
            .shadow(color: ColorTheme.cardShadow, radius: 8, x: 0, y: 2)
    }
}

// MARK: - Button Modifiers

struct WSUPrimaryButtonModifier: ViewModifier {
    var isDisabled: Bool = false

    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(ColorTheme.textOnPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(isDisabled ? ColorTheme.textSecondary : ColorTheme.primary)
            .cornerRadius(Spacing.buttonCornerRadius)
    }
}

struct WSUSecondaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(ColorTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Spacing.buttonCornerRadius)
                    .stroke(ColorTheme.primary, lineWidth: 2)
            )
    }
}

struct WSUAccentButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 17, weight: .semibold))
            .foregroundColor(ColorTheme.textOnAccent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(ColorTheme.accent)
            .cornerRadius(Spacing.buttonCornerRadius)
    }
}

struct WSUTextButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(ColorTheme.primary)
    }
}

// MARK: - TextField Modifier

struct WSUTextFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(Spacing.md)
            .background(ColorTheme.cardBackground)
            .cornerRadius(Spacing.textFieldCornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Spacing.textFieldCornerRadius)
                    .stroke(ColorTheme.border, lineWidth: 1)
            )
    }
}

// MARK: - View Extension for Easy Access

extension View {
    /// Apply WSU card styling with white background and subtle shadow
    func wsuCard() -> some View {
        modifier(WSUCardModifier())
    }

    /// Apply WSU primary button styling with green background
    func wsuPrimaryButton(isDisabled: Bool = false) -> some View {
        modifier(WSUPrimaryButtonModifier(isDisabled: isDisabled))
    }

    /// Apply WSU secondary button styling with green outline
    func wsuSecondaryButton() -> some View {
        modifier(WSUSecondaryButtonModifier())
    }

    /// Apply WSU accent button styling with gold background
    func wsuAccentButton() -> some View {
        modifier(WSUAccentButtonModifier())
    }

    /// Apply WSU text button styling
    func wsuTextButton() -> some View {
        modifier(WSUTextButtonModifier())
    }

    /// Apply WSU text field styling
    func wsuTextField() -> some View {
        modifier(WSUTextFieldModifier())
    }
}
