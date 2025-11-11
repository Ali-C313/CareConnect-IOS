//
//  HomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct HomeView: View {
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// Statusanzeige
    @State private var showStatusPopup = false
    /// Suchsheet
    @State private var showSearchSheet = false

    /// UI-Inhalt
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    Text("Tippe auf den Status, um ihn zu ändern")
                        .font(.caption)
                        .foregroundColor(CCDesign.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 8)

                    statsSection

                    employeesSection
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)
                .scrollContentBackground(.hidden)
                .background(CCDesign.background)
                .animation(.easeInOut, value: appState.staffStatus)
                .animation(.easeInOut, value: appState.orders)
                .animation(.easeInOut, value: appState.searchText)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .task { await appState.loadInitial() }
            .sheet(isPresented: $showSearchSheet) {
                GlobalSearchView()
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack(spacing: 0) {
            Picker(selection: $appState.staffStatus, label: HStack(spacing: 8) {
                Circle()
                    .fill(appState.staffStatus.color)
                    .frame(width: 12, height: 12)
                Text(appState.staffStatus.rawValue)
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            ) {
                ForEach(StaffStatus.allCases) { st in
                    HStack {
                        Circle()
                            .fill(st.color)
                            .frame(width: 12, height: 12)
                        Text(st.displayName)
                    }
                    .tag(st)
                }
            }
            .pickerStyle(.menu)
            .onChange(of: appState.staffStatus) {
                Task { await appState.updateCurrentStatus(appState.staffStatus) }
            }
            .frame(maxWidth: .infinity)

            Divider()
                .frame(height: 36)
                .background(Color.secondary.opacity(0.3))
                .padding(.vertical, 8)

            SearchBarView(text: $appState.searchText,
                          placeholder: "Suche Mitarbeiter, Patienten, Aufträge…")
                .frame(height: 36)
                .onTapGesture { showSearchSheet = true }
                .frame(maxWidth: .infinity)
        }
        .padding()
        .background(CCDesign.card)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
    }

    // MARK: - Statistik Section
    private var statsSection: some View {
        HStack(spacing: 16) {
            statTile(value: appState.orders.filter { $0.state == .offen }.count,
                     label: "Offen",
                     iconName: "clock",
                     gradientColors: [Color.orange.opacity(0.85), Color.orange.opacity(0.6)],
                     color: .orange)
            .frame(minWidth: 0, maxWidth: .infinity)

            statTile(value: appState.orders.filter { $0.state == .aktuell }.count,
                     label: "Aktuell",
                     iconName: "play.circle",
                     gradientColors: [Color.blue.opacity(0.85), Color.blue.opacity(0.6)],
                     color: .blue)
            .frame(minWidth: 0, maxWidth: .infinity)

            statTile(value: appState.orders.filter { $0.state == .erledigt }.count,
                     label: "Erledigt",
                     iconName: "checkmark.circle",
                     gradientColors: [Color.green.opacity(0.85), Color.green.opacity(0.6)],
                     color: .green)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
        .clipped(antialiased: false)
        .transition(.opacity.combined(with: .move(edge: .bottom)))
    }

    // MARK: - Statistik-Helper
    /// Statistik-Kachel
    private func statTile(value: Int, label: String, iconName: String, gradientColors: [Color], color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [CCDesign.card.opacity(0.95), color.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: color.opacity(0.25), radius: 6, x: 0, y: 3)

            VStack(spacing: 10) {
                Image(systemName: iconName)
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(color)

                Text("\(value)")
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundColor(CCDesign.textPrimary)

                Text(label)
                    .font(.caption.bold())
                    .foregroundColor(CCDesign.textSecondary)
            }
            .padding(.vertical, 12)
        }
        .frame(height: 110)
    }

    // MARK: - Mitarbeiter Section
    private var employeesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("👥 Mitarbeiter")
                .font(.headline)
                .foregroundColor(CCDesign.textPrimary)
                .padding(.bottom, 4)

            LazyVStack(spacing: 12) {
                ForEach(appState.filteredEmployees(appState.searchText)) { e in
                    NavigationLink {
                        EmployeeProfileView(employeeId: e.id ?? "")
                    } label: {
                        HStack(spacing: 12) {
                            AvatarView(
                                initials: "\(e.firstName.prefix(1))\(e.lastName.prefix(1))",
                                size: 48
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(e.staffStatusEnum.color.opacity(0.7), lineWidth: 2)
                                    .shadow(color: e.staffStatusEnum.color.opacity(0.5), radius: 6)
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(e.firstName) \(e.lastName)")
                                    .font(.headline)
                                    .foregroundColor(CCDesign.textPrimary)
                                    .lineLimit(1)
                                Text(e.role)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(e.staffStatusEnum.rawValue)
                                    .font(.caption2)
                                    .foregroundColor(e.staffStatusEnum.color)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(CCDesign.card)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.light)
}
