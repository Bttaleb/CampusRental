//
//  DashboardView.swift
//  CampusBookingSystem
//
//  Main dashboard showing user's bookings and quick actions
//

import SwiftUI
import Combine

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = DashboardViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: Spacing.lg) {
                    // Welcome Header
                    welcomeHeader

                    // Quick Stats
                    statsSection

                    // Upcoming Bookings
                    upcomingBookingsSection

                    // Quick Actions
                    quickActionsSection
                }
                .padding(Spacing.md)
            }
            .background(ColorTheme.background)
            .navigationTitle("Dashboard")
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    private var welcomeHeader: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Welcome back,")
                .font(.title3)
                .foregroundColor(ColorTheme.textSecondary)

            Text(authViewModel.currentUser?.displayName ?? "Student")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
        }
        .padding(.bottom, Spacing.xs)
    }
    
    private var statsSection: some View {
        HStack(spacing: Spacing.sm) {
            StatCard(
                title: "Upcoming",
                value: "\(viewModel.upcomingCount)",
                icon: "calendar",
                color: ColorTheme.wsuGreen
            )

            StatCard(
                title: "Completed",
                value: "\(viewModel.completedCount)",
                icon: "checkmark.circle",
                color: ColorTheme.statusCompleted
            )

            StatCard(
                title: "This Week",
                value: "\(viewModel.weeklyCount)",
                icon: "clock",
                color: ColorTheme.wsuGold
            )
        }
    }
    
    private var upcomingBookingsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Upcoming Bookings")
                    .wsuSectionHeader()
                Spacer()
                NavigationLink("See All") {
                    // BookingsListView()
                }
                .font(.subheadline)
                .foregroundColor(ColorTheme.wsuGold)
            }
            
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else if viewModel.upcomingBookings.isEmpty {
                ContentUnavailableView(
                    "No Upcoming Bookings",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("Book a tutor, study room, or equipment to get started")
                )
            } else {
                ForEach(viewModel.upcomingBookings.prefix(3)) { booking in
                    BookingCard(booking: booking)
                }
            }
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Quick Actions")
                .wsuSectionHeader()

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
                QuickActionButton(
                    title: "Find Tutor",
                    icon: "person.2.fill",
                    color: ColorTheme.wsuGreen
                ) {
                    // Navigate to tutors
                }

                QuickActionButton(
                    title: "Book Room",
                    icon: "building.2.fill",
                    color: ColorTheme.statusCompleted
                ) {
                    // Navigate to rooms
                }

                QuickActionButton(
                    title: "Rent Equipment",
                    icon: "laptopcomputer",
                    color: ColorTheme.wsuGold
                ) {
                    // Navigate to equipment
                }

                QuickActionButton(
                    title: "My Bookings",
                    icon: "list.bullet.rectangle",
                    color: ColorTheme.info
                ) {
                    // Navigate to bookings
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)

            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .wsuCard()
    }
}

struct BookingCard: View {
    let booking: UnifiedBooking

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: booking.type.icon)
                .font(.title2)
                .foregroundColor(booking.status.color)
                .frame(width: 40)

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(booking.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.textPrimary)

                Text(booking.subtitle)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)

                Text(booking.formattedTimeRange)
                    .font(.caption2)
                    .foregroundColor(ColorTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .padding(Spacing.md)
        .wsuCard()
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(ColorTheme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(Spacing.md)
            .wsuCard()
        }
    }
}

// MARK: - Dashboard ViewModel
@MainActor
class DashboardViewModel: ObservableObject {
    @Published var upcomingBookings: [UnifiedBooking] = []
    @Published var upcomingCount = 0
    @Published var completedCount = 0
    @Published var weeklyCount = 0
    @Published var isLoading = false
    
    func loadData() async {
        isLoading = true
        // Fetch data from backend
        // Placeholder implementation
        isLoading = false
    }
    
    func refresh() async {
        await loadData()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
