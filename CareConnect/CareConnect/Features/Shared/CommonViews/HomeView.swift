//
//  HomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI
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
            ZStack {
                CCDesign.background.ignoresSafeArea()

                VStack(alignment: .leading, spacing: 24) {

                    // Kopf: Status + Suche
                    HStack(spacing: 12) {
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
                        .background(CCDesign.card.opacity(0.95))
                        .cornerRadius(12)) {
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

                        Spacer()

                        SearchBarView(text: $appState.searchText,
                                      placeholder: "Suche Mitarbeiter, Patienten, Aufträge…")
                            .frame(height: 36)
                            .onTapGesture { showSearchSheet = true }
                    }
                    .padding(.horizontal)

                    Text("Tippe auf den Status, um ihn zu ändern")
                        .font(.caption)
                        .foregroundColor(CCDesign.textSecondary)
                        .padding(.horizontal)

                    // Statistik
                    HStack(spacing: 12) {
                        statTile(value: appState.orders.filter { $0.state == .offen }.count,
                                 label: "Offen", color: .orange)
                        statTile(value: appState.orders.filter { $0.state == .aktuell }.count,
                                 label: "Aktuell", color: .blue)
                        statTile(value: appState.orders.filter { $0.state == .erledigt }.count,
                                 label: "Erledigt", color: .green)
                    }
                    .padding(.horizontal)

                    // Mitarbeiterliste mit Navigation
                    VStack(alignment: .leading, spacing: 12) {
                        Text("👥 Mitarbeiter")
                            .font(.headline)
                            .foregroundColor(CCDesign.textPrimary)

                        ScrollView(showsIndicators: false) {
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
                                        .shadow(color: Color(.separator).opacity(0.25),
                                                radius: 3, x: 0, y: 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 20)
                }
                .padding(.vertical, 24)
            }
            .navigationTitle("Home")
            .task { await appState.loadInitial() }
            .sheet(isPresented: $showSearchSheet) {
                GlobalSearchView()
                    .environmentObject(appState)
            }
        }
    }

    // MARK: - Statistik-Helper
    /// Statistik-Kachel
    private func statTile(value: Int, label: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(color.opacity(0.9))
            VStack {
                Text("\(value)")
                    .font(.title2.bold())
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(.white)
            .padding(8)
        }
        .frame(height: 80)
        .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppStateViewModel())
        .preferredColorScheme(.light)
}
