//
//  Rentable.swift
//  CampusBookingSystem
//
//  Shared rental contract across tutor sessions, room bookings,
//  and equipment reservations.
//

import Foundation
//MARK: OOP - Abstraction, Polymorphism

// MARK: - Rentable Protocol
protocol Rentable: Identifiable { // Abstraction + Polymorphism
    var startTime: Date { get }
    var endTime: Date { get }
    var createdAt: Date { get }
    var updatedAt: Date { get }
    var canCancel: Bool { get }           // Polymorphism — each type checks its own status + deadline
    var canReschedule: Bool { get }       // Polymorphism — defaults to canCancel, overridable
    var isUpcoming: Bool { get }          // Polymorphism — each type checks its own status enum
    var formattedDuration: String { get } // Polymorphism — rooms use hours, equipment uses days
    var displayTitle: String { get }      // Polymorphism — what the unified rentals row shows

    func cancel() async throws
    func reschedule(to start: Date, end: Date) async throws -> Self
}

// MARK: - Default Implementations
extension Rentable { // Abstraction — shared logic defined once, inherited by all conformers

    /// Elapsed time between start and end
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }

    /// Whether the booking window has fully passed
    var isPast: Bool {
        endTime < Date()
    }

    /// Formatted time range string shared across all rental types
    var formattedTimeRange: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return "\(formatter.string(from: startTime)) - \(formatter.string(from: endTime))"
    }

    /// Default: same window as cancellation. Override per type if policies diverge.
    var canReschedule: Bool { canCancel }
}

// MARK: - Errors
enum RentableError: LocalizedError {
    case serviceUnavailable
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .serviceUnavailable: return "Rental service is not configured."
        case .notImplemented:     return "This rental action is not implemented yet."
        }
    }
}

// MARK: - Service Registry
/// Composition root for rental services. Wired once at app startup so
/// `Rentable` value types can route `cancel()` / `reschedule(...)` to the
/// correct backend without holding a non-Codable service reference.
final class RentalServices {
    static let shared = RentalServices()
    var tutor: TutorServiceProvider?
    var room: RoomServiceProvider?
    // Equipment service not yet implemented; slot reserved.
    private init() {}
}
