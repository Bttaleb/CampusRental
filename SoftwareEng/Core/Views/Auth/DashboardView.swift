//
//  DashboardView.swift
//  CampusBookingSystem
//
//  Main dashboard — surfaces the user's rentals via the unified Rentable feed.
//

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var vm = RentalsViewModel()

    var body: some View {
        NavigationView {
            List {
                Section {
                    welcomeHeader
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Spacing.md, leading: Spacing.md, bottom: 0, trailing: Spacing.md))

                Section {
                    statsSection
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: Spacing.sm, leading: Spacing.md, bottom: 0, trailing: Spacing.md))

                Section("Upcoming") {
                    if vm.isLoading && vm.rentals.isEmpty {
                        HStack { Spacer(); ProgressView(); Spacer() }
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    } else if vm.upcoming.isEmpty {
                        ContentUnavailableView(
                            "No Upcoming Rentals",
                            systemImage: "calendar.badge.exclamationmark",
                            description: Text("Book a tutor, study room, or equipment to get started.")
                        )
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(vm.upcoming.indices, id: \.self) { i in
                            let rental = vm.upcoming[i]
                            AnyRentalRow(rental: rental, onCancel: nil)
                                .listRowBackground(ColorTheme.cardBackground)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    if rental.canCancel {
                                        Button(role: .destructive) {
                                            Task { await vm.cancel(rental) }
                                        } label: {
                                            Label("Cancel", systemImage: "xmark.circle")
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(ColorTheme.background)
            .navigationTitle("Dashboard")
            .refreshable { await vm.load() }
            .task { await vm.load() }
            .alert("Error", isPresented: .constant(vm.errorMessage != nil), actions: {
                Button("OK") { vm.errorMessage = nil }
            }, message: {
                Text(vm.errorMessage ?? "")
            })
        }
    }

    // MARK: - Sections

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
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var statsSection: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.sm) {
            StatCard(
                title: "Upcoming",
                value: "\(vm.upcoming.count)",
                icon: "calendar",
                color: ColorTheme.wsuGreen
            )
            StatCard(
                title: "Reservations / Sessions",
                value: "\(vm.rentals.count)",
                icon: "tray.full",
                color: ColorTheme.info
            )
            StatCard(
                title: "Completed",
                value: "\(vm.past.count)",
                icon: "checkmark.circle",
                color: ColorTheme.statusCompleted
            )
            StatCard(
                title: "This Week",
                value: "\(thisWeekCount)",
                icon: "clock",
                color: ColorTheme.wsuGold
            )
        }
    }

    // MARK: - Computed

    private var thisWeekCount: Int {
        let now = Date()
        let weekFromNow = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? now
        return vm.upcoming.filter { $0.startTime >= now && $0.startTime <= weekFromNow }.count
    }
}

// MARK: - Stat Card

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
                .multilineTextAlignment(.center)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(Spacing.md)
        .wsuCard()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
