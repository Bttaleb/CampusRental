//
//  WSUBadge.swift
//  SoftwareEng
//
//  Reusable badge component for status indicators
//

import SwiftUI

enum BadgeStyle {
    case pending
    case confirmed
    case cancelled
    case completed
    case noShow
    case custom(backgroundColor: Color, textColor: Color)

    var backgroundColor: Color {
        switch self {
        case .pending: return ColorTheme.statusPending
        case .confirmed: return ColorTheme.statusConfirmed
        case .cancelled: return ColorTheme.statusCancelled
        case .completed: return ColorTheme.statusCompleted
        case .noShow: return ColorTheme.statusNoShow
        case .custom(let bgColor, _): return bgColor
        }
    }

    var textColor: Color {
        switch self {
        case .pending: return ColorTheme.textOnAccent
        case .confirmed: return ColorTheme.textOnPrimary
        case .cancelled: return .white
        case .completed: return .white
        case .noShow: return .white
        case .custom(_, let txtColor): return txtColor
        }
    }
}

struct WSUBadge: View {
    let text: String
    let style: BadgeStyle

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(style.textColor)
            .padding(.horizontal, Spacing.sm)
            .padding(.vertical, Spacing.xxs)
            .background(style.backgroundColor)
            .cornerRadius(6)
    }
}

#Preview {
    VStack(spacing: Spacing.md) {
        WSUBadge(text: "Pending", style: .pending)
        WSUBadge(text: "Confirmed", style: .confirmed)
        WSUBadge(text: "Cancelled", style: .cancelled)
        WSUBadge(text: "Completed", style: .completed)
        WSUBadge(text: "No Show", style: .noShow)
    }
    .padding()
}
