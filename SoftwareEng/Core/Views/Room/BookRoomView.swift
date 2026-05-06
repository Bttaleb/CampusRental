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
    @State private var availabilityDate: Date = .now
    @State private var availabilitySlots: [TimeSlot] = []
    @State private var isLoadingAvailability = false

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

                Section("Availability Calendar") {
                    DatePicker(
                        "Date",
                        selection: $availabilityDate,
                        in: Date()...,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)

                    if isLoadingAvailability {
                        ProgressView("Loading availability...")
                    } else if unavailableSlots.isEmpty {
                        Label("No reserved times on this date", systemImage: "checkmark.circle")
                            .foregroundColor(.green)
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Reserved / Unavailable Times")
                                .font(.subheadline.weight(.semibold))
                            ForEach(unavailableSlots) { slot in
                                Text(slot.formattedTimeRange)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
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
            .task {
                availabilityDate = startTime
                await loadAvailability()
            }
            .onChange(of: availabilityDate) { _ in
                Task { await loadAvailability() }
            }
            .onChange(of: startTime) { newValue in
                availabilityDate = newValue
            }
            .onReceive(NotificationCenter.default.publisher(for: .rentalDidCancel)) { notification in
                guard
                    let type = notification.userInfo?["type"] as? String,
                    let resourceId = notification.userInfo?["resourceId"] as? String,
                    type == "room",
                    resourceId == room.id
                else { return }
                Task { await loadAvailability() }
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

    private var unavailableSlots: [TimeSlot] {
        availabilitySlots.filter { !$0.isAvailable }
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

    private func loadAvailability() async {
        isLoadingAvailability = true
        availabilitySlots = await viewModel.checkAvailability(roomId: room.id, date: availabilityDate)
        isLoadingAvailability = false
    }
}
