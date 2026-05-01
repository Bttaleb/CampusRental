//
//  StatusDisplayable.swift
//  CampusBookingSystem
//
//  Epic 2-5: Tutor, Room, Equipment & Notification
//  Requirements: Shared display contract for all status and type enums
//

import Foundation
//MARK: OOP - Abstraction, Polymorphism

// MARK: - StatusDisplayable Protocol
protocol StatusDisplayable { // Abstraction + Polymorphism
    var displayName: String { get } // Polymorphism - each case answers differently
    var icon: String { get }        // Polymorphism - each case returns its own SF Symbol
}
