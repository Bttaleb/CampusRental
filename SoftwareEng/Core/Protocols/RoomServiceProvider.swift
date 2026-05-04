//
//  RoomServiceProvider.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  Abstract contract for room service implementations.
//

import Foundation
// MARK: OOP - Abstraction, Encapsulation

protocol RoomServiceProvider { // Abstraction — hides concrete room backend (Supabase, mock, REST, etc.)

    // MARK: - Discovery
    func search(filters: RoomSearchFilters) async throws -> [StudyRoom]
    func getRoom(id: String) async throws -> StudyRoom

    // MARK: - Booking Management
    func book(request: RoomBookingRequest) async throws -> RoomBooking
    func getUserBookings() async throws -> [RoomBooking]
    func cancel(id: String) async throws
    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> RoomBooking

    // MARK: - Availability
    func getAvailability(roomId: String, date: Date) async throws -> [TimeSlot]

    // MARK: - Ratings
    func rate(roomId: String, rating: Int, comment: String?) async throws
}
