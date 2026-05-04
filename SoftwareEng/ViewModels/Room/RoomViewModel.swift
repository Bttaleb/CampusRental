//
//  RoomViewModel.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  Handles room search, filtering, and booking management.
//

import Foundation
import SwiftUI
import Combine
// MARK: OOP - Abstraction, Polymorphism, Encapsulation
@MainActor
final class RoomViewModel: ObservableObject { // Abstraction + Polymorphism
    // MARK: - Published Properties
    @Published var rooms: [StudyRoom] = []
    @Published var selectedRoom: StudyRoom?
    @Published var myBookings: [RoomBooking] = []
    @Published var searchFilters = RoomSearchFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let roomService: RoomServiceProvider // DIP — depend on abstraction

    init(roomService: RoomServiceProvider = SupabaseRoomService()) {
        self.roomService = roomService
    }

    // MARK: - Discovery

    func fetchRooms(filters: RoomSearchFilters? = nil) async {
        isLoading = true
        errorMessage = nil
        do {
            let applied = filters ?? searchFilters
            rooms = try await roomService.search(filters: applied)
        } catch {
            errorMessage = error.localizedDescription
            print("DEBUG: Failed to fetch rooms: \(error)")
        }
        isLoading = false
    }

    func fetchRoomDetails(roomId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            selectedRoom = try await roomService.getRoom(id: roomId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    // MARK: - Booking

    func bookRoom(roomId: String, startTime: Date, endTime: Date,
                  attendees: Int, purpose: String? = nil) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let request = RoomBookingRequest(
                roomId: roomId,
                startTime: startTime,
                endTime: endTime,
                purpose: purpose,
                attendees: attendees
            )
            let booking = try await roomService.book(request: request)
            myBookings.insert(booking, at: 0)
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func fetchMyBookings() async {
        isLoading = true
        errorMessage = nil
        do {
            myBookings = try await roomService.getUserBookings()
            myBookings.sort { $0.startTime > $1.startTime }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func cancelBooking(bookingId: String) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            try await roomService.cancel(id: bookingId)
            myBookings.removeAll { $0.id == bookingId }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func rescheduleBooking(bookingId: String, newStartTime: Date, newEndTime: Date) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let updated = try await roomService.reschedule(
                id: bookingId,
                newStartTime: newStartTime,
                newEndTime: newEndTime
            )
            if let i = myBookings.firstIndex(where: { $0.id == bookingId }) {
                myBookings[i] = updated
            }
            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Filters

    func applyFilters(building: String? = nil, minCapacity: Int? = nil,
                      requiredFeatures: [RoomFeature]? = nil,
                      sortBy: RoomSortOption? = nil) {
        if let building = building { searchFilters.building = building }
        if let minCapacity = minCapacity { searchFilters.minCapacity = minCapacity }
        if let requiredFeatures = requiredFeatures { searchFilters.requiredFeatures = requiredFeatures }
        if let sortBy = sortBy { searchFilters.sortBy = sortBy }
        Task { await fetchRooms() }
    }

    func clearFilters() {
        searchFilters = RoomSearchFilters()
        Task { await fetchRooms() }
    }

    // MARK: - Computed

    var upcomingBookings: [RoomBooking] {
        myBookings.filter { $0.status == .confirmed && $0.startTime > Date() }
    }

    var pastBookings: [RoomBooking] {
        myBookings.filter { $0.endTime < Date() }
    }

    var availableBuildings: [String] {
        Array(Set(rooms.map { $0.building })).sorted()
    }
}
