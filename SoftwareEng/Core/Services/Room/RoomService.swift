//
//  RoomService.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  Concrete Supabase-backed implementation of RoomServiceProvider.
//

import Foundation
import Supabase
// MARK: OOP — Encapsulation, Abstraction
struct SupabaseRoomService: RoomServiceProvider { // Abstraction — concrete implementation
    private let client: SupabaseClient // Encapsulation — Supabase client hidden from callers

    init(client: SupabaseClient) { // Dependency Injection
        self.client = client
    }

    init() {
        self.init(client: SupabaseClient(
            supabaseURL: URL(string: AppConstants.projectURLString)!,
            supabaseKey: AppConstants.projectAPIKey
        ))
    }

    // MARK: - Discovery

    func search(filters: RoomSearchFilters) async throws -> [StudyRoom] {
        var query = client.from("study_rooms").select()

        if let building = filters.building, !building.isEmpty {
            query = query.eq("building", value: building)
        }
        if let minCapacity = filters.minCapacity {
            query = query.gte("capacity", value: minCapacity)
        }
        if !filters.requiredFeatures.isEmpty {
            let featureStrings = filters.requiredFeatures.map { $0.rawValue }
            query = query.contains("features", value: featureStrings)
        }

        let orderColumn: String
        let ascending: Bool
        switch filters.sortBy {
        case .building: orderColumn = "building"; ascending = true
        case .capacity: orderColumn = "capacity"; ascending = true
        case .name:     orderColumn = "name";     ascending = true
        }

        return try await query.order(orderColumn, ascending: ascending).execute().value
    }

    func getRoom(id: String) async throws -> StudyRoom {
        return try await client.from("study_rooms")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    // MARK: - Booking Management

    func book(request: RoomBookingRequest) async throws -> RoomBooking {
        return try await client.from("room_bookings")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
    }

    func getUserBookings() async throws -> [RoomBooking] {
        guard let userId = try? await client.auth.session.user.id.uuidString else {
            return []
        }

        return try await client.from("room_bookings")
            .select()
            .eq("user_id", value: userId)
            .order("start_time", ascending: false)
            .execute()
            .value
    }

    func cancel(id: String) async throws {
        try await client.from("room_bookings")
            .update(["status": "cancelled"])
            .eq("id", value: id)
            .execute()
    }

    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> RoomBooking {
        let formatter = ISO8601DateFormatter()
        return try await client.from("room_bookings")
            .update([
                "start_time": formatter.string(from: newStartTime),
                "end_time": formatter.string(from: newEndTime)
            ])
            .eq("id", value: id)
            .select()
            .single()
            .execute()
            .value
    }

    // MARK: - Availability

    /// Returns time slots for a given room on a given day.
    /// TODO: real implementation needs to compare existing bookings against
    /// the room's operating hours. For now we return an empty array so the
    /// surface of the protocol is honored without shipping wrong data.
    func getAvailability(roomId: String, date: Date) async throws -> [TimeSlot] {
        return []
    }

    // MARK: - Ratings

    func rate(roomId: String, rating: Int, comment: String?) async throws {
        let payload = RoomRatingInsert(roomId: roomId, rating: rating, comment: comment)
        try await client.from("room_ratings")
            .insert(payload)
            .execute()
    }
}

// MARK: - Request Bodies

private struct RoomRatingInsert: Encodable { // Encapsulation — payload shape hidden from outside the service
    let roomId: String
    let rating: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case rating
        case comment
    }
}
