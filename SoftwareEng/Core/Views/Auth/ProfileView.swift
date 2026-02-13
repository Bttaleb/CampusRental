//
//  ProfileView.swift
//  CampusBookingSystem
//
//  Epic 1.2: User Profile Management
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(AuthManager.self) private var authManager
    @State private var showingEditProfile = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        AsyncImage(url: URL(string: authViewModel.currentUser?.photoURL ?? "")) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(authViewModel.currentUser?.name ?? "")
                                .font(.title2)
                            Text(authViewModel.currentUser?.email ?? "")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical)
                }
                
                Section("Account") {
                    if let user = authViewModel.currentUser {
                        LabeledContent("Role", value: user.role.displayName)
                        if let major = user.major {
                            LabeledContent("Major", value: major)
                        }
                    }
                }
                
                Section {
                    Button("Edit Profile") {
                        showingEditProfile = true
                    }
                }
                
                Section {
                    Button("Sign Out", role: .destructive) {
                        Task {
                            try? await authManager.signOut()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}
