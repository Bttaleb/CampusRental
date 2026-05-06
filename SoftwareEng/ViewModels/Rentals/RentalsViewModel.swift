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

extension Notification.Name {
    static let rentalDidCancel = Notification.Name("rentalDidCancel")
}

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
        equipmentService: EquipmentServiceProvider = SupabaseEquipmentService()
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

        // Hydrate equipment details for equipment reservations
        do {
            let reservations = try await equipmentService.getUserReservations()
            let hydratedReservations = await hydrateEquipmentDetails(in: reservations)
            collected.append(contentsOf: hydratedReservations.map { $0 as any Rentable })
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
            postCancellationNotification(for: rental)
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

    private func postCancellationNotification(for rental: any Rentable) {
        var userInfo: [String: Any] = [:]

        switch rental {
        case let room as RoomBooking:
            userInfo["type"] = "room"
            userInfo["resourceId"] = room.roomId
        case let equipment as EquipmentReservation:
            userInfo["type"] = "equipment"
            userInfo["resourceId"] = equipment.equipmentId
        case let tutor as TutorSession:
            userInfo["type"] = "tutor"
            userInfo["resourceId"] = tutor.tutorId
        default:
            userInfo["type"] = "unknown"
        }

        NotificationCenter.default.post(name: .rentalDidCancel, object: nil, userInfo: userInfo)
    }

    private func hydrateEquipmentDetails(in reservations: [EquipmentReservation]) async -> [EquipmentReservation] {
        var result: [EquipmentReservation] = []
        result.reserveCapacity(reservations.count)

        for var reservation in reservations {
            if reservation.equipment == nil {
                reservation.equipment = try? await equipmentService.getEquipment(id: reservation.equipmentId)
            }
            result.append(reservation)
        }
        return result
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
