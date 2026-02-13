//
//  Config.swift
//  CampusBookingSystem
//
//  Configuration and Environment Variables
//

import Foundation

struct Config {
    // MARK: - API Configuration
    struct API {
        #if DEBUG
        static let baseURL = "http://localhost:3000/api"
        #else
        static let baseURL = "https://api.campusbooking.edu"
        #endif
        
        static let timeout: TimeInterval = 30
        static let maxRetries = 3
    }
    
    // MARK: - Authentication
    struct Auth {
        static let tokenKey = "auth_token"
        static let refreshTokenKey = "refresh_token"
        static let userKey = "current_user"
        
        // University SSO (if applicable)
        static let ssoEnabled = true
        static let ssoDomain = "@university.edu"
    }
    
    // MARK: - Booking Rules
    struct Booking {
        // Study Room Rules
        static let maxRoomDuration: TimeInterval = 2 * 3600 // 2 hours
        static let roomCancellationDeadline: TimeInterval = 3600 // 1 hour before
        
        // Tutor Session Rules
        static let minTutorSessionDuration: TimeInterval = 1800 // 30 minutes
        static let maxTutorSessionDuration: TimeInterval = 2 * 3600 // 2 hours
        static let tutorCancellationDeadline: TimeInterval = 24 * 3600 // 24 hours before
        
        // Equipment Rules
        static let maxEquipmentDuration: TimeInterval = 7 * 24 * 3600 // 7 days
        static let equipmentCancellationDeadline: TimeInterval = 3600 // 1 hour before
    }
    
    // MARK: - Pagination
    struct Pagination {
        static let defaultPageSize = 20
        static let maxPageSize = 100
    }
    
    // MARK: - Cache
    struct Cache {
        static let tutorsCacheDuration: TimeInterval = 300 // 5 minutes
        static let roomsCacheDuration: TimeInterval = 60 // 1 minute
        static let equipmentCacheDuration: TimeInterval = 60 // 1 minute
    }
    
    // MARK: - Notifications
    struct Notifications {
        static let reminderBeforeBooking: TimeInterval = 3600 // 1 hour before
        static let enablePushNotifications = true
    }
    
    // MARK: - Feature Flags
    struct Features {
        static let ratingsEnabled = false // Epic 7 - Stretch Goal
        static let adminPanelEnabled = true
        static let offlineMode = false
    }
}
