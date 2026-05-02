//
//  TutorServiceProvider.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//  Requirements: Abstract contract for tutor service implementations
//

import Foundation
// MARK: OOP - Abstraction, Encapsulation

// MARK: - Tutor Service Protocol
protocol TutorServiceProvider { // Abstraction - hides concrete tutor backend (Supabase, mock, REST, etc.)

    // MARK: - Discovery
    func searchTutors(filters: TutorSearchFilters) async throws -> [TutorProfile]
    func getTutorProfile(id: String) async throws -> TutorProfile

    // MARK: - Session Management
    func bookSession(request: TutorBookingRequest) async throws -> TutorSession
    func getUserSessions() async throws -> [TutorSession]
    func cancelSession(id: String) async throws
    func rescheduleSession(id: String, newStartTime: Date, newEndTime: Date) async throws -> TutorSession

    // MARK: - Availability
    func getTutorAvailability(tutorId: String, date: Date) async throws -> [TimeSlot]

    // MARK: - Ratings
    func rateSession(sessionId: String, rating: Int, comment: String?) async throws
}
