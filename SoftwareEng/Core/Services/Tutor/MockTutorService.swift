//
//  MockTutorService.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//  In-memory implementation of TutorServiceProvider for tests and offline demo.
//
//  OOP — Demonstrates LSP/OCP/DIP: TutorViewModel works with this implementation
//  with zero changes. Same protocol, swappable backend.
//

import Foundation

final class MockTutorService: TutorServiceProvider { // Polymorphism + Abstraction
    private var tutors: [TutorProfile] // Encapsulation — backing store hidden
    private var sessions: [TutorSession] = []
    private let mockStudentId = "mock-student-id"

    init(seedTutors: [TutorProfile] = MockTutorService.defaultTutors()) {
        self.tutors = seedTutors
    }

    // MARK: - Discovery

    func searchTutors(filters: TutorSearchFilters) async throws -> [TutorProfile] {
        var result = tutors

        if let subject = filters.subject, !subject.isEmpty {
            result = result.filter { $0.subjects.contains(subject) }
        }
        if let minRate = filters.minRate {
            result = result.filter { $0.hourlyRate >= minRate }
        }
        if let maxRate = filters.maxRate {
            result = result.filter { $0.hourlyRate <= maxRate }
        }
        if let minRating = filters.minRating {
            result = result.filter { $0.rating >= minRating }
        }

        switch filters.sortBy {
        case .rating:   result.sort { $0.rating > $1.rating }
        case .price:    result.sort { $0.hourlyRate < $1.hourlyRate }
        case .sessions: result.sort { $0.totalSessions > $1.totalSessions }
        case .name:     result.sort { $0.name < $1.name }
        }
        return result
    }

    func getTutorProfile(id: String) async throws -> TutorProfile {
        guard let tutor = tutors.first(where: { $0.id == id }) else {
            throw NSError(domain: "MockTutorService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Tutor not found"])
        }
        return tutor
    }

    // MARK: - Session Management

    func bookSession(request: TutorBookingRequest) async throws -> TutorSession {
        let now = Date()
        let session = TutorSession(
            id: UUID().uuidString,
            tutorId: request.tutorId,
            studentId: mockStudentId,
            tutor: tutors.first { $0.id == request.tutorId },
            student: nil,
            subject: request.subject,
            startTime: request.startTime,
            endTime: request.endTime,
            status: .scheduled,
            notes: request.notes,
            meetingLink: nil,
            createdAt: now,
            updatedAt: now
        )
        sessions.append(session)
        return session
    }

    func getUserSessions() async throws -> [TutorSession] {
        sessions
            .filter { $0.studentId == mockStudentId }
            .sorted { $0.startTime > $1.startTime }
    }

    func cancelSession(id: String) async throws {
        guard let idx = sessions.firstIndex(where: { $0.id == id }) else { return }
        var s = sessions[idx]
        s.status = .cancelled
        sessions[idx] = s
    }

    func rescheduleSession(id: String, newStartTime: Date, newEndTime: Date) async throws -> TutorSession {
        guard let idx = sessions.firstIndex(where: { $0.id == id }) else {
            throw NSError(domain: "MockTutorService", code: 404,
                          userInfo: [NSLocalizedDescriptionKey: "Session not found"])
        }
        var s = sessions[idx]
        s.startTime = newStartTime
        s.endTime = newEndTime
        s.updatedAt = Date()
        sessions[idx] = s
        return s
    }

    // MARK: - Availability

    func getTutorAvailability(tutorId: String, date: Date) async throws -> [TimeSlot] {
        []
    }

    // MARK: - Ratings

    func rateSession(sessionId: String, rating: Int, comment: String?) async throws {
        // No-op in mock
    }

    // MARK: - Seed Data

    private static func defaultTutors() -> [TutorProfile] {
        let now = Date()
        return [
            TutorProfile(
                id: "mock-1", userId: "user-1", name: "Alex Chen", email: "alex@wsu.edu",
                photoURL: nil, subjects: ["Calculus", "Linear Algebra"], hourlyRate: 25,
                availability: [], rating: 4.9, totalSessions: 87,
                bio: "Math grad student, 3 years tutoring.", isApproved: true,
                createdAt: now, updatedAt: now
            ),
            TutorProfile(
                id: "mock-2", userId: "user-2", name: "Priya Patel", email: "priya@wsu.edu",
                photoURL: nil, subjects: ["CS 1101", "Data Structures"], hourlyRate: 30,
                availability: [], rating: 4.8, totalSessions: 64,
                bio: "CS senior. Loves debugging.", isApproved: true,
                createdAt: now, updatedAt: now
            ),
            TutorProfile(
                id: "mock-3", userId: "user-3", name: "Marcus Johnson", email: "marcus@wsu.edu",
                photoURL: nil, subjects: ["Physics", "Calculus"], hourlyRate: 22,
                availability: [], rating: 4.7, totalSessions: 41,
                bio: "Physics MS, patient with first-years.", isApproved: true,
                createdAt: now, updatedAt: now
            )
        ]
    }
}
