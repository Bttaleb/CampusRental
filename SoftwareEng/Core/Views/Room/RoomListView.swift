//
//  RoomListView.swift
//  CampusBookingSystem
//
//  Epic 3: Study Room Booking
//

import SwiftUI

struct RoomListView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "building.2.fill",
                description: Text("Study room booking will be available soon.")
            )
            .navigationTitle("Study Rooms")
        }
    }
}

#Preview {
    RoomListView()
}
