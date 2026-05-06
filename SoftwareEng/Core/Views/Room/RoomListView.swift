//
//  RoomListView.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//

import SwiftUI

struct RoomListView: View {
    @StateObject private var viewModel = RoomViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.rooms.isEmpty {
                    ProgressView("Loading rooms...")
                } else if viewModel.rooms.isEmpty {
                    ContentUnavailableView(
                        "No Rooms Found",
                        systemImage: "building.2.crop.circle",
                        description: Text("No rooms match your search criteria.")
                    )
                } else {
                    List(filteredRooms) { room in
                        NavigationLink(value: room) {
                            RoomRowView(room: room)
                        }
                    }
                    .navigationDestination(for: StudyRoom.self) { room in
                        RoomDetailView(room: room)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Study Rooms")
            .searchable(text: $searchText, prompt: "Search by building or room")
            .refreshable { await viewModel.fetchRooms() }
            .task { await viewModel.fetchRooms() }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var filteredRooms: [StudyRoom] {
        let availableRooms = viewModel.rooms.filter { $0.isAvailable }
        guard !searchText.isEmpty else { return availableRooms }
        return availableRooms.filter {
            $0.building.localizedCaseInsensitiveContains(searchText)
                || $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.roomNumber.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct RoomRowView: View {
    let room: StudyRoom

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Building icon
            RoundedRectangle(cornerRadius: 10)
                .fill(ColorTheme.wsuGreen.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "building.2.fill")
                        .font(.title3)
                        .foregroundColor(ColorTheme.wsuGreen)
                }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(room.fullName)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                Text(room.location)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                HStack(spacing: Spacing.xs) {
                    Label("\(room.capacity)", systemImage: "person.2")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    if !room.features.isEmpty {
                        Text("· \(room.features.count) features")
                            .font(.caption)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }
            }

            Spacer()

            Circle()
                .fill(room.isAvailable ? .green : .red)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, Spacing.xxs)
        .padding(.horizontal, Spacing.xs)
        .background(ColorTheme.cardBackground)
        .wsuCard()
    }
}

#Preview {
    RoomListView()
}
