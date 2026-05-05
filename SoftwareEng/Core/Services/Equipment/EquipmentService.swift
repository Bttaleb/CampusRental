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

}
