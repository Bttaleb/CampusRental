//
//  TutorListView.swift
//  CampusBookingSystem
//
//  Epic 2: Tutor Booking
//

import SwiftUI

struct TutorListView: View {
    @StateObject private var viewModel = TutorViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.tutors.isEmpty {
                    ProgressView("Loading tutors...")
                } else if viewModel.tutors.isEmpty {
                    ContentUnavailableView(
                        "No Tutors Found",
                        systemImage: "person.2.slash",
                        description: Text("No tutors match your search criteria.")
                    )
                } else {
                    List(filteredTutors) { tutor in
                        TutorRowView(tutor: tutor)
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Tutors")
            .searchable(text: $searchText, prompt: "Search by name or subject")
            .refreshable {
                await viewModel.fetchTutors()
            }
            .task {
                await viewModel.fetchTutors()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
    
    private var filteredTutors: [TutorProfile] {
        if searchText.isEmpty {
            return viewModel.tutors
        }
        return viewModel.tutors.filter { tutor in
            tutor.name.localizedCaseInsensitiveContains(searchText) ||
            tutor.subjects.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

struct TutorRowView: View {
    let tutor: TutorProfile

    var body: some View {
        HStack(spacing: Spacing.sm) {
            // Avatar
            Circle()
                .fill(ColorTheme.wsuGreen.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(tutor.name.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(ColorTheme.wsuGreen)
                }

            VStack(alignment: .leading, spacing: Spacing.xxs) {
                Text(tutor.name)
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)

                Text(tutor.subjects.joined(separator: ", "))
                    .font(.subheadline)
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineLimit(1)

                HStack(spacing: Spacing.xs) {
                    Label(tutor.ratingDisplay, systemImage: "star.fill")
                        .font(.caption)
                        .foregroundColor(ColorTheme.wsuGold)

                    Text(tutor.formattedRate)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(ColorTheme.textSecondary)
                .font(.caption)
        }
        .padding(.vertical, Spacing.xxs)
        .padding(.horizontal, Spacing.xs)
        .background(ColorTheme.cardBackground)
        .wsuCard()
    }
}

#Preview {
    TutorListView()
}
