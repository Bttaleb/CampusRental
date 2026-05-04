//
//  RoomTests.swift
//  SoftwareEngTests
//
//  Exercises MockRoomService directly and through RoomViewModel.
//  Uses Swift Testing (Xcode 16+).
//

import Testing
import Foundation
@testable import SoftwareEng

@MainActor
struct RoomTests {

    // MARK: - Search filtering

    @Test func searchReturnsAllRoomsByDefault() async throws {
        let service = MockRoomService()
        let result = try await service.search(filters: RoomSearchFilters())
        #expect(result.count == 3)
    }

    @Test func searchFiltersByBuilding() async throws {
        let service = MockRoomService()
        var filters = RoomSearchFilters()
        filters.building = "Library"
        let result = try await service.search(filters: filters)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.building == "Library" })
    }

    @Test func searchFiltersByMinCapacity() async throws {
        let service = MockRoomService()
        var filters = RoomSearchFilters()
        filters.minCapacity = 6
        let result = try await service.search(filters: filters)
        #expect(result.allSatisfy { $0.capacity >= 6 })
    }

    @Test func searchRequiresAllFeatures() async throws {
        let service = MockRoomService()
        var filters = RoomSearchFilters()
        filters.requiredFeatures = [.projector, .computer]
        let result = try await service.search(filters: filters)
        // Only the conference room has both projector AND computer.
        #expect(result.count == 1)
        #expect(result.first?.id == "room-2")
    }

    @Test func searchSortsByCapacityAscending() async throws {
        let service = MockRoomService()
        var filters = RoomSearchFilters()
        filters.sortBy = .capacity
        let result = try await service.search(filters: filters)
        let capacities = result.map { $0.capacity }
        #expect(capacities == capacities.sorted())
    }

    // MARK: - Booking lifecycle

    @Test func bookCreatesConfirmedBooking() async throws {
        let service = MockRoomService()
        let request = RoomBookingRequest(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(3600),
            endTime:   Date().addingTimeInterval(7200),
            purpose: "Group study",
            attendees: 4
        )
        let booking = try await service.book(request: request)
        #expect(booking.status == .confirmed)
        #expect(booking.roomId == "room-1")
        #expect(booking.attendees == 4)
    }

    @Test func cancelMarksBookingAsCancelled() async throws {
        let service = MockRoomService()
        let request = RoomBookingRequest(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(7200),
            endTime: Date().addingTimeInterval(10800),
            purpose: nil,
            attendees: 2
        )
        let booking = try await service.book(request: request)

        try await service.cancel(id: booking.id)

        let bookings = try await service.getUserBookings()
        let cancelled = bookings.first { $0.id == booking.id }
        #expect(cancelled?.status == .cancelled)
    }

    @Test func rescheduleUpdatesBookingTimes() async throws {
        let service = MockRoomService()
        let request = RoomBookingRequest(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            purpose: nil,
            attendees: 2
        )
        let original = try await service.book(request: request)

        let newStart = Date().addingTimeInterval(86_400)
        let newEnd   = newStart.addingTimeInterval(3600)
        let rescheduled = try await service.reschedule(
            id: original.id,
            newStartTime: newStart,
            newEndTime: newEnd
        )

        #expect(rescheduled.startTime == newStart)
        #expect(rescheduled.endTime   == newEnd)
    }

    // MARK: - RoomViewModel integration

    @Test func viewModelFetchPopulatesRooms() async {
        let vm = RoomViewModel(roomService: MockRoomService())
        await vm.fetchRooms()
        #expect(vm.rooms.count == 3)
        #expect(vm.errorMessage == nil)
    }

    @Test func viewModelBookAddsToMyBookings() async {
        let vm = RoomViewModel(roomService: MockRoomService())
        let success = await vm.bookRoom(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            attendees: 2,
            purpose: "Test"
        )
        #expect(success)
        #expect(vm.myBookings.count == 1)
        #expect(vm.myBookings.first?.roomId == "room-1")
    }

    @Test func viewModelCancelRemovesFromMyBookings() async {
        let vm = RoomViewModel(roomService: MockRoomService())
        _ = await vm.bookRoom(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            attendees: 2,
            purpose: nil
        )
        let bookingId = vm.myBookings.first!.id

        let success = await vm.cancelBooking(bookingId: bookingId)
        #expect(success)
        #expect(vm.myBookings.isEmpty)
    }

    // MARK: - Rentable conformance via service registry

    @Test func roomBookingCancelRoutesThroughRegistry() async throws {
        let service = MockRoomService()
        let request = RoomBookingRequest(
            roomId: "room-1",
            startTime: Date().addingTimeInterval(3600),
            endTime: Date().addingTimeInterval(7200),
            purpose: nil,
            attendees: 1
        )
        let booking = try await service.book(request: request)

        let previous = RentalServices.shared.room
        RentalServices.shared.room = service
        defer { RentalServices.shared.room = previous }

        try await booking.cancel()

        let after = try await service.getUserBookings()
        #expect(after.first { $0.id == booking.id }?.status == .cancelled)
    }

    @Test func roomBookingCancelThrowsWhenServiceMissing() async {
        let booking = RoomBooking(
            id: "x", roomId: "room-1", userId: "u",
            room: nil, user: nil,
            startTime: Date().addingTimeInterval(7200),
            endTime: Date().addingTimeInterval(10800),
            purpose: nil, attendees: 1, status: .confirmed,
            createdAt: .now, updatedAt: .now
        )

        let previous = RentalServices.shared.room
        RentalServices.shared.room = nil
        defer { RentalServices.shared.room = previous }

        await #expect(throws: RentableError.self) {
            try await booking.cancel()
        }
    }
}
