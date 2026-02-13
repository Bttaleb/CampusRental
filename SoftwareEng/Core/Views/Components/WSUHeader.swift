//
//  WSUHeader.swift
//  SoftwareEng
//
//  Wayne State University branded header component
//

import SwiftUI

struct WSUHeader: View {
    let title: String
    var subtitle: String? = nil
    var showGradient: Bool = true

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Spacing.lg)
        .background(
            Group {
                if showGradient {
                    LinearGradient(
                        gradient: Gradient(colors: [ColorTheme.wsuGreen, ColorTheme.wsuLightGreen]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    ColorTheme.wsuGreen
                }
            }
        )
    }
}

#Preview {
    VStack(spacing: 0) {
        WSUHeader(title: "Campus Booking", subtitle: "Wayne State University")
        WSUHeader(title: "Dashboard", showGradient: false)
    }
}
