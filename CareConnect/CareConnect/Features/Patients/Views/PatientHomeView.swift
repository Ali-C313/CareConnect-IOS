//
//  PatientHomeView.swift
//  CareConnect
//
//  Created by Ali Chehab on 23.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth

struct PatientHomeView: View {
    /// App-Status
    @EnvironmentObject var appState: AppStateViewModel
    /// ViewModel
    @StateObject var viewModel = PatientHomeViewModel()
    /// Alert anzeigen
    @State private var showAlert = false
    /// Live-View anzeigen
    @State private var showLiveView = false
    /// Button Animation State
    @State private var isPressed = false

    // MARK: - Date Formatting
    private static let orderDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    /// UI-Inhalt
    let gradientColors: [Color] = [Color.blue.opacity(0.6), Color.green.opacity(0.8)]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.teal.opacity(0.2),
                        Color(.systemGroupedBackground)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    Spacer()

                    VStack(spacing: 20) {
                        Image(systemName: "stethoscope")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160)
                            .foregroundStyle(Color.teal)
                            .shadow(color: CCDesign.accent.opacity(0.3), radius: 10, y: 4)

                        VStack(spacing: 8) {
                            Text("Ihre Gesundheit in besten Händen.")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.primary)
                            Text("Willkommen bei CareConnect – Ihr Partner für eine verlässliche Versorgung.")
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                                .padding(.horizontal)
                        }
                    }

                    Spacer()

                    EmergencyButton(isPressed: $isPressed, showAlert: $showAlert)
                        .padding(.horizontal, 40)

                    Button {
                        showLiveView = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "doc.text.magnifyingglass")
                            Text("Zu meinen Aufträgen")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(CCDesign.card)
                        .clipShape(RoundedRectangle(cornerRadius: CCDesign.radius))
                        .shadow(color: .black.opacity(0.08), radius: 6, y: 3)
                        .foregroundStyle(CCDesign.textPrimary)
                        .padding(.horizontal, 40)
                    }

                    Spacer()

                    Text("© 2025 CareConnect")
                        .font(.footnote)
                        .foregroundStyle(CCDesign.textSecondary.opacity(0.6))
                        .padding(.bottom, 10)
                }
                .padding()
                .alert("Notfallaktion", isPresented: $showAlert) {
                    Button("Dringlichen Auftrag erstellen") {
                        Task {
                            if let userID = appState.currentUser?.uid {
                                await appState.createEmergencyOrder(for: userID)
                            }
                        }
                    }
                    Button("Notfallkontakt anrufen") {
                        if let url = URL(string: "tel://0123456789") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Abbrechen", role: .cancel) { }
                } message: {
                    Text("Wählen Sie eine Notfallaktion aus:")
                }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.white.opacity(0.15), for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .fullScreenCover(isPresented: $showLiveView) { PatientOrdersView() }
        }
    }
}

#Preview {
    PatientHomeView()
}