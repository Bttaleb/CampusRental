//
//  MockEquipmentService.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Booking
//  In-memory implementation of EquipmentServiceProvider for tests and offline demo.
//

import Foundation

final class MockEquipmentService: EquipmentServiceProvider { // Polymorphism + Abstraction
    /// Shared in-memory store so every screen (list, detail, rentals) sees the
    /// same reservations during a simulator session.
    static let shared = MockEquipmentService()

    private var equipment: [Equipment]
    private var reservations: [EquipmentReservation] = []
    private let mockUserId = "mock-user-id"

    init(seedEquipment: [Equipment] = MockEquipmentService.defaultEquipment()) {
        self.equipment = seedEquipment
    }

    // MARK: - Discovery

    func search(filters: EquipmentSearchFilters) async throws -> [Equipment] {
        var result = equipment

        if let category = filters.category {
            result = result.filter { $0.category == category }
        }
        if let location = filters.location, !location.isEmpty {
            result = result.filter { $0.location == location }
        }
        if let condition = filters.condition {
            result = result.filter { $0.condition == condition }
        }
        if filters.availableOnly {
            result = result.filter { $0.isAvailable }
        }
        if let q = filters.searchQuery, !q.isEmpty {
            result = result.filter { $0.name.localizedCaseInsensitiveContains(q) }
        }

        switch filters.sortBy {
        case .name:      result.sort { $0.name < $1.name }
        case .category:  result.sort { $0.category.rawValue < $1.category.rawValue }
        case .location:  result.sort { $0.location < $1.location }
        case .condition: result.sort { $0.condition.rawValue < $1.condition.rawValue }
        }
        return result
    }

    func getEquipment(id: String) async throws -> Equipment {
        guard let item = equipment.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockEquipmentService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Equipment not found"])
        }
        return item
    }

    // MARK: - Reservation Management

    func rent(request: EquipmentReservationRequest) async throws -> EquipmentReservation {
        guard let idx = equipment.firstIndex(where: { $0.id == request.equipmentId }) else {
            throw NSError(domain: "MockEquipmentService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Equipment not found"])
        }
        guard equipment[idx].isAvailable else {
            throw EquipmentServiceError.timeSlotConflict
        }
        equipment[idx].isAvailable = false

        let now = Date()
        let reservation = EquipmentReservation(
            id: UUID().uuidString,
            equipmentId: request.equipmentId,
            userId: mockUserId,
            equipment: equipment[idx],
            user: nil,
            startTime: request.startTime,
            endTime: request.endTime,
            purpose: request.purpose,
            status: .confirmed,
            checkedOutAt: nil,
            returnedAt: nil,
            notes: nil,
            createdAt: now,
            updatedAt: now
        )
        reservations.append(reservation)
        return reservation
    }

    func getUserReservations() async throws -> [EquipmentReservation] {
        reservations
            .filter { $0.userId == mockUserId }
            .sorted { $0.startTime > $1.startTime }
    }

    func cancel(id: String) async throws {
        guard let idx = reservations.firstIndex(where: { $0.id == id }) else { return }
        var r = reservations[idx]
        r.status = .cancelled
        reservations[idx] = r

        if let eqIdx = equipment.firstIndex(where: { $0.id == r.equipmentId }) {
            equipment[eqIdx].isAvailable = true
        }
    }

    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> EquipmentReservation {
        guard let idx = reservations.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "MockEquipmentService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Reservation not found"])
        }
        var r = reservations[idx]
        r.startTime = newStartTime
        r.endTime = newEndTime
        r.updatedAt = Date()
        reservations[idx] = r
        return r
    }

    // MARK: - Availability

    func getEquipmentAvailability(equipmnentId: String, date: Date) async throws -> [TimeSlot] {
        []
    }

    // MARK: - Ratings

    func rate(equipmentId: String, rating: Int, comment: String?) async throws {
        // No-op in mock
    }

    // MARK: - Seed Data

    private static func defaultEquipment() -> [Equipment] {
        let now = Date()
        return [
            Equipment(
                id: "eq-1", name: "MacBook Pro 14\"", category: .laptop,
                description: "M3 Pro, 18GB RAM. Loaner laptop.",
                imageURL: nil, serialNumber: "MBP-001",
                location: "Library Help Desk", isAvailable: true,
                condition: .excellent,
                specifications: ["CPU": "M3 Pro", "RAM": "18GB", "Storage": "512GB"],
                createdAt: now, updatedAt: now
            ),
            Equipment(
                id: "eq-2", name: "Canon EOS R6", category: .camera,
                description: "Mirrorless body with 24-105mm kit lens.",
                imageURL: nil, serialNumber: "CAM-014",
                location: "Media Center", isAvailable: true,
                condition: .good,
                specifications: ["Sensor": "Full-frame", "Lens": "24-105mm f/4"],
                createdAt: now, updatedAt: now
            ),
            Equipment(
                id: "eq-3", name: "TI-84 Plus CE", category: .calculator,
                description: "Graphing calculator for exams.",
                imageURL: nil, serialNumber: "CAL-203",
                location: "Math Department", isAvailable: true,
                condition: .good,
                specifications: nil,
                createdAt: now, updatedAt: now
            ),
            Equipment(
                id: "eq-4", name: "Epson PowerLite Projector", category: .projector,
                description: "1080p portable projector with HDMI.",
                imageURL: nil, serialNumber: "PRJ-007",
                location: "Student Center AV", isAvailable: false,
                condition: .fair,
                specifications: ["Lumens": "3600", "Resolution": "1920x1080"],
                createdAt: now, updatedAt: now
            ),
            Equipment(
                id: "eq-5", name: "iPad Air", category: .tablet,
                description: "10.9\" with Apple Pencil.",
                imageURL: nil, serialNumber: "TAB-031",
                location: "Library Help Desk", isAvailable: true,
                condition: .excellent,
                specifications: ["Storage": "256GB", "Accessories": "Apple Pencil"],
                createdAt: now, updatedAt: now
            ),
            Equipment(
                id: "eq-6", name: "Shure SM7B Microphone", category: .microphone,
                description: "Studio mic for podcasts and interviews.",
                imageURL: nil, serialNumber: "MIC-019",
                location: "Media Center", isAvailable: true,
                condition: .good,
                specifications: nil,
                createdAt: now, updatedAt: now
            )
        ]
    }
}
