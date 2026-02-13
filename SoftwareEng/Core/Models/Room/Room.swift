//
//  Room.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  Requirements: Room listing, availability, and reservation management
//

import Foundation

// MARK: - Study Room
struct StudyRoom: Codable, Identifiable {
    let id: String
    var name: String
    var building: String
    var floor: Int
    var roomNumber: String
    var capacity: Int
    var features: [RoomFeature]
    var imageURL: String?
    var isAvailable: Bool
    var description: String?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case building
        case floor
        case roomNumber = "room_number"
        case capacity
        case features
        case imageURL = "image_url"
        case isAvailable = "is_available"
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    var fullName: String {
        "\(building) - Room \(roomNumber)"
    }
    
    var location: String {
        "\(building), Floor \(floor)"
    }
    
    var featuresDisplay: String {
        features.map { $0.displayName }.joined(separator: ", ")
    }
}

// MARK: - Room Features
enum RoomFeature: String, Codable, CaseIterable {
    case whiteboard = "whiteboard"
    case projector = "projector"
    case tvScreen = "tv_screen"
    case computer = "computer"
    case wifi = "wifi"
    case airConditioning = "air_conditioning"
    case windows = "windows"
    case powerOutlets = "power_outlets"
    
    var displayName: String {
        switch self {
        case .whiteboard: return "Whiteboard"
        case .projector: return "Projector"
        case .tvScreen: return "TV Screen"
        case .computer: return "Computer"
        case .wifi: return "WiFi"
        case .airConditioning: return "A/C"
        case .windows: return "Windows"
        case .powerOutlets: return "Power Outlets"
        }
    }
    
    var icon: String {
        switch self {
        case .whiteboard: return "pencil.and.outline"
        case .projector: return "projector"
        case .tvScreen: return "tv"
        case .computer: return "desktopcomputer"
        case .wifi: return "wifi"
        case .airConditioning: return "snow"
        case .windows: return "sun.max"
        case .powerOutlets: return "bolt.fill"
        }
    }
}

// MARK: - Room Booking
struct RoomBooking: Codable, Identifiable {
    let id: String
    let roomId: String
    let userId: String
    var room: StudyRoom?
    var user: User?
    var startTime: Date
    var endTime: Date
    var purpose: String?
    var attendees: Int
    var status: BookingStatus
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case roomId = "room_id"
        case userId = "user_id"
        case room
        case user
        case startTime = "start_time"
        case endTime = "end_time"
        case purpose
        case attendees
        case status
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
    
    var canCancel: Bool {
        status == .confirmed && startTime.timeIntervalSinceNow > Config.Booking.roomCancellationDeadline
    }
    
    var isUpcoming: Bool {
        status == .confirmed && startTime > Date()
    }
    
    var isPast: Bool {
        endTime < Date()
    }
}

// MARK: - Room Search Filters
struct RoomSearchFilters {
    var building: String?
    var minCapacity: Int?
    var requiredFeatures: [RoomFeature] = []
    var date: Date?
    var startTime: Date?
    var endTime: Date?
    var sortBy: RoomSortOption = .name
    
    var queryParameters: [String: String] {
        var params: [String: String] = [:]
        
        if let building = building {
            params["building"] = building
        }
        if let minCapacity = minCapacity {
            params["min_capacity"] = String(minCapacity)
        }
        if !requiredFeatures.isEmpty {
            params["features"] = requiredFeatures.map { $0.rawValue }.joined(separator: ",")
        }
        if let date = date {
            let formatter = ISO8601DateFormatter()
            params["date"] = formatter.string(from: date)
        }
        if let startTime = startTime {
            let formatter = ISO8601DateFormatter()
            params["start_time"] = formatter.string(from: startTime)
        }
        if let endTime = endTime {
            let formatter = ISO8601DateFormatter()
            params["end_time"] = formatter.string(from: endTime)
        }
        params["sort_by"] = sortBy.rawValue
        
        return params
    }
}

enum RoomSortOption: String, CaseIterable {
    case name = "name"
    case capacity = "capacity"
    case building = "building"
    
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - Room Booking Request
struct RoomBookingRequest: Codable {
    let roomId: String
    let startTime: Date
    let endTime: Date
    var purpose: String?
    var attendees: Int
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case purpose
        case attendees
    }
}

// MARK: - Room Availability
struct RoomAvailability: Codable {
    let roomId: String
    let date: Date
    var availableSlots: [TimeSlot]
    
    enum CodingKeys: String, CodingKey {
        case roomId = "room_id"
        case date
        case availableSlots = "available_slots"
    }
}

struct TimeSlot: Codable, Identifiable {
    var id: String { "\(startTime.timeIntervalSince1970)" }
    let startTime: Date
    let endTime: Date
    var isAvailable: Bool
    
    enum CodingKeys: String, CodingKey {
        case startTime = "start_time"
        case endTime = "end_time"
        case isAvailable = "is_available"
    }
    
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}
