//
//  TutorViewModel.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//  Handles tutor search, filtering, and session booking
//

import Foundation
import SwiftUI
import Combine

@MainActor
class TutorViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var tutors: [TutorProfile] = []
    @Published var selectedTutor: TutorProfile?
    @Published var mySessions: [TutorSession] = []
    @Published var searchFilters = TutorSearchFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - Services
    private let tutorService = TutorService.shared
    
    // MARK: - Tutor Discovery
    
    /// Fetch all tutors with optional filters
    func fetchTutors(filters: TutorSearchFilters? = nil) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let appliedFilters = filters ?? searchFilters
            tutors = try await tutorService.searchTutors(filters: appliedFilters)
        } catch {
            errorMessage = error.localizedDescription
            print("DEBUG: Failed to fetch tutors: \(error)")
        }
        
        isLoading = false
    }
    
    /// Fetch specific tutor details
    func fetchTutorDetails(tutorId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            selectedTutor = try await tutorService.getTutorProfile(id: tutorId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Search tutors by subject
    func searchBySubject(_ subject: String) async {
        var filters = TutorSearchFilters()
        filters.subject = subject
        await fetchTutors(filters: filters)
    }
    
    // MARK: - Session Booking
    
    /// Book a tutoring session
    func bookSession(tutorId: String, subject: String, startTime: Date, endTime: Date, notes: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let request = TutorBookingRequest(
                tutorId: tutorId,
                subject: subject,
                startTime: startTime,
                endTime: endTime,
                notes: notes
            )
            
            let session = try await tutorService.bookSession(request: request)
            mySessions.insert(session, at: 0)
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// Fetch user's tutoring sessions
    func fetchMySessions() async {
        isLoading = true
        errorMessage = nil
        
        do {
            mySessions = try await tutorService.getUserSessions()
            mySessions.sort { $0.startTime > $1.startTime }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    /// Cancel a session
    func cancelSession(sessionId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            try await tutorService.cancelSession(id: sessionId)
            mySessions.removeAll { $0.id == sessionId }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// Reschedule a session
    func rescheduleSession(sessionId: String, newStartTime: Date, newEndTime: Date) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedSession = try await tutorService.rescheduleSession(
                id: sessionId,
                newStartTime: newStartTime,
                newEndTime: newEndTime
            )
            
            if let index = mySessions.firstIndex(where: { $0.id == sessionId }) {
                mySessions[index] = updatedSession
            }
            
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Availability
    
    /// Check tutor availability for a specific time
    func checkAvailability(tutorId: String, date: Date) async -> [TimeSlot] {
        do {
            return try await tutorService.getTutorAvailability(tutorId: tutorId, date: date)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
    
    // MARK: - Ratings (Epic 7 - Optional)
    
    /// Submit rating for a session
    func rateSession(sessionId: String, rating: Int, comment: String?) async -> Bool {
        guard Config.Features.ratingsEnabled else { return false }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await tutorService.rateSession(sessionId: sessionId, rating: rating, comment: comment)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    // MARK: - Filters & Sorting
    
    func applyFilters(subject: String? = nil, minRate: Double? = nil, maxRate: Double? = nil, 
                     minRating: Double? = nil, sortBy: TutorSortOption? = nil) {
        if let subject = subject { searchFilters.subject = subject }
        if let minRate = minRate { searchFilters.minRate = minRate }
        if let maxRate = maxRate { searchFilters.maxRate = maxRate }
        if let minRating = minRating { searchFilters.minRating = minRating }
        if let sortBy = sortBy { searchFilters.sortBy = sortBy }
        
        Task {
            await fetchTutors()
        }
    }
    
    func clearFilters() {
        searchFilters = TutorSearchFilters()
        Task {
            await fetchTutors()
        }
    }
    
    // MARK: - Computed Properties
    
    var upcomingSessions: [TutorSession] {
        mySessions.filter { $0.status == .scheduled && $0.startTime > Date() }
    }
    
    var pastSessions: [TutorSession] {
        mySessions.filter { $0.endTime < Date() }
    }
    
    var availableSubjects: [String] {
        Array(Set(tutors.flatMap { $0.subjects })).sorted()
    }
}
