//
//  EquipmentDetailView.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Rental
//

import SwiftUI

struct EquipmentDetailView: View {
    let equipment: Equipment
    @State private var showReserveSheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Spacing.md) {
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(equipment.name)
                        .font(.title2.bold())
                        .foregroundColor(ColorTheme.textPrimary)
                    Text(equipment.location)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                    HStack {
                        Circle()
                            .fill(equipment.isAvailable ? .green : .red)
                            .frame(width: 10, height: 10)
                        Text(equipment.isAvailable ? "Available" : "Reserved")
                            .font(.caption)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                }

                Divider()

                LabeledContent("Category") {
                    Label(equipment.category.displayName, systemImage: equipment.category.icon)
                }
                LabeledContent("Condition", value: equipment.condition.displayName)
                if let serial = equipment.serialNumber {
                    LabeledContent("Serial", value: serial)
                }

                if let specs = equipment.specifications, !specs.isEmpty {
                    VStack(alignment: .leading, spacing: Spacing.xs) {
                        Text("Specifications")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        ForEach(specs.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                            HStack {
                                Text(key)
                                    .foregroundColor(ColorTheme.textSecondary)
                                Spacer()
                                Text(value)
                                    .foregroundColor(ColorTheme.textPrimary)
                            }
                            .font(.caption)
                        }
                    }
                }

                if let description = equipment.description, !description.isEmpty {
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
                    showReserveSheet = true
                } label: {
                    Text(equipment.isAvailable ? "Reserve" : "Currently Reserved")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(equipment.isAvailable ? ColorTheme.wsuGreen : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!equipment.isAvailable)
            }
            .padding()
        }
        .navigationTitle(equipment.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReserveSheet) {
            ReserveEquipmentView(equipment: equipment)
        }
    }
}
