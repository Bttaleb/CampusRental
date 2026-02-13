//
//  Booking.swift
//  CampusBookingSystem
//
//  Shared booking models and status definitions
//

import Foundation
import SwiftUI
import Combine
// MARK: - Booking Status
enum BookingStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case cancelled = "cancelled"
    case completed = "completed"
    case noShow = "no_show"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .cancelled: return "Cancelled"
        case .completed: return "Completed"
        case .noShow: return "No Show"
        }
    }
    
    var color: Color {
        switch self {
        case .pending: return ColorTheme.statusPending
        case .confirmed: return ColorTheme.statusConfirmed
        case .cancelled: return ColorTheme.statusCancelled
        case .completed: return ColorTheme.statusCompleted
        case .noShow: return ColorTheme.statusNoShow
        }
    }

    var badgeStyle: BadgeStyle {
        switch self {
        case .pending: return .pending
        case .confirmed: return .confirmed
        case .cancelled: return .cancelled
        case .completed: return .completed
        case .noShow: return .noShow
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .cancelled: return "xmark.circle"
        case .completed: return "checkmark.circle.fill"
        case .noShow: return "questionmark.circle"
        }
    }
}

// MARK: - Booking Type
enum BookingType: String, Codable {
    case tutor = "tutor"
    case room = "room"
    case equipment = "equipment"
    
    var displayName: String {
        switch self {
        case .tutor: return "Tutor Session"
        case .room: return "Study Room"
        case .equipment: return "Equipment"
        }
    }
    
    var icon: String {
        switch self {
        case .tutor: return "person.2"
        case .room: return "building.2"
        case .equipment: return "laptopcomputer"
        }
    }
}

// MARK: - Unified Booking (for user's booking history)
struct UnifiedBooking: Identifiable {
    let id: String
    let type: BookingType
    let title: String
    let subtitle: String
    let startTime: Date
    let endTime: Date
    let status: BookingStatus
    let imageURL: String?
    
    // Reference to original booking
    var tutorSession: TutorSession?
    var roomBooking: RoomBooking?
    var equipmentReservation: EquipmentReservation?
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: startTime)
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var isUpcoming: Bool {
        status == .confirmed && startTime > Date()
    }
    
    var isPast: Bool {
        endTime < Date()
    }
    
    var canCancel: Bool {
        guard status == .confirmed else { return false }
        
        switch type {
        case .tutor:
            return startTime.timeIntervalSinceNow > Config.Booking.tutorCancellationDeadline
        case .room:
            return startTime.timeIntervalSinceNow > Config.Booking.roomCancellationDeadline
        case .equipment:
            return startTime.timeIntervalSinceNow > Config.Booking.equipmentCancellationDeadline
        }
    }
}

// MARK: - Cancellation Request
struct CancellationRequest: Codable {
    let bookingId: String
    let bookingType: BookingType
    var reason: String?
    
    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case bookingType = "booking_type"
        case reason
    }
}

// MARK: - Reschedule Request
struct RescheduleRequest: Codable {
    let bookingId: String
    let bookingType: BookingType
    let newStartTime: Date
    let newEndTime: Date
    var reason: String?
    
    enum CodingKeys: String, CodingKey {
        case bookingId = "booking_id"
        case bookingType = "booking_type"
        case newStartTime = "new_start_time"
        case newEndTime = "new_end_time"
        case reason
    }
}

// MARK: - Booking Summary (for dashboard)
struct BookingSummary {
    var upcomingCount: Int
    var completedCount: Int
    var cancelledCount: Int
    var upcomingBookings: [UnifiedBooking]
    
    enum CodingKeys: String, CodingKey {
        case upcomingCount = "upcoming_count"
        case completedCount = "completed_count"
        case cancelledCount = "cancelled_count"
        case upcomingBookings = "upcoming_bookings"
    }
}
