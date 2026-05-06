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

// MARK: - Domain Errors

enum RoomServiceError: LocalizedError { // Encapsulation — readable, user-facing wording
    case timeSlotConflict
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .timeSlotConflict: return "This room is already booked for that time. Pick a different slot."
        case .notAuthenticated: return "You must be signed in to do that."
        }
    }
}

// MARK: - Service

struct SupabaseRoomService: RoomServiceProvider { // Abstraction — concrete implementation
    private let client: SupabaseClient // Encapsulation — Supabase client hidden from callers

    // Operating hours used to compute hourly availability slots.
    // Adjust later if rooms have varying hours per building.
    private static let openHour  = 8
    private static let closeHour = 22

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
        try await ensureRoomIsAvailable(
            roomId: request.roomId,
            start: request.startTime,
            end: request.endTime,
            excludingBookingId: nil
        )
        do {
            return try await client.from("room_bookings")
                .insert(request)
                .select()
                .single()
                .execute()
                .value
        } catch {
            // Translate the EXCLUDE constraint violation into a user-friendly error.
            // Supabase surfaces the raw Postgres message; the constraint name is
            // a stable signal that we tripped the no-overlap rule.
            if "\(error)".contains("room_bookings_no_overlap") {
                throw RoomServiceError.timeSlotConflict
            }
            throw error
        }
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
        let current: RoomBooking = try await client.from("room_bookings")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        try await ensureRoomIsAvailable(
            roomId: current.roomId,
            start: newStartTime,
            end: newEndTime,
            excludingBookingId: id
        )

        let formatter = ISO8601DateFormatter()
        do {
            return try await client.from("room_bookings")
                .update([
                    "start_time": formatter.string(from: newStartTime),
                    "end_time":   formatter.string(from: newEndTime)
                ])
                .eq("id", value: id)
                .select()
                .single()
                .execute()
                .value
        } catch {
            if "\(error)".contains("room_bookings_no_overlap") {
                throw RoomServiceError.timeSlotConflict
            }
            throw error
        }
    }

    // MARK: - Availability

    /// Returns hourly time slots for a given room on a given day. Each slot is
    /// marked unavailable if any active booking (pending or confirmed) for that
    /// room overlaps it. Operating hours are 08:00–22:00 by convention.
    func getAvailability(roomId: String, date: Date) async throws -> [TimeSlot] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        // Fetch any active booking on this room whose window overlaps the day.
        // Two ranges [a, b) and [c, d) overlap iff a < d AND c < b.
        let bookings: [RoomBooking] = try await client.from("room_bookings")
            .select()
            .eq("room_id", value: roomId)
            .in("status", values: ["pending", "confirmed"])
            .lt("start_time", value: formatter.string(from: endOfDay))
            .gt("end_time",   value: formatter.string(from: startOfDay))
            .execute()
            .value

        var slots: [TimeSlot] = []
        for hour in Self.openHour..<Self.closeHour {
            guard
                let slotStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay),
                let slotEnd   = calendar.date(byAdding: .hour, value: 1, to: slotStart)
            else { continue }

            let isBooked = bookings.contains { booking in
                booking.startTime < slotEnd && booking.endTime > slotStart
            }
            slots.append(TimeSlot(
                startTime: slotStart,
                endTime: slotEnd,
                isAvailable: !isBooked
            ))
        }
        return slots
    }

    // MARK: - Ratings

    func rate(roomId: String, rating: Int, comment: String?) async throws {
        let payload = RoomRatingInsert(roomId: roomId, rating: rating, comment: comment)
        try await client.from("room_ratings")
            .insert(payload)
            .execute()
    }

    // MARK: - Conflict Guard

    private func ensureRoomIsAvailable(
        roomId: String,
        start: Date,
        end: Date,
        excludingBookingId: String?
    ) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var query = client.from("room_bookings")
            .select("id")
            .eq("room_id", value: roomId)
            .in("status", values: ["pending", "confirmed"])
            .lt("start_time", value: formatter.string(from: end))
            .gt("end_time", value: formatter.string(from: start))
            .limit(20)

        let conflicts: [BookingConflictRow] = try await query.execute().value
        let hasConflicts = conflicts.contains { conflict in
            guard let excludingBookingId else { return true }
            return conflict.id != excludingBookingId
        }
        if hasConflicts {
            throw RoomServiceError.timeSlotConflict
        }
    }
}

private struct BookingConflictRow: Decodable {
    let id: String
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
