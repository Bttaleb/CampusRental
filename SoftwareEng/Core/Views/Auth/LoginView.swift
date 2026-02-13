//
//  LoginView.swift
//  CampusBookingSystem
//
//  Epic 1.1: User Registration & Login
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(AuthManager.self) var authManager: AuthManager
    @State private var email = ""
    @State private var password = ""
    @State private var showingRegistration = false
    @State private var showingPasswordReset = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                ColorTheme.background
                    .ignoresSafeArea()

                VStack(spacing: Spacing.xl) {
                    // Logo and Title
                    VStack(spacing: Spacing.sm) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .foregroundColor(ColorTheme.wsuGreen)

                        Text("Campus Booking")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)

                        Text("Wayne State University")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.wsuGold)
                            .fontWeight(.medium)
                    }
                    .padding(.top, 60)
                
                    // Login Form
                    VStack(spacing: Spacing.md) {
                        TextField("University Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .wsuTextField()

                        SecureField("Password", text: $password)
                            .textContentType(.password)
                            .wsuTextField()

                        if let errorMessage = authViewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(ColorTheme.error)
                                .multilineTextAlignment(.center)
                        }

                        Button(action: handleLogin) {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                            } else {
                                Text("Sign In")
                            }
                        }
                        .wsuPrimaryButton(isDisabled: authViewModel.isLoading || !isFormValid)
                        .disabled(authViewModel.isLoading || !isFormValid)

                        Button("Forgot Password?") {
                            showingPasswordReset = true
                        }
                        .wsuTextButton()
                    }
                    .padding(.horizontal, Spacing.xl)
                
                    Spacer()

                    // Register Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(ColorTheme.textSecondary)

                        Button("Sign Up") {
                            showingRegistration = true
                        }
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.wsuGold)
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showingRegistration) {
                RegistrationView()
            }
            .sheet(isPresented: $showingPasswordReset) {
                PasswordResetView()
            }
        }
    }
    
    private var isFormValid: Bool {
        authViewModel.validateEmail(email) && authViewModel.validatePassword(password)
    }
    
    private func handleLogin() {
        Task {
            await authViewModel.login(email: email, password: password)
            if authViewModel.isAuthenticated {
                await authManager.getAuthState()
            }
        }
    }
}

// MARK: - Registration View
struct RegistrationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(AuthManager.self) var authManager: AuthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var name = ""
    @State private var role: UserRole = .student
    @State private var major = ""
    @State private var year: StudentYear?
    
    var body: some View {
        NavigationView {
            Form {
                Section("Personal Information") {
                    TextField("Full Name", text: $name)
                    TextField("University Email", text: $email)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                
                Section("Account Security") {
                    SecureField("Password", text: $password)
                        .textContentType(.newPassword)
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textContentType(.newPassword)
                }
                
                Section("Role") {
                    Picker("I am a", selection: $role) {
                        ForEach(UserRole.allCases.filter { $0 != .admin }, id: \.self) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if role == .student {
                    Section("Student Information") {
                        TextField("Major", text: $major)
                        Picker("Year", selection: $year) {
                            Text("Select").tag(nil as StudentYear?)
                            ForEach(StudentYear.allCases, id: \.self) { year in
                                Text(year.displayName).tag(year as StudentYear?)
                            }
                        }
                    }
                }
                
                if let errorMessage = authViewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Up") {
                        handleRegistration()
                    }
                    .disabled(!isFormValid || authViewModel.isLoading)
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        !name.isEmpty &&
        authViewModel.validateEmail(email) &&
        authViewModel.validatePassword(password) &&
        password == confirmPassword &&
        (role == .tutor || (!major.isEmpty && year != nil))
    }
    
    private func handleRegistration() {
        Task {
            await authViewModel.register(
                email: email,
                password: password,
                name: name,
                role: role,
                major: role == .student ? major : nil,
                year: role == .student ? year : nil
            )

            if authViewModel.isAuthenticated {
                await authManager.getAuthState()
                dismiss()
            }
        }
    }
}

// MARK: - Password Reset View
struct PasswordResetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var email = ""
    @State private var showingSuccess = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("University Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .keyboardType(.emailAddress)
                    .padding(.horizontal)
                
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                
                Button("Send Reset Link") {
                    handlePasswordReset()
                }
                .wsuPrimaryButton(isDisabled: !authViewModel.validateEmail(email) || authViewModel.isLoading)
                .padding(.horizontal)
                .disabled(!authViewModel.validateEmail(email) || authViewModel.isLoading)
                
                Spacer()
            }
            .navigationTitle("Reset Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Check Your Email", isPresented: $showingSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("We've sent you a password reset link. Please check your email.")
            }
        }
    }
    
    private func handlePasswordReset() {
        Task {
            await authViewModel.resetPassword(email: email)
            showingSuccess = true
        }
    }
}

#Preview {
    LoginView()
        .environment(AuthManager(service: SupabaseAuthService()))
        .environmentObject(AuthViewModel())
}

