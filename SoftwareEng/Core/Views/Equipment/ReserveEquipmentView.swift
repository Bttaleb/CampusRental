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
        }
    }

    private var isValid: Bool { endTime > startTime }

    private var confirmationMessage: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Reserve \(equipment.name) from \(formatter.string(from: startTime)) to \(formatter.string(from: endTime))?"
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
}
