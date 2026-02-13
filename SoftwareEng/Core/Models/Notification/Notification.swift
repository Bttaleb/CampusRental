//
//  Notification.swift
//  CampusBookingSystem
//
//  Epic 5: Notifications
//  Requirements: Push notifications for bookings, reminders, and updates
//

import Foundation

// MARK: - Notification Model
struct AppNotification: Codable, Identifiable {
    let id: String
    let userId: String
    var type: NotificationType
    var title: String
    var message: String
    var data: [String: String]?
    var isRead: Bool
    var createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case type
        case title
        case message
        case data
        case isRead = "is_read"
        case createdAt = "created_at"
    }
    
    var icon: String {
        type.icon
    }
    
    var color: String {
        type.color
    }
    
    var formattedTime: String {
        let now = Date()
        let interval = now.timeIntervalSince(createdAt)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

// MARK: - Notification Type
enum NotificationType: String, Codable {
    case bookingConfirmed = "booking_confirmed"
    case bookingCancelled = "booking_cancelled"
    case bookingReminder = "booking_reminder"
    case bookingRescheduled = "booking_rescheduled"
    case equipmentDue = "equipment_due"
    case equipmentOverdue = "equipment_overdue"
    case tutorAvailable = "tutor_available"
    case roomAvailable = "room_available"
    case adminApproval = "admin_approval"
    case ratingRequest = "rating_request"
    case systemUpdate = "system_update"
    
    var displayName: String {
        switch self {
        case .bookingConfirmed: return "Booking Confirmed"
        case .bookingCancelled: return "Booking Cancelled"
        case .bookingReminder: return "Booking Reminder"
        case .bookingRescheduled: return "Booking Rescheduled"
        case .equipmentDue: return "Equipment Due"
        case .equipmentOverdue: return "Equipment Overdue"
        case .tutorAvailable: return "Tutor Available"
        case .roomAvailable: return "Room Available"
        case .adminApproval: return "Admin Approval"
        case .ratingRequest: return "Rating Request"
        case .systemUpdate: return "System Update"
        }
    }
    
    var icon: String {
        switch self {
        case .bookingConfirmed: return "checkmark.circle.fill"
        case .bookingCancelled: return "xmark.circle.fill"
        case .bookingReminder: return "bell.fill"
        case .bookingRescheduled: return "calendar.badge.clock"
        case .equipmentDue: return "exclamationmark.triangle.fill"
        case .equipmentOverdue: return "exclamationmark.circle.fill"
        case .tutorAvailable: return "person.fill.checkmark"
        case .roomAvailable: return "building.2.fill"
        case .adminApproval: return "checkmark.shield.fill"
        case .ratingRequest: return "star.fill"
        case .systemUpdate: return "info.circle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .bookingConfirmed: return "Green"
        case .bookingCancelled: return "Red"
        case .bookingReminder: return "Blue"
        case .bookingRescheduled: return "Orange"
        case .equipmentDue: return "Yellow"
        case .equipmentOverdue: return "Red"
        case .tutorAvailable: return "Green"
        case .roomAvailable: return "Green"
        case .adminApproval: return "Purple"
        case .ratingRequest: return "Yellow"
        case .systemUpdate: return "Blue"
        }
    }
}

// MARK: - Notification Preferences
struct NotificationPreferences: Codable {
    var pushEnabled: Bool
    var emailEnabled: Bool
    var bookingConfirmations: Bool
    var bookingReminders: Bool
    var cancellations: Bool
    var availabilityAlerts: Bool
    var adminMessages: Bool
    var ratingRequests: Bool
    
    enum CodingKeys: String, CodingKey {
        case pushEnabled = "push_enabled"
        case emailEnabled = "email_enabled"
        case bookingConfirmations = "booking_confirmations"
        case bookingReminders = "booking_reminders"
        case cancellations
        case availabilityAlerts = "availability_alerts"
        case adminMessages = "admin_messages"
        case ratingRequests = "rating_requests"
    }
    
    static var `default`: NotificationPreferences {
        NotificationPreferences(
            pushEnabled: true,
            emailEnabled: true,
            bookingConfirmations: true,
            bookingReminders: true,
            cancellations: true,
            availabilityAlerts: true,
            adminMessages: true,
            ratingRequests: true
        )
    }
}

// MARK: - Push Notification Payload
struct PushNotificationPayload: Codable {
    let title: String
    let body: String
    let badge: Int?
    let sound: String?
    let data: [String: String]?
    
    init(title: String, body: String, badge: Int? = nil, sound: String? = "default", data: [String: String]? = nil) {
        self.title = title
        self.body = body
        self.badge = badge
        self.sound = sound
        self.data = data
    }
}
