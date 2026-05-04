//
//  EquipmentServiceProvider.swift
//  SoftwareEng
//
//  Created by Bassel Taleb on 5/3/26.
//

import Foundation

protocol EquipmentServiceProvider {
    func search(filters: EquipmentSearchFilters) async throws -> [Equipment]
    func getEquipment(id: String) async throws -> Equipment
    
    func rent(request: EquipmentReservationRequest) async throws -> EquipmentReservation
    func getUserReservations() async throws -> [EquipmentReservation]
    func cancel(id: String) async throws
    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> EquipmentReservation
    
    func getEquipmentAvailability(equipmnentId: String, date: Date) async throws -> [TimeSlot]
    func rate(equipmentId: String, rating: Int, comment: String?) async throws
}
