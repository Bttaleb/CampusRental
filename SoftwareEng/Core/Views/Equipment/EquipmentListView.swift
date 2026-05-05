//
//  EquipmentListView.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Rental
//

import SwiftUI

struct EquipmentListView: View {
    @StateObject private var viewModel = EquipmentViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.equipment.isEmpty {
                    ProgressView("Loading equipment...")
                } else if viewModel.equipment.isEmpty {
                    ContentUnavailableView(
                        "No Equipment Found",
                        systemImage: "laptopcomputer",
                        description: Text("No equipment matches your search.")
                    )
                } else {
                    List(filteredEquipment) { item in
                        NavigationLink(value: item) {
                            EquipmentRowView(equipment: item)
                        }
                    }
                    .navigationDestination(for: Equipment.self) { item in
                        EquipmentDetailView(equipment: item)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Equipment")
            .searchable(text: $searchText, prompt: "Search equipment")
            .refreshable { await viewModel.fetchEquipment() }
            .task { await viewModel.fetchEquipment() }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var filteredEquipment: [Equipment] {
        guard !searchText.isEmpty else { return viewModel.equipment }
        return viewModel.equipment.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
                || $0.location.localizedCaseInsensitiveContains(searchText)
                || $0.category.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }
}

struct EquipmentRowView: View {
    let equipment: Equipment

    var body: some View {
        HStack(spacing: Spacing.sm) {
            RoundedRectangle(cornerRadius: 10)
                .fill(ColorTheme.wsuGreen.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: equipment.category.icon)
                        .font(.title3)
                        .foregroundColor(ColorTheme.wsuGreen)
                }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(equipment.name)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                Text(equipment.location)
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                HStack(spacing: Spacing.xs) {
                    Label(equipment.category.displayName, systemImage: "tag")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    Text("· \(equipment.condition.displayName)")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }

            Spacer()

            Circle()
                .fill(equipment.isAvailable ? .green : .red)
                .frame(width: 8, height: 8)
        }
        .padding(.vertical, Spacing.xxs)
        .padding(.horizontal, Spacing.xs)
        .background(ColorTheme.cardBackground)
        .wsuCard()
    }
}

#Preview {
    EquipmentListView()
}
