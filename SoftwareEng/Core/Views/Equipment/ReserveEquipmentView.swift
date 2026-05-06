//
//  ReserveEquipmentView.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Rental
//  Sheet for creating a new equipment reservation.
//

import SwiftUI

struct ReserveEquipmentView: View {
    let equipment: Equipment
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = EquipmentViewModel()

    @State private var startTime: Date = .now.addingTimeInterval(3600)
    @State private var endTime: Date = .now.addingTimeInterval(3600 * 25)
    @State private var purpose: String = ""
    @State private var showConfirmationAlert = false
    @State private var availabilityDate: Date = .now
    @State private var availabilitySlots: [TimeSlot] = []
    @State private var isLoadingAvailability = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Equipment") {
                    LabeledContent("Name", value: equipment.name)
                    LabeledContent("Location", value: equipment.location)
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
                    TextField("Purpose (optional)", text: $purpose, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let error = viewModel.errorMessage {
                    Section {
                        Text(error).foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Reserve Equipment")
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
                            Text("Reserve")
                        }
                    }
                    .disabled(!isValid || viewModel.isLoading)
                }
            }
            .alert("Confirm Equipment Reservation", isPresented: $showConfirmationAlert) {
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
                    type == "equipment",
                    resourceId == equipment.id
                else { return }
                Task { await loadAvailability() }
            }
        }
    }

    private var isValid: Bool { endTime > startTime }

    private var confirmationMessage: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Reserve \(equipment.name) from \(formatter.string(from: startTime)) to \(formatter.string(from: endTime))?"
    }

    private var unavailableSlots: [TimeSlot] {
        availabilitySlots.filter { !$0.isAvailable }
    }

    private func submit() async {
        let trimmed = purpose.trimmingCharacters(in: .whitespacesAndNewlines)
        let success = await viewModel.reserve(
            equipmentId: equipment.id,
            startTime: startTime,
            endTime: endTime,
            purpose: trimmed.isEmpty ? nil : trimmed
        )
        if success { dismiss() }
    }

    private func loadAvailability() async {
        isLoadingAvailability = true
        availabilitySlots = await viewModel.checkAvailability(equipmentId: equipment.id, date: availabilityDate)
        isLoadingAvailability = false
    }
}
