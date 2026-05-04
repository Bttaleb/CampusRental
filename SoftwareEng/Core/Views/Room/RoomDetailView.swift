//
//  RoomDetailView.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//

import SwiftUI

struct RoomDetailView: View {
    let room: StudyRoom
    @State private var showBookingSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                // Header
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(room.fullName)
                        .font(.title2.bold())
                        .foregroundColor(ColorTheme.textPrimary)
                    Text(room.location)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                    HStack {
                        Circle()
                            .fill(room.isAvailable ? .green : .red)
                            .frame(width: 10, height: 10)
                        Text(room.isAvailable ? "Available" : "In use")
                            .font(.caption)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }

                Divider()

                // Capacity
                LabeledContent("Capacity") {
                    Label("\(room.capacity) people", systemImage: "person.2")
                }

                // Features
                if !room.features.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Features")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        FlowFeatures(features: room.features)
                    }
                }

                // Description
                if let description = room.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("About")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        Text(description)
                            .font(.body)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }

                Spacer(minLength: Spacing.lg)

                Button {
                    showBookingSheet = true
                } label: {
                    Text("Book this Room")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(room.isAvailable ? ColorTheme.wsuGreen : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!room.isAvailable)
            }
            .padding()
        }
        .navigationTitle(room.fullName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showBookingSheet) {
            BookRoomView(room: room)
        }
    }
}

private struct FlowFeatures: View {
    let features: [RoomFeature]

    var body: some View {
        // Simple wrapping using LazyVGrid — adequate for the small feature list.
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], alignment: .leading, spacing: Spacing.xs) {
            ForEach(features, id: \.self) { feature in
                Label(feature.displayName, systemImage: feature.icon)
                    .font(.caption)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 10)
                    .background(ColorTheme.wsuGreen.opacity(0.12))
                    .foregroundColor(ColorTheme.wsuGreen)
                    .cornerRadius(8)
            }
        }
    }
}

#Preview {
    NavigationStack {
        RoomDetailView(room: StudyRoom(
            id: "1", name: "Quiet Room A", building: "Library",
            floor: 2, roomNumber: "201", capacity: 6,
            features: [.whiteboard, .projector, .wifi, .powerOutlets],
            imageURL: nil, isAvailable: true,
            description: "Group study room with projector.",
            createdAt: .now, updatedAt: .now
        ))
    }
}
