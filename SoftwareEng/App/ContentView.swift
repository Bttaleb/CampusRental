//
//  ContentView.swift
//  CampusBookingSystem
//
//  Epic 1: User Accounts & Profiles
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(AuthManager.self) private var authManager
    
    var body: some View {
        Group {
            switch authManager.authState {
            case .notDetermined:
                ProgressView()
            case .notAuthenticated:
                LoginView()
            case .authenticated:
                MainTabView()
            }
        }
        .task {
            await authManager.getAuthState()
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home/Dashboard
            DashboardView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            // Tutors
            TutorListView()
                .tabItem {
                    Label("Tutors", systemImage: "person.2.fill")
                }
                .tag(1)
            
            // Study Rooms
            RoomListView()
                .tabItem {
                    Label("Rooms", systemImage: "building.2.fill")
                }
                .tag(2)
            
            // Equipment
            EquipmentListView()
                .tabItem {
                    Label("Equipment", systemImage: "laptopcomputer")
                }
                .tag(3)
            
            // Profile
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
                .tag(4)
        }
        .accentColor(ColorTheme.wsuGreen)
    }
}

#Preview {
    ContentView()
        .environment(AuthManager(service: SupabaseAuthService()))
        .environmentObject(AuthViewModel())
        .environmentObject(NotificationManager.shared)
}
