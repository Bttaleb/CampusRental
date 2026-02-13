//
//  EquipmentListView.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Rental
//

import SwiftUI

struct EquipmentListView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "laptopcomputer",
                description: Text("Equipment rental will be available soon.")
            )
            .navigationTitle("Equipment")
        }
    }
}

#Preview {
    EquipmentListView()
}
