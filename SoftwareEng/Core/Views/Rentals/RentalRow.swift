//
//  RentalRow.swift
//  CampusBookingSystem
//
//  Generic list row that renders any Rentable using only the protocol
//  surface — no per-domain switch statements.
//

import SwiftUI

struct RentalRow<R: Rentable>: View { // Polymorphism via generics
    let rental: R
    var onCancel: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(rental.displayTitle)
                .font(.headline)
            Text(rental.formattedTimeRange)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack {
                Text(rental.formattedDuration)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                if rental.canCancel, let onCancel {
                    Button("Cancel", role: .destructive, action: onCancel)
                        .buttonStyle(.borderless)
                        .font(.caption)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
