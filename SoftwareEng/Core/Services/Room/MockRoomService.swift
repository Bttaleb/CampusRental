//
//  MockRoomService.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  In-memory implementation of RoomServiceProvider for tests and offline demo.
//

import Foundation

final class MockRoomService: RoomServiceProvider { // Polymorphism + Abstraction
    private var rooms: [StudyRoom]
    private var bookings: [RoomBooking] = []
    private let mockUserId = "mock-user-id"

    init(seedRooms: [StudyRoom] = MockRoomService.defaultRooms()) {
        self.rooms = seedRooms
    }

    // MARK: - Discovery

    func search(filters: RoomSearchFilters) async throws -> [StudyRoom] {
        var result = rooms

        if let building = filters.building, !building.isEmpty {
            result = result.filter { $0.building == building }
        }
        if let minCapacity = filters.minCapacity {
            result = result.filter { $0.capacity >= minCapacity }
        }
        if !filters.requiredFeatures.isEmpty {
            result = result.filter { room in
                filters.requiredFeatures.allSatisfy { room.features.contains($0) }
            }
        }

        switch filters.sortBy {
        case .name:     result.sort { $0.name < $1.name }
        case .capacity: result.sort { $0.capacity < $1.capacity }
        case .building: result.sort { $0.building < $1.building }
        }
        return result
    }

    func getRoom(id: String) async throws -> StudyRoom {
        guard let room = rooms.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockRoomService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Room not found"])
        }
        return room
    }

    // MARK: - Booking Management

    func book(request: RoomBookingRequest) async throws -> RoomBooking {
        let now = Date()
        let booking = RoomBooking(
            id: UUID().uuidString,
            roomId: request.roomId,
            userId: mockUserId,
            room: rooms.first { $0.id == request.roomId },
            user: nil,
            startTime: request.startTime,
            endTime: request.endTime,
            purpose: request.purpose,
            attendees: request.attendees,
            status: .confirmed,
            createdAt: now,
            updatedAt: now
        )
        bookings.append(booking)
        return booking
    }

    func getUserBookings() async throws -> [RoomBooking] {
        bookings
            .filter { $0.userId == mockUserId }
            .sorted { $0.startTime > $1.startTime }
    }

    func cancel(id: String) async throws {
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else { return }
        var b = bookings[idx]
        b.status = .cancelled
        bookings[idx] = b
    }

    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> RoomBooking {
        guard let idx = bookings.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "MockRoomService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Booking not found"])
        }
        var b = bookings[idx]
        b.startTime = newStartTime
        b.endTime = newEndTime
        b.updatedAt = Date()
        bookings[idx] = b
        return b
    }

    // MARK: - Availability

    func getAvailability(roomId: String, date: Date) async throws -> [TimeSlot] {
        []
    }

    // MARK: - Ratings

    func rate(roomId: String, rating: Int, comment: String?) async throws {
        // No-op in mock
    }

    // MARK: - Seed Data

    private static func defaultRooms() -> [StudyRoom] {
        let now = Date()
        return [
            StudyRoom(
                id: "room-1", name: "Quiet Room A", building: "Library",
                floor: 2, roomNumber: "201", capacity: 6,
                features: [.whiteboard, .wifi, .powerOutlets],
                imageURL: nil, isAvailable: true,
                description: "Group study room.",
                createdAt: now, updatedAt: now
            ),
            StudyRoom(
                id: "room-2", name: "Conference Room", building: "Student Center",
                floor: 1, roomNumber: "105", capacity: 12,
                features: [.projector, .tvScreen, .computer, .wifi, .airConditioning],
                imageURL: nil, isAvailable: true,
                description: "Large room with AV equipment.",
                createdAt: now, updatedAt: now
            ),
            StudyRoom(
                id: "room-3", name: "Pod 3B", building: "Library",
                floor: 3, roomNumber: "303", capacity: 4,
                features: [.whiteboard, .wifi],
                imageURL: nil, isAvailable: false,
                description: "Small group pod.",
                createdAt: now, updatedAt: now
            )
        ]
    }
}
