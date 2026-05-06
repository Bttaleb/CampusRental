//
//  TutorDetailView.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking — detail screen + booking form.
//

import SwiftUI

struct TutorDetailView: View {
    // MARK: - Inputs
    let tutor: TutorProfile

    // MARK: - State
    @StateObject private var viewModel = TutorViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSubject: String = ""
    @State private var startTime: Date = Date().addingTimeInterval(60 * 60)   // +1h
    @State private var durationHours: Double = 1
    @State private var notes: String = ""
    @State private var showSuccessAlert = false
    @State private var showConfirmationAlert = false
    @State private var availabilityDate: Date = .now
    @State private var availabilitySlots: [TimeSlot] = []
    @State private var isLoadingAvailability = false

    // MARK: - Derived
    private var endTime: Date {
        startTime.addingTimeInterval(durationHours * 3600)
    }

    private var canBook: Bool {
        !selectedSubject.isEmpty && endTime > startTime && !viewModel.isLoading
    }

    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.lg) {
                header
                bioSection
                availabilityCalendar
                bookingForm
                bookButton
            }
            .padding(Spacing.md)
        }
        .background(ColorTheme.background)
        .navigationTitle(tutor.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if selectedSubject.isEmpty {
                selectedSubject = tutor.subjects.first ?? ""
            }
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
                type == "tutor",
                resourceId == tutor.id
            else { return }
            Task { await loadAvailability() }
        }
        .alert("Session Booked", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Your session with \(tutor.name) is scheduled.")
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    // MARK: - Subviews

    private var header: some View {
        HStack(spacing: Spacing.md) {
            Circle()
                .fill(ColorTheme.wsuGreen.opacity(0.2))
                .frame(width: 72, height: 72)
                .overlay {
                    Text(tutor.name.prefix(1).uppercased())
                        .font(.title)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.wsuGreen)
                }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(tutor.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.textPrimary)

                HStack(spacing: Spacing.xs) {
                    Label(tutor.ratingDisplay, systemImage: "star.fill")
                        .foregroundColor(ColorTheme.wsuGold)
                    Text("• \(tutor.totalSessions) sessions")
                        .foregroundColor(ColorTheme.textSecondary)
                }
                .font(.subheadline)

                Text(tutor.formattedRate)
                    .font(.headline)
                    .foregroundColor(ColorTheme.wsuGreen)
            }
            Spacer()
        }
    }

    private var bioSection: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("About")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
            Text(tutor.bio.isEmpty ? "No bio yet." : tutor.bio)
                .font(.body)
                .foregroundColor(ColorTheme.textSecondary)
        }
    }

    private var bookingForm: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Book a Session")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

            // Subject — data-driven Picker over tutor.subjects
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Subject").font(.subheadline).foregroundColor(ColorTheme.textSecondary)
                Picker("Subject", selection: $selectedSubject) {
                    ForEach(tutor.subjects, id: \.self) { subject in
                        Text(subject).tag(subject)
                    }
                }
                .pickerStyle(.menu)
            }

            // Start time
            DatePicker(
                "Start time",
                selection: $startTime,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )

            // Duration
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Duration: \(durationHours, specifier: "%.1f") hr")
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                Stepper(value: $durationHours, in: 0.5...4, step: 0.5) {
                    EmptyView()
                }
            }

            // Notes
            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text("Notes (optional)").font(.subheadline).foregroundColor(ColorTheme.textSecondary)
                TextField("e.g. focus on derivatives", text: $notes, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.roundedBorder)
            }
        }
        .padding(Spacing.md)
        .background(ColorTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var availabilityCalendar: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Availability Calendar")
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)

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
                VStack(alignment: .leading, spacing: Spacing.xxs) {
                    Text("Reserved / Unavailable Times")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(ColorTheme.textPrimary)
                    ForEach(unavailableSlots) { slot in
                        Text(slot.formattedTimeRange)
                            .font(.caption)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }
            }
        }
        .padding(Spacing.md)
        .background(ColorTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var bookButton: some View {
        Button {
            showConfirmationAlert = true
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView().tint(.white)
                }
                Text(viewModel.isLoading ? "Booking..." : "Book Session")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(canBook ? ColorTheme.wsuGreen : ColorTheme.textSecondary)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(!canBook)
        .alert("Confirm Tutor Session", isPresented: $showConfirmationAlert) {
            Button("Confirm") {
                Task { await book() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text(confirmationMessage)
        }
    }

    // MARK: - Actions

    private var unavailableSlots: [TimeSlot] {
        availabilitySlots.filter { !$0.isAvailable }
    }

    private var confirmationMessage: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return "Book \(selectedSubject) with \(tutor.name) from \(formatter.string(from: startTime)) to \(formatter.string(from: endTime))?"
    }

    private func loadAvailability() async {
        isLoadingAvailability = true
        availabilitySlots = await viewModel.checkAvailability(tutorId: tutor.id, date: availabilityDate)
        isLoadingAvailability = false
    }

    private func book() async {
        let success = await viewModel.bookSession(
            tutorId: tutor.id,
            subject: selectedSubject,
            startTime: startTime,
            endTime: endTime,
            notes: notes.isEmpty ? nil : notes
        )
        if success { showSuccessAlert = true }
    }
}

#Preview {
    NavigationStack {
        TutorDetailView(
            tutor: TutorProfile(
                id: "preview-1", userId: "u1", name: "Preview Tutor",
                email: "p@wsu.edu", photoURL: nil,
                subjects: ["Calculus", "Linear Algebra"], hourlyRate: 25,
                availability: [], rating: 4.9, totalSessions: 50,
                bio: "Sample bio for preview.", isApproved: true,
                createdAt: Date(), updatedAt: Date()
            )
        )
    }
}
