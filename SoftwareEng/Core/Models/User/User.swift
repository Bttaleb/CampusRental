//
//  User.swift
//  CampusBookingSystem
//
//  Epic 1.1 & 1.2: User Registration & Profile Management
//  Requirements: User account with role-based attributes
//

import Foundation

// MARK: - User Model
struct User: Codable, Identifiable {
    let id: String
    var email: String
    var name: String
    var photoURL: String?
    var phoneNumber: String?
    var role: UserRole
    
    // Student-specific fields
    var major: String?
    var year: StudentYear?
    
    // Tutor-specific fields
    var subjects: [String]?
    var hourlyRate: Double?
    var availability: [AvailabilitySlot]?
    var rating: Double?
    var totalSessions: Int?
    var bio: String?
    
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case photoURL = "photo_url"
        case phoneNumber = "phone_number"
        case role
        case major
        case year
        case subjects
        case hourlyRate = "hourly_rate"
        case availability
        case rating
        case totalSessions = "total_sessions"
        case bio
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var displayName: String {
        name.isEmpty ? email : name
    }
    
    var isStudent: Bool {
        role == .student
    }
    
    var isTutor: Bool {
        role == .tutor
    }
    
    var isAdmin: Bool {
        role == .admin
    }
}

// MARK: - User Role
enum UserRole: String, Codable, CaseIterable {
    case student = "student"
    case tutor = "tutor"
    case admin = "admin"
    
    var displayName: String {
        switch self {
        case .student: return "Student"
        case .tutor: return "Tutor"
        case .admin: return "Admin"
        }
    }
}

// MARK: - Student Year
enum StudentYear: String, Codable, CaseIterable {
    case freshman = "freshman"
    case sophomore = "sophomore"
    case junior = "junior"
    case senior = "senior"
    case graduate = "graduate"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Availability Slot
struct AvailabilitySlot: Codable, Identifiable {
    var id: String
    var dayOfWeek: DayOfWeek
    var startTime: String // Format: "HH:mm"
    var endTime: String   // Format: "HH:mm"
    var isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case dayOfWeek = "day_of_week"
        case startTime = "start_time"
        case endTime = "end_time"
        case isAvailable = "is_available"
    }
}

enum DayOfWeek: String, Codable, CaseIterable {
    case monday = "monday"
    case tuesday = "tuesday"
    case wednesday = "wednesday"
    case thursday = "thursday"
    case friday = "friday"
    case saturday = "saturday"
    case sunday = "sunday"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Registration Request
struct RegistrationRequest: Codable {
    let email: String
    let password: String
    let name: String
    let role: UserRole
    let major: String?
    let year: StudentYear?
}

// MARK: - Login Request
struct LoginRequest: Codable {
    let email: String
    let password: String
}

// MARK: - Profile Update Request
struct ProfileUpdateRequest: Codable {
    var name: String?
    var phoneNumber: String?
    var photoURL: String?
    var major: String?
    var year: StudentYear?
    var subjects: [String]?
    var hourlyRate: Double?
    var bio: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case phoneNumber = "phone_number"
        case photoURL = "photo_url"
        case major
        case year
        case subjects
        case hourlyRate = "hourly_rate"
        case bio
    }
}
