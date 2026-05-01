//
//  Bookable.swift
//  CampusBookingSystem
//
//  Epic 2-4: Tutor, Room & Equipment Booking
//  Requirements: Shared contract for all booking and reservation types
//

import Foundation
//MARK: OOP - Abstraction, Polymorphism

// MARK: - Bookable Protocol
protocol Bookable: Identifiable { // Abstraction + Polymorphism
    var startTime: Date { get }
    var endTime: Date { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var canCancel: Bool { get }    // Polymorphism - each type checks its own status + deadline
    var isUpcoming: Bool { get }  // Polymorphism - each type checks its own status enum
    var formattedDuration: String { get } // Polymorphism - rooms use hours, equipment uses days
}

// MARK: - Default Implementations
extension Bookable { // Abstraction - shared logic defined once, inherited by all conformers

    /// Elapsed time between start and end
    var duration: TimeInterval { // Abstraction - hides timeIntervalSince calculation
        endTime.timeIntervalSince(startTime)
    }

    /// Whether the booking window has fully passed
    var isPast: Bool { // Abstraction - hides date comparison
        endTime < Date()
    }

    /// Formatted time range string shared across all booking types
    var formattedTimeRange: String { // Abstraction - hides DateFormatter setup
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }
}
