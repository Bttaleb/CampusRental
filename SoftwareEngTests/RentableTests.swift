//
//  RentableTests.swift
//  SoftwareEngTests
//
//  Verifies the shared Rentable protocol contract and that default
//  implementations are picked up by all three conformers.
//

import Testing
import Foundation
@testable import SoftwareEng

struct RentableTests {

    // MARK: - Helpers

    private func makeTutorSession(
        start: Date,
        end: Date,
        status: SessionStatus = .scheduled
    ) -> TutorSession {
        TutorSession(
            id: "s1",
            tutorId: "t1",
            studentId: "u1",
            tutor: nil,
            student: nil,
            subject: "Calculus",
            startTime: start,
            endTime: end,
            status: status,
            notes: nil,
            meetingLink: nil,
            createdAt: start,
            updatedAt: start
        )
    }

    private func makeRoomBooking(
        start: Date,
        end: Date,
        status: BookingStatus = .confirmed
    ) -> RoomBooking {
        RoomBooking(
            id: "r1",
            roomId: "rm1",
            userId: "u1",
            room: nil,
            user: nil,
            startTime: start,
            endTime: end,
            purpose: nil,
            attendees: 1,
            status: status,
            createdAt: start,
            updatedAt: start
        )
    }

    private func makeEquipmentReservation(
        start: Date,
        end: Date,
        status: BookingStatus = .confirmed
    ) -> EquipmentReservation {
        EquipmentReservation(
            id: "e1",
            equipmentId: "eq1",
            userId: "u1",
            equipment: nil,
            user: nil,
            startTime: start,
            endTime: end,
            purpose: nil,
            status: status,
            checkedOutAt: nil,
            returnedAt: nil,
            notes: nil,
            createdAt: start,
            updatedAt: start
        )
    }

    // MARK: - duration default impl

    @Test func durationMatchesEndMinusStartForAllTypes() {
        let start = Date()
        let end = start.addingTimeInterval(3600)

        let s = makeTutorSession(start: start, end: end)
        let r = makeRoomBooking(start: start, end: end)
        let e = makeEquipmentReservation(start: start, end: end)

        #expect(s.duration == 3600)
        #expect(r.duration == 3600)
        #expect(e.duration == 3600)
    }

    // MARK: - isPast default impl

    @Test func isPastFlipsAtBoundary() {
        let pastEnd = Date().addingTimeInterval(-60)
        let futureEnd = Date().addingTimeInterval(60)

        let pastSession = makeTutorSession(
            start: pastEnd.addingTimeInterval(-3600),
            end: pastEnd
        )
        let futureSession = makeTutorSession(
            start: futureEnd.addingTimeInterval(-3600),
            end: futureEnd
        )

        #expect(pastSession.isPast)
        #expect(!futureSession.isPast)
    }

    // MARK: - canCancel respects per-type deadline

    @Test func canCancelRespectsTutorDeadline() {
        let aheadOfDeadline = Date().addingTimeInterval(
            Config.Booking.tutorCancellationDeadline + 600
        )
        let session = makeTutorSession(
            start: aheadOfDeadline,
            end: aheadOfDeadline.addingTimeInterval(3600)
        )
        #expect(session.canCancel)

        let tooLate = Date().addingTimeInterval(
            Config.Booking.tutorCancellationDeadline - 600
        )
        let lateSession = makeTutorSession(
            start: tooLate,
            end: tooLate.addingTimeInterval(3600)
        )
        #expect(!lateSession.canCancel)
    }

    // MARK: - cancel() routes through RentalServices

    @Test func tutorSessionCancelInvokesRegisteredService() async throws {
        final class RecordingTutorService: TutorServiceProvider {
            var cancelledIds: [String] = []
            func searchTutors(filters: TutorSearchFilters) async throws -> [TutorProfile] { [] }
            func getTutorProfile(id: String) async throws -> TutorProfile {
                throw NSError(domain: "test", code: 0)
            }
            func bookSession(request: TutorBookingRequest) async throws -> TutorSession {
                throw NSError(domain: "test", code: 0)
            }
            func getUserSessions() async throws -> [TutorSession] { [] }
            func cancelSession(id: String) async throws { cancelledIds.append(id) }
            func rescheduleSession(id: String, newStartTime: Date, newEndTime: Date) async throws -> TutorSession {
                throw NSError(domain: "test", code: 0)
            }
            func getTutorAvailability(tutorId: String, date: Date) async throws -> [TimeSlot] { [] }
            func rateSession(sessionId: String, rating: Int, comment: String?) async throws {}
        }

        let recorder = RecordingTutorService()
        let previous = RentalServices.shared.tutor
        RentalServices.shared.tutor = recorder
        defer { RentalServices.shared.tutor = previous }

        let session = makeTutorSession(
            start: Date().addingTimeInterval(7200),
            end: Date().addingTimeInterval(10800)
        )
        try await session.cancel()

        #expect(recorder.cancelledIds == [session.id])
    }

    @Test func cancelThrowsWhenServiceMissing() async {
        let previous = RentalServices.shared.tutor
        RentalServices.shared.tutor = nil
        defer { RentalServices.shared.tutor = previous }

        let session = makeTutorSession(
            start: Date().addingTimeInterval(7200),
            end: Date().addingTimeInterval(10800)
        )
        await #expect(throws: RentableError.self) {
            try await session.cancel()
        }
    }
}
