//
//  RentalsViewModel.swift
//  CampusBookingSystem
//
//  Unified view model that surfaces every Rentable (tutor sessions, room
//  bookings, equipment reservations) the user owns, regardless of domain.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class RentalsViewModel: ObservableObject { // Abstraction + Polymorphism
    @Published var rentals: [any Rentable] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var canUndoLastAction = false

    private let tutorService: TutorServiceProvider
    private let roomService: RoomServiceProvider
    private let equipmentService: EquipmentServiceProvider
    private let history = RentalHistoryCaretaker(maxSnapshots: 10)

    init(
        tutorService: TutorServiceProvider = SupabaseTutorService(),
        roomService: RoomServiceProvider = SupabaseRoomService(),
        equipmentService: EquipmentServiceProvider = MockEquipmentService.shared
    ) {
        self.tutorService = tutorService
        self.roomService = roomService
        self.equipmentService = equipmentService
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        var collected: [any Rentable] = []
        var firstError: String?

        do {
            let sessions = try await tutorService.getUserSessions()
            collected.append(contentsOf: sessions.map { $0 as any Rentable })
        } catch {
            firstError = firstError ?? error.localizedDescription
        }

        do {
            let bookings = try await roomService.getUserBookings()
            collected.append(contentsOf: bookings.map { $0 as any Rentable })
        } catch {
            firstError = firstError ?? error.localizedDescription
        }

        do {
            let reservations = try await equipmentService.getUserReservations()
            collected.append(contentsOf: reservations.map { $0 as any Rentable })
        } catch {
            firstError = firstError ?? error.localizedDescription
        }

        if let firstError, collected.isEmpty {
            errorMessage = firstError
        }
        rentals = collected.sorted { $0.startTime > $1.startTime }
    }

    func cancel(_ rental: any Rentable) async {
        do {
            saveSnapshot(label: "Cancel rental")
            try await rental.cancel()
            let targetKey = "\(rental.id)"
            rentals.removeAll { "\($0.id)" == targetKey }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func undoLastAction() {
        guard let snapshot = history.pop() else { return }
        rentals = snapshot.rentals
        canUndoLastAction = history.hasSnapshots
    }

    private func saveSnapshot(label: String) {
        history.push(
            RentalSnapshot(
                rentals: rentals,
                actionLabel: label,
                createdAt: Date()
            )
        )
        canUndoLastAction = true
    }

    var upcoming: [any Rentable] { rentals.filter { $0.isUpcoming } }
    var past: [any Rentable]     { rentals.filter { $0.isPast } }
}

// MARK: - Memento
private struct RentalSnapshot {
    let rentals: [any Rentable]
    let actionLabel: String
    let createdAt: Date
}

private final class RentalHistoryCaretaker {
    private let maxSnapshots: Int
    private var snapshots: [RentalSnapshot] = []

    init(maxSnapshots: Int) {
        self.maxSnapshots = maxSnapshots
    }

    var hasSnapshots: Bool {
        !snapshots.isEmpty
    }

    func push(_ snapshot: RentalSnapshot) {
        snapshots.append(snapshot)
        if snapshots.count > maxSnapshots {
            snapshots.removeFirst()
        }
    }

    func pop() -> RentalSnapshot? {
        snapshots.popLast()
    }
}
