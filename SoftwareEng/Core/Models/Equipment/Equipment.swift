//
//  Equipment.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Booking
//  Requirements: Equipment listing, availability, and reservation management
//

import Foundation

// MARK: - Equipment
struct Equipment: Codable, Identifiable {
    let id: String
    var name: String
    var category: EquipmentCategory
    var description: String?
    var imageURL: String?
    var serialNumber: String?
    var location: String
    var isAvailable: Bool
    var condition: EquipmentCondition
    var specifications: [String: String]?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case description
        case imageURL = "image_url"
        case serialNumber = "serial_number"
        case location
        case isAvailable = "is_available"
        case condition
        case specifications
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var statusDisplay: String {
        isAvailable ? "Available" : "In Use"
    }
    
    var statusColor: String {
        isAvailable ? "Green" : "Red"
    }
}

// MARK: - Equipment Category
enum EquipmentCategory: String, Codable, CaseIterable {
    case laptop = "laptop"
    case camera = "camera"
    case calculator = "calculator"
    case projector = "projector"
    case tablet = "tablet"
    case microphone = "microphone"
    case headphones = "headphones"
    case charger = "charger"
    case other = "other"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .laptop: return "laptopcomputer"
        case .camera: return "camera"
        case .calculator: return "number.square"
        case .projector: return "projector"
        case .tablet: return "ipad"
        case .microphone: return "mic"
        case .headphones: return "headphones"
        case .charger: return "battery.100.bolt"
        case .other: return "cube.box"
        }
    }
}

// MARK: - Equipment Condition
enum EquipmentCondition: String, Codable {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case poor = "poor"
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var color: String {
        switch self {
        case .excellent: return "Green"
        case .good: return "Blue"
        case .fair: return "Orange"
        case .poor: return "Red"
        }
    }
}

// MARK: - Equipment Reservation
struct EquipmentReservation: Codable, Identifiable {
    let id: String
    let equipmentId: String
    let userId: String
    var equipment: Equipment?
    var user: User?
    var startTime: Date
    var endTime: Date
    var purpose: String?
    var status: BookingStatus
    var checkedOutAt: Date?
    var returnedAt: Date?
    var notes: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case equipmentId = "equipment_id"
        case userId = "user_id"
        case equipment
        case user
        case startTime = "start_time"
        case endTime = "end_time"
        case purpose
        case status
        case checkedOutAt = "checked_out_at"
        case returnedAt = "returned_at"
        case notes
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let days = Int(duration) / 86400
        if days > 0 {
            return "\(days) day\(days > 1 ? "s" : "")"
        }
        let hours = Int(duration) / 3600
        return "\(hours) hour\(hours > 1 ? "s" : "")"
    }
    
    var formattedDateRange: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
    
    var canReturn: Bool {
        status == .confirmed && checkedOutAt != nil && returnedAt == nil
    }
    
    var canCancel: Bool {
        status == .confirmed && startTime.timeIntervalSinceNow > Config.Booking.equipmentCancellationDeadline
    }
    
    var isOverdue: Bool {
        status == .confirmed && endTime < Date() && returnedAt == nil
    }
    
    var isActive: Bool {
        status == .confirmed && checkedOutAt != nil && returnedAt == nil
    }
}

// MARK: - Equipment Search Filters
struct EquipmentSearchFilters {
    var category: EquipmentCategory?
    var location: String?
    var availableOnly: Bool = true
    var condition: EquipmentCondition?
    var searchQuery: String?
    var sortBy: EquipmentSortOption = .name
    
    var queryParameters: [String: String] {
        var params: [String: String] = [:]
        
        if let category = category {
            params["category"] = category.rawValue
        }
        if let location = location {
            params["location"] = location
        }
        if availableOnly {
            params["available_only"] = "true"
        }
        if let condition = condition {
            params["condition"] = condition.rawValue
        }
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            params["search"] = searchQuery
        }
        params["sort_by"] = sortBy.rawValue
        
        return params
    }
}

enum EquipmentSortOption: String, CaseIterable {
    case name = "name"
    case category = "category"
    case location = "location"
    case condition = "condition"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Equipment Reservation Request
struct EquipmentReservationRequest: Codable {
    let equipmentId: String
    let startTime: Date
    let endTime: Date
    var purpose: String?
    
    enum CodingKeys: String, CodingKey {
        case equipmentId = "equipment_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case purpose
    }
}

// MARK: - Equipment Return Request
struct EquipmentReturnRequest: Codable {
    let reservationId: String
    var condition: EquipmentCondition
    var notes: String?
    
    enum CodingKeys: String, CodingKey {
        case reservationId = "reservation_id"
        case condition
        case notes
    }
}
