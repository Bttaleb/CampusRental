//
//  AuthServiceProvider.swift
//  CampusBookingSystem
//
//  Epic 1.1: User Registration & Login
//  Requirements: Abstract contract for authentication service implementations
//

import Foundation
//MARK: OOP - Abstraction, Encapsulation

// MARK: - Auth Service Protocol
protocol AuthServiceProvider { // Abstraction - hides concrete auth implementation from callers

    // MARK: - Core Auth (used by AuthManager)

    func signUp(email: String, password: String) async throws -> AuthenticationState
    func signIn(email: String, password: String) async throws -> AuthenticationState
    func signOut() async throws
    func getAuthState() async throws -> AuthenticationState

    // MARK: - Rich Auth (used by AuthViewModel)

    /// Register with full profile data
    /// Abstraction - hides concrete signup + User-building logic
    func register(email: String, password: String, name: String, role: UserRole,
                  major: String?, year: StudentYear?) async throws -> User

    /// Login and return an app User
    /// Abstraction - hides profile fetch + fallback logic
    func login(email: String, password: String) async throws -> User

    /// Update user profile
    func updateProfile(userId: String, request: ProfileUpdateRequest) async throws -> User

    /// Send a password reset email
    func resetPassword(email: String) async throws
}
