import Foundation
import Supabase

enum EquipmentServiceError: LocalizedError {
    case timeSlotConflict
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .timeSlotConflict: return "This equipment is already booked"
        case .notAuthenticated: return "You must be signed in to do that"
        }
    }
}

struct SupabaseEquipmentService: EquipmentServiceProvider {
    
    private let client: SupabaseClient
    
    private static let openHour = 8
    private static let closeHour = 22
    
    init(client: SupabaseClient) {
        self.client = client
    }
    
    init() {
        self.init(client: SupabaseClient(
            supabaseURL: URL(string: AppConstants.projectURLString)!, supabaseKey: AppConstants.projectAPIKey
        ))
    }

    func search(filters: EquipmentSearchFilters) async throws -> [Equipment] {
        var query = client.from("equipment").select()
        
        if let location = filters.location {
            query = query.eq("location", value: location)
        }
        
        if let category = filters.category {
            query = query.eq("category", value: category.rawValue)
        }
        
        if let condition = filters.condition {
            query = query.eq("condition", value: condition.rawValue)
        }
        
        let orderColumn: String
        let ascending: Bool
        switch filters.sortBy {
        case .name: orderColumn = "name"; ascending = true
        case .category: orderColumn = "category"; ascending = true
        case .location: orderColumn = "location"; ascending = true
        case .condition: orderColumn = "condition"; ascending = true
        }
        
        return try await query.order(orderColumn, ascending: ascending).execute().value
    }
    
    func getEquipment(id: String) async throws -> Equipment {
        return try await client.from("equipment")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
    }
    // Ensure equipment is available
    func rent(request: EquipmentReservationRequest) async throws -> EquipmentReservation {
        try await ensureEquipmentIsAvailable(
            equipmentId: request.equipmentId,
            start: request.startTime,
            end: request.endTime,
            excludingReservationId: nil
        )
        do {
            return try await client.from("equipment_reservations")
                .insert(request)
                .select()
                .single()
                .execute()
                .value
        } catch {
            if "\(error)".contains("equipment_reservation_no_overlap") {
                throw EquipmentServiceError.timeSlotConflict
            }
            throw error
        }
    }
    
    func getUserReservations() async throws -> [EquipmentReservation] {
        guard let userId = try? await
                client.auth.session.user.id.uuidString else {
            return []
        }
        
        return try await client.from("equipment_reservations")
            .select()
            .eq("user_id", value: userId)
            .order("start_time", ascending: false)
            .execute()
            .value
    }
    
    func cancel(id: String) async throws {
        try await client.from("equipment_reservations")
            .update(["status": "cancelled"])
            .eq("id", value: id)
            .execute()
    }
    
    func reschedule(id: String, newStartTime: Date, newEndTime: Date) async throws -> EquipmentReservation {
        let current: EquipmentReservation = try await client.from("equipment_reservations")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value

        try await ensureEquipmentIsAvailable(
            equipmentId: current.equipmentId,
            start: newStartTime,
            end: newEndTime,
            excludingReservationId: id
        )

        let formatter = ISO8601DateFormatter()
        do {
            return try await client.from("equipment_reservations")
                .update(["start_time": formatter.string(from: newStartTime), "end_time": formatter.string(from: newEndTime)])
                .eq("id", value: id)
                .select()
                .single()
                .execute()
                .value
        } catch {
            if "\(error)".contains("equipment_reservation_no_overlap") {
                throw EquipmentServiceError.timeSlotConflict
            }
            throw error
        }
    }
    
    func getEquipmentAvailability(equipmnentId: String, date: Date) async throws -> [TimeSlot] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let reservations: [EquipmentReservation] = try await
        client.from("equipment_reservations")
            .select()
            .eq("equipment_id", value: equipmnentId)
            .in("status", value: ["pending", "confirmed"])
            .lt("start_time", value: formatter.string(from: endOfDay))
            .gt("end_time", value: formatter.string(from: startOfDay))
            .execute()
            .value
        
        var slots: [TimeSlot] = []
        for hour in Self.openHour..<Self.closeHour {
            guard
                let slotStart = calendar.date(bySettingHour: hour, minute: 0, second: 0, of: startOfDay),
                let slotEnd = calendar.date(byAdding: .hour, value: 1, to: slotStart)
            else {continue}
            
            let isReserved = reservations.contains {
                reservation in reservation.startTime < slotEnd && reservation.endTime > slotStart
            }
            slots.append(TimeSlot(startTime: slotStart, endTime: slotEnd, isAvailable: !isReserved))
        }
        return slots
    }
    
    func rate(equipmentId: String, rating: Int, comment: String?) async throws {
        let payload = EquipmentRatingInsert(equipmentId: equipmentId, rating: rating, comment: comment)
        try await client.from("equipment_ratings")
            .insert(payload)
            .execute()
    }

    // MARK: - Conflict Guard

    private func ensureEquipmentIsAvailable(
        equipmentId: String,
        start: Date,
        end: Date,
        excludingReservationId: String?
    ) async throws {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var query = client.from("equipment_reservations")
            .select("id")
            .eq("equipment_id", value: equipmentId)
            .in("status", value: ["pending", "confirmed"])
            .lt("start_time", value: formatter.string(from: end))
            .gt("end_time", value: formatter.string(from: start))
            .limit(20)

        let conflicts: [ReservationConflictRow] = try await query.execute().value
        let hasConflicts = conflicts.contains { conflict in
            guard let excludingReservationId else { return true }
            return conflict.id != excludingReservationId
        }
        if hasConflicts {
            throw EquipmentServiceError.timeSlotConflict
        }
    }
}

private struct ReservationConflictRow: Decodable {
    let id: String
}

private struct EquipmentRatingInsert: Encodable {
    let equipmentId: String
    let rating: Int
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case equipmentId = "equipment_id"
        case rating
        case comment
    }
}
