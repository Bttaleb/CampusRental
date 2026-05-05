//
//  MyRentalsView.swift
//  CampusBookingSystem
//
//  Unified rental history across tutor sessions, study rooms, and equipment.
//  Driven entirely by the Rentable protocol.
//

import SwiftUI

struct MyRentalsView: View {
    @StateObject private var vm = RentalsViewModel()

    var body: some View {
        NavigationStack {
            List {
                if !vm.upcoming.isEmpty {
                    Section("Upcoming") {
                        ForEach(vm.upcoming.indices, id: \.self) { i in
                            let rental = vm.upcoming[i]
                            AnyRentalRow(rental: rental, onCancel: nil)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if rental.canCancel {
                                        Button(role: .destructive) {
                                            Task { await vm.cancel(rental) }
                                        } label: {
                                            Label("Cancel", systemImage: "xmark.circle")
                                        }
                                    }
                                }
                        }
                    }
                }
                if !vm.past.isEmpty {
                    Section("Past") {
                        ForEach(vm.past.indices, id: \.self) { i in
                            let rental = vm.past[i]
                            AnyRentalRow(rental: rental, onCancel: nil)
                        }
                    }
                }
                if vm.rentals.isEmpty && !vm.isLoading {
                    ContentUnavailableView(
                        "No rentals yet",
                        systemImage: "tray",
                        description: Text("Your tutor sessions, room bookings, and equipment reservations will appear here.")
                    )
                }
            }
            .navigationTitle("My Rentals")
            .overlay { if vm.isLoading { ProgressView() } }
            .task { await vm.load() }
            .refreshable { await vm.load() }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: {
                Text(vm.errorMessage ?? "")
            })
        }
    }
}

/// Non-generic row that renders any Rentable directly, sidestepping the
/// existential-opening dance Swift requires for generic row types.
struct AnyRentalRow: View {
    let rental: any Rentable
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
