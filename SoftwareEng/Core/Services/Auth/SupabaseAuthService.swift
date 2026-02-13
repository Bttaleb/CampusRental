//
//  SupabaseAuthService.swift
//  CampusBookingSystem
//
//  Epic 1.1: User Registration & Login
//  Handles authentication API calls via Supabase
//

import Foundation
import Supabase

struct SupabaseAuthService {
    let client: SupabaseClient

    init() {
        self.client = SupabaseClient(
            supabaseURL: URL(string: AppConstants.projectURLString)!,
            supabaseKey: AppConstants.projectAPIKey
        )
    }

    // MARK: - Core Auth (used by AuthManager)

    func signUp(email: String, password: String) async throws -> AuthenticationState {
        try await client.auth.signUp(email: email, password: password)
        return .authenticated
    }

    func signIn(email: String, password: String) async throws -> AuthenticationState {
        try await client.auth.signIn(email: email, password: password)
        return .authenticated
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }

    func getAuthState() async throws -> AuthenticationState {
        let user = try? await client.auth.session.user
        return user == nil ? .notAuthenticated : .authenticated
    }

    // MARK: - Rich Auth (used by AuthViewModel)

    /// Register with full profile data, calls Supabase signUp then builds a User
    func register(email: String, password: String, name: String, role: UserRole,
                  major: String?, year: StudentYear?) async throws -> User {
        let response = try await client.auth.signUp(email: email, password: password)
        let supabaseUser = response.user

        // Build app User from Supabase auth user
        return User(
            id: supabaseUser.id.uuidString,
            email: email,
            name: name,
            role: role,
            major: major,
            year: year,
            createdAt: supabaseUser.createdAt,
            updatedAt: supabaseUser.updatedAt ?? Date()
        )
    }

    /// Login and return an app User
    func login(email: String, password: String) async throws -> User {
        let session = try await client.auth.signIn(email: email, password: password)
        let supabaseUser = session.user

        // Try to fetch profile from profiles table
        if let profile: User = try? await client.from("profiles")
            .select()
            .eq("id", value: supabaseUser.id.uuidString)
            .single()
            .execute()
            .value {
            return profile
        }

        // Fallback: build a minimal User from auth data
        return User(
            id: supabaseUser.id.uuidString,
            email: supabaseUser.email ?? email,
            name: supabaseUser.email?.components(separatedBy: "@").first ?? "User",
            role: .student,
            createdAt: supabaseUser.createdAt,
            updatedAt: supabaseUser.updatedAt ?? Date()
        )
    }

    /// Update user profile in the profiles table
    func updateProfile(userId: String, request: ProfileUpdateRequest) async throws -> User {
        return try await client.from("profiles")
            .update(request)
            .eq("id", value: userId)
            .select()
            .single()
            .execute()
            .value
    }

    /// Send a password reset email
    func resetPassword(email: String) async throws {
        try await client.auth.resetPasswordForEmail(email)
    }
}
