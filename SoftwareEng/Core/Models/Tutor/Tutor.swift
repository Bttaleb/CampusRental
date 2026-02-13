//
//  Tutor.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//  Requirements: Tutor profiles with availability and booking management
//

import Foundation

// MARK: - Tutor Profile
struct TutorProfile: Codable, Identifiable {
    let id: String
    let userId: String
    var name: String
    var email: String
    var photoURL: String?
    var subjects: [String]
    var hourlyRate: Double
    var availability: [AvailabilitySlot]
    var rating: Double
    var totalSessions: Int
    var bio: String
    var isApproved: Bool
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case email
        case photoURL = "photo_url"
        case subjects
        case hourlyRate = "hourly_rate"
        case availability
        case rating
        case totalSessions = "total_sessions"
        case bio
        case isApproved = "is_approved"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var formattedRate: String {
        String(format: "$%.2f/hr", hourlyRate)
    }
    
    var ratingDisplay: String {
        String(format: "%.1f", rating)
    }
}

// MARK: - Tutor Search Filters
struct TutorSearchFilters {
    var subject: String?
    var minRate: Double?
    var maxRate: Double?
    var minRating: Double?
    var availableOn: DayOfWeek?
    var sortBy: TutorSortOption = .rating
    
    var queryParameters: [String: String] {
        var params: [String: String] = [:]
        
        if let subject = subject {
            params["subject"] = subject
        }
        if let minRate = minRate {
            params["min_rate"] = String(minRate)
        }
        if let maxRate = maxRate {
            params["max_rate"] = String(maxRate)
        }
        if let minRating = minRating {
            params["min_rating"] = String(minRating)
        }
        if let availableOn = availableOn {
            params["available_on"] = availableOn.rawValue
        }
        params["sort_by"] = sortBy.rawValue
        
        return params
    }
}

enum TutorSortOption: String, CaseIterable {
    case rating = "rating"
    case price = "price"
    case sessions = "sessions"
    case name = "name"
    
    var displayName: String {
        switch self {
        case .rating: return "Rating"
        case .price: return "Price"
        case .sessions: return "Sessions"
        case .name: return "Name"
        }
    }
}

// MARK: - Tutor Session
struct TutorSession: Codable, Identifiable {
    let id: String
    let tutorId: String
    let studentId: String
    var tutor: TutorProfile?
    var student: User?
    var subject: String
    var startTime: Date
    var endTime: Date
    var status: SessionStatus
    var notes: String?
    var meetingLink: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case tutorId = "tutor_id"
        case studentId = "student_id"
        case tutor
        case student
        case subject
        case startTime = "start_time"
        case endTime = "end_time"
        case status
        case notes
        case meetingLink = "meeting_link"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = (Int(duration) % 3600) / 60
        return hours > 0 ? "\(hours)h \(minutes)m" : "\(minutes)m"
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var canCancel: Bool {
        status == .scheduled && startTime.timeIntervalSinceNow > Config.Booking.tutorCancellationDeadline
    }
    
    var canReschedule: Bool {
        status == .scheduled && startTime.timeIntervalSinceNow > Config.Booking.tutorCancellationDeadline
    }
}

// MARK: - Session Status
enum SessionStatus: String, Codable {
    case scheduled = "scheduled"
    case completed = "completed"
    case cancelled = "cancelled"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .scheduled: return "Scheduled"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .noShow: return "No Show"
        }
    }
    
    var color: String {
        switch self {
        case .scheduled: return "Blue"
        case .completed: return "Green"
        case .cancelled: return "Red"
        case .noShow: return "Orange"
        }
    }
}

// MARK: - Booking Request
struct TutorBookingRequest: Codable {
    let tutorId: String
    let subject: String
    let startTime: Date
    let endTime: Date
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case tutorId = "tutor_id"
        case subject
        case startTime = "start_time"
        case endTime = "end_time"
        case notes
    }
}

// MARK: - Tutor Rating
struct TutorRating: Codable, Identifiable {
    let id: String
    let tutorId: String
    let studentId: String
    let sessionId: String
    var rating: Int // 1-5
    var comment: String?
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case tutorId = "tutor_id"
        case studentId = "student_id"
        case sessionId = "session_id"
        case rating
        case comment
        case createdAt = "created_at"
    }
}
