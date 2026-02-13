//
//  WSUEmptyState.swift
//  SoftwareEng
//
//  Empty state view with WSU branding
//

import SwiftUI

struct WSUEmptyState: View {
    let icon: String
    let title: String
    let message: String
    var actionTitle: String? = nil
    var action: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(ColorTheme.wsuGreen.opacity(0.3))
                .padding(.bottom, Spacing.sm)

            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(ColorTheme.textPrimary)

            Text(message)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(ColorTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Spacing.xl)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                }
                .wsuPrimaryButton()
                .padding(.horizontal, Spacing.xl)
                .padding(.top, Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(Spacing.xl)
    }
}

#Preview {
    WSUEmptyState(
        icon: "calendar.badge.exclamationmark",
        title: "No Bookings Yet",
        message: "You haven't made any bookings. Start by exploring available rooms and tutors.",
        actionTitle: "Browse Rooms",
        action: { print("Action tapped") }
    )
}
