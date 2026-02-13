//
//  AuthViewModel.swift
//  CampusBookingSystem
//
//  Epic 1.1: User Registration & Login
//  Handles authentication flow and user session management
//

import Foundation
import SwiftUI
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Services
    private let authService = SupabaseAuthService()
    private let keychainService = KeychainService.shared

    // MARK: - Initialization
    init() {
        checkAuthStatus()
    }

    // MARK: - Authentication Methods

    /// Check if user is already authenticated via cached data
    func checkAuthStatus() {
        if let userData = keychainService.getData(key: Config.Auth.userKey),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }

    /// Register new user
    func register(email: String, password: String, name: String, role: UserRole,
                  major: String? = nil, year: StudentYear? = nil) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.register(
                email: email,
                password: password,
                name: name,
                role: role,
                major: major,
                year: year
            )

            // Cache user data locally
            if let userData = try? JSONEncoder().encode(user) {
                keychainService.saveData(userData, key: Config.Auth.userKey)
            }

            currentUser = user
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Login existing user
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await authService.login(email: email, password: password)

            // Cache user data locally
            if let userData = try? JSONEncoder().encode(user) {
                keychainService.saveData(userData, key: Config.Auth.userKey)
            }

            currentUser = user
            isAuthenticated = true

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Logout current user
    func logout() {
        Task {
            try? await authService.signOut()
        }

        keychainService.deleteData(key: Config.Auth.userKey)

        currentUser = nil
        isAuthenticated = false
    }

    /// Update user profile
    func updateProfile(_ request: ProfileUpdateRequest) async {
        guard let userId = currentUser?.id else { return }

        isLoading = true
        errorMessage = nil

        do {
            let updatedUser = try await authService.updateProfile(userId: userId, request: request)

            // Update cache
            if let userData = try? JSONEncoder().encode(updatedUser) {
                keychainService.saveData(userData, key: Config.Auth.userKey)
            }

            currentUser = updatedUser

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    /// Reset password
    func resetPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            try await authService.resetPassword(email: email)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    // MARK: - Validation

    func validateEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }

    func validatePassword(_ password: String) -> Bool {
        return password.count >= 8
    }

    func validateUniversityEmail(_ email: String) -> Bool {
        return email.hasSuffix(Config.Auth.ssoDomain)
    }
}
