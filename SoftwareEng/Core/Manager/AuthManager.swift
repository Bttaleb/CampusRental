//
//  AuthManager.swift
//  SoftwareEng
//
//  Created by Bassel Taleb on 2/13/26.
//

import Foundation

@Observable @MainActor
final class AuthManager {
    private let service: SupabaseAuthService
    
    var authState: AuthenticationState = .notDetermined
    var error: Error?
    
    init(service: SupabaseAuthService) {
        self.service = service
    }
                                /* "async" and not "async throws" so we can handle
                                            and catch the error to display it*/
    func signUp(email: String, password: String) async {
        do {
            self.authState = try await service.signUp(email: email, password: password)
        } catch {
            self.error = error
            print("DEBUG: Error signing up: \(error)")
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            self.authState = try await service.signIn(email: email, password: password)
        } catch {
            self.error = error
            print("DEBUG: Error logging in: \(error)")
        }
    }
    
    func signOut() async {
        do {
            try await service.signOut()
        } catch {
            self.error = error
            print("DEBUG: Error signing out: \(error)")
        }
    }
    
    func getAuthState() async {
        do {
            self.authState = try await service.getAuthState()
        } catch {
            self.error = error
            print("DEBUG: Error getting auth state: \(error)")
        }
    }
}


