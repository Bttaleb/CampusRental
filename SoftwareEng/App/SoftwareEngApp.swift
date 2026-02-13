//
//  CampusBookingSystemApp.swift
//  CampusBookingSystem
//
//  Created on 2/6/26
//  Sprint 1 - Initial Implementation
//

import SwiftUI

@main
struct SoftwareEngApp: App {
    // MARK: - State Objects
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var authManager = AuthManager(service: SupabaseAuthService())
    
    // MARK: - App Delegate
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(authManager)
                .environmentObject(authViewModel)
                .environmentObject(notificationManager)
                .onAppear {
                    configureApp()
                }
        }
    }
    
    // MARK: - Configuration
    private func configureApp() {
        // Configure navigation bar appearance with WSU Green
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .wsuGreen
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white

        // Request notification permissions
        notificationManager.requestAuthorization()
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Additional app configuration
        return true
    }
    
    func application(_ application: UIApplication,
                    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(token)")
        // Send token to backend
    }
}
