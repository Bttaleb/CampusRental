//
//  TutorService.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//  Concrete Supabase-backed implementation of TutorServiceProvider
//

import Foundation
import Supabase
// MARK: OOP — Encapsulation, Abstraction
struct SupabaseTutorService: TutorServiceProvider { // Abstraction — concrete implementation of TutorServiceProvider
    private let client: SupabaseClient // Encapsulation — Supabase client hidden from callers

    init(client: SupabaseClient) { // Dependency Injection — client supplied by composition root
        self.client = client
    }

    init() {
        self.init(client: SupabaseClient(
            supabaseURL: URL(string: AppConstants.projectURLString)!,
            supabaseKey: AppConstants.projectAPIKey
        ))
    }

    // MARK: - Tutor Discovery

    func searchTutors(filters: TutorSearchFilters) async throws -> [TutorProfile] {
        var query = client.from("tutor_profiles").select()

        if let subject = filters.subject, !subject.isEmpty {
            query = query.contains("subjects", value: [subject])
        }
        if let minRate = filters.minRate {
            query = query.gte("hourly_rate", value: minRate)
        }
        if let maxRate = filters.maxRate {
            query = query.lte("hourly_rate", value: maxRate)
        }
        if let minRating = filters.minRating {
            query = query.gte("rating", value: minRating)
        }

        let orderColumn: String
        let ascending: Bool
        switch filters.sortBy {
        case .rating:
            orderColumn = "rating"
            ascending = false
        case .price:
            orderColumn = "hourly_rate"
            ascending = true
        case .sessions:
            orderColumn = "total_sessions"
            ascending = false
        case .name:
            orderColumn = "name"
            ascending = true
        }

        return try await query.order(orderColumn, ascending: ascending).execute().value
    }

    func getTutorProfile(id: String) async throws -> TutorProfile {
        return try await client.from("tutor_profiles")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }

    // MARK: - Session Management

    func bookSession(request: TutorBookingRequest) async throws -> TutorSession {
        return try await client.from("tutor_sessions")
            .insert(request)
            .select()
            .single()
            .execute()
            .value
    }

    func getUserSessions() async throws -> [TutorSession] {
        guard let userId = try? await client.auth.session.user.id.uuidString else {
            return []
        }

        return try await client.from("tutor_sessions")
            .select()
            .eq("student_id", value: userId)
            .order("start_time", ascending: false)
            .execute()
            .value
    }

    func cancelSession(id: String) async throws {
        try await client.from("tutor_sessions")
            .update(["status": "cancelled"])
            .eq("id", value: id)
            .execute()
    }

    func rescheduleSession(id: String, newStartTime: Date, newEndTime: Date) async throws -> TutorSession {
        let formatter = ISO8601DateFormatter()
        return try await client.from("tutor_sessions")
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

    func getTutorAvailability(tutorId: String, date: Date) async throws -> [TimeSlot] {
        let formatter = ISO8601DateFormatter()
        let dateString = formatter.string(from: date)

        return try await client.from("tutor_availability")
            .select()
            .eq("tutor_id", value: tutorId)
            .eq("date", value: dateString)
            .execute()
            .value
    }

    // MARK: - Ratings

    func rateSession(sessionId: String, rating: Int, comment: String?) async throws {
        let ratingData = RatingInsert(sessionId: sessionId, rating: rating, comment: comment)
        try await client.from("tutor_ratings")
            .insert(ratingData)
            .execute()
    }
}

// MARK: - Request Bodies

private struct RatingInsert: Encodable { // Encapsulation — payload shape hidden from outside the service
    let sessionId: String
    let rating: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case rating
        case comment
    }
}
