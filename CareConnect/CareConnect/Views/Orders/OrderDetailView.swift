//
//  OrderDetailView.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct OrderDetailView: View {
    let order: Order
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) private var dismiss

    private let service: FirebaseServiceType = FirebaseLiveService()

    @State private var isProcessing = false
    @State private var showCompletionAlert = false
    @State private var showError = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [CCDesign.background, CCDesign.background.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {

                    // MARK: - Header
                    headerSection

                    // MARK: - Statusanzeige
                    statusSection

                    // MARK: - Patientendaten
                    if let patient = appState.patients.first(where: { ($0.uid ?? "") == (order.assignedTo ?? "") }) {
                        patientSection(patient)
                    }

                    // MARK: - Aktionen
                    actionSection
                }
                .padding()
                .padding(.bottom, 24)
            }

            if isProcessing {
                ZStack {
                    Color.black.opacity(0.35).ignoresSafeArea()
                    ProgressView("Wird aktualisiert …")
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                        .shadow(radius: 6)
                }
            }
        }
        .navigationTitle("Auftragsdetails")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Fehler", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: { Text(errorMessage) }
        .alert("Auftrag abschließen?", isPresented: $showCompletionAlert) {
            Button("Abbrechen", role: .cancel) { }
            Button("Bestätigen", role: .destructive) {
                Task {
                    await complete()
                    dismiss()
                }
            }
        } message: { Text("Dieser Auftrag wird als erledigt markiert.") }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                Circle()
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 70, height: 70)
                    .overlay(
                        Image(systemName: "person.text.rectangle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.accentColor)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(order.patientName)
                        .font(.title3.bold())
                        .foregroundColor(CCDesign.textPrimary)
                    Text("Patientenauftrag")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
            }

            if let notes = order.notes, !notes.isEmpty {
                Text(notes.joined(separator: ", "))
                    .font(.body)
                    .foregroundColor(CCDesign.textPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(CCDesign.card.opacity(0.9))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
    }

    // MARK: - Status
    private var statusSection: some View {
        HStack {
            Image(systemName: icon(for: order.state))
                .foregroundColor(order.state.color)
                .font(.system(size: 34))
                .padding(8)
                .background(order.state.color.opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text(order.state.displayName)
                    .font(.headline)
                    .foregroundColor(order.state.color)
            }

            Spacer()
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
    }

    // MARK: - Patientendaten
    private func patientSection(_ patient: Patient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .foregroundColor(.teal)
                    .font(.system(size: 22))
                Text("Patientendaten")
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)
            }

            Divider()

            Group {
                Text("Alter: \(patient.age) Jahre")
                if !patient.medications.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Medikamente:")
                            .font(.subheadline.bold())
                            .foregroundColor(.accentColor)
                        ForEach(patient.medications) { med in
                            Text("• \(med.name)")
                                .foregroundColor(CCDesign.textPrimary)
                        }
                    }
                }

                if let notes = patient.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notizen:")
                            .font(.subheadline.bold())
                            .foregroundColor(.accentColor)
                        Text(notes)
                            .foregroundColor(CCDesign.textPrimary)
                    }
                }

                if !patient.history.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Historie:")
                            .font(.subheadline.bold())
                            .foregroundColor(.accentColor)
                        ForEach(patient.history, id: \.self) { entry in
                            Text("• \(entry)")
                                .foregroundColor(CCDesign.textPrimary)
                        }
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
    }

    // MARK: - Aktionen
    private var actionSection: some View {
        VStack(spacing: 16) {
            if order.state == .offen {
                bigButton(title: "Auftrag annehmen", color: .blue, icon: "checkmark.circle.fill") {
                    await accept()
                }
            } else if order.state == .aktuell {
                bigButton(title: "Auftrag abschließen", color: .green, icon: "checkmark.seal.fill") {
                    showCompletionAlert = true
                }
            } else if order.state == .erledigt {
                Label("✅ Auftrag abgeschlossen", systemImage: "seal.fill")
                    .font(.headline)
                    .foregroundColor(.green)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(CCDesign.card)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(radius: 3)
            }
        }
    }

    private func bigButton(title: String, color: Color, icon: String, action: @escaping () async -> Void) -> some View {
        Button {
            guard !isProcessing else { return }
            isProcessing = true
            Task {
                await action()
                isProcessing = false
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: icon)
                Text(title).font(.headline.bold())
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 3)
        }
    }

    // MARK: - Firestore Aktionen
    private func accept() async {
        guard let emp = appState.currentEmployee, let id = order.id else { return }
        do {
            try await service.updateOrder(id: id, fields: [
                "state": OrderState.aktuell.rawValue,
                "employeeId": emp.id ?? emp.email,
                "acceptedAt": Date()
            ])
        } catch {
            showError = true
            errorMessage = "Fehler beim Annehmen: \(error.localizedDescription)"
        }
    }

    private func complete() async {
        guard let id = order.id else { return }
        do {
            try await service.updateOrder(id: id, fields: [
                "state": OrderState.erledigt.rawValue,
                "completedAt": Date()
            ])
        } catch {
            showError = true
            errorMessage = "Fehler beim Abschließen: \(error.localizedDescription)"
        }
    }

    private func icon(for state: OrderState) -> String {
        switch state {
        case .offen: return "tray.full.fill"
        case .aktuell: return "clock.arrow.circlepath"
        case .erledigt: return "checkmark.seal.fill"
        }
    }
}

#Preview {
    OrderDetailView(order: Order(
        state: .aktuell,
        notes: ["Kontrolle nach Medikamenteneinnahme und Puls messen."],
        description: "Kontrolle nach Medikamenteneinnahme",
        patientName: "Maria Schulz",
        createdBy: "DemoUser",
        assignedTo: nil,
        dueDate: Timestamp(date: Date().addingTimeInterval(3600)),
        createdAt: Timestamp(date: Date())
    ))
    .environmentObject(AppStateViewModel())
}
