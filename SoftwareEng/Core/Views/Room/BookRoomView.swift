//
//  BookRoomView.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//  Sheet for creating a new room booking.
//

import SwiftUI

struct BookRoomView: View {
    let room: StudyRoom
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = RoomViewModel()

    @State private var startTime: Date = .now.addingTimeInterval(3600)
    @State private var endTime: Date = .now.addingTimeInterval(7200)
    @State private var attendees: Int = 1
    @State private var purpose: String = ""
    @State private var showConfirmationAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Room") {
                    LabeledContent("Name", value: room.fullName)
                    LabeledContent("Capacity", value: "\(room.capacity)")
                }

                Section("When") {
                    DatePicker("Start", selection: $startTime, in: Date()...)
                    DatePicker("End", selection: $endTime, in: startTime...)
                }

                Section("Details") {
                    Stepper("Attendees: \(attendees)", value: $attendees, in: 1...room.capacity)
                    TextField("Purpose (optional)", text: $purpose, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Book Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        showConfirmationAlert = true
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text("Book")
                        }
                    }
                    .disabled(!isValid || viewModel.isLoading)
                }
            }
            .alert("Confirm Room Booking", isPresented: $showConfirmationAlert) {
                Button("Confirm") {
                    Task { await submit() }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(confirmationMessage)
            }
        }
    }

    private var isValid: Bool {
        endTime > startTime && attendees >= 1 && attendees <= room.capacity
    }

    private var confirmationMessage: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Book \(room.fullName) for \(attendees) attendee\(attendees > 1 ? "s" : "") from \(formatter.string(from: startTime)) to \(formatter.string(from: endTime))?"
    }

    private func submit() async {
        let purposeValue = purpose.trimmingCharacters(in: .whitespacesAndNewlines)
        let success = await viewModel.bookRoom(
            roomId: room.id,
            startTime: startTime,
            endTime: endTime,
            attendees: attendees,
            purpose: purposeValue.isEmpty ? nil : purposeValue
        )
        if success { dismiss() }
    }
}
