//
//  EquipmentViewModel.swift
//  CampusBookingSystem
//
//  Epic 4: Equipment Rental
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class EquipmentViewModel: ObservableObject { // Abstraction + Polymorphism
    @Published var equipment: [Equipment] = []
    @Published var searchFilters = EquipmentSearchFilters()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: EquipmentServiceProvider // DIP — depend on abstraction

    init(service: EquipmentServiceProvider = SupabaseEquipmentService()) {
        self.service = service
    }

    func fetchEquipment() async {
        isLoading = true
        errorMessage = nil
        do {
            equipment = try await service.search(filters: searchFilters)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func reserve(equipmentId: String, startTime: Date, endTime: Date, purpose: String?) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            let request = EquipmentReservationRequest(
                equipmentId: equipmentId,
                startTime: startTime,
                endTime: endTime,
                purpose: purpose
            )
            _ = try await service.rent(request: request)
            await fetchEquipment()
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func checkAvailability(equipmentId: String, date: Date) async -> [TimeSlot] {
        do {
            return try await service.getEquipmentAvailability(equipmnentId: equipmentId, date: date)
        } catch {
            errorMessage = error.localizedDescription
            return []
        }
    }
}
