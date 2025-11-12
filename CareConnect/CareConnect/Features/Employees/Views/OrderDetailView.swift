//
//  OrderDetailView.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
import Foundation
import FirebaseAuth
import FirebaseFirestore
import MapKit
import CoreLocation

struct OrderDetailView: View {
    let order: Order
    @EnvironmentObject var appState: AppStateViewModel
    @Environment(\.dismiss) private var dismiss

    private let service: FirebaseServiceType = FirebaseLiveService()

    /// Ladezustand
    @State private var isProcessing = false
    @State private var showCompletionAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showEditSheet = false

    /// Live-Tracking
    @State private var locationListener: ListenerRegistration?
    @State private var employeeCoordinate: CLLocationCoordinate2D?
    @State private var patientCoordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.0, longitude: 8.6), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    @State private var etaText: String? = nil

    var body: some View {
        mainView
    }

    private var mainView: some View {
        ZStack {
            backgroundLayer
            contentList

            if isProcessing {
                processingOverlay
            }
        }
        .onAppear {
            if order.state == .aktuell {
                startLiveTracking()
            } else if order.state == .offen {
                Task {
                    await updateOrderToAktuell()
                }
                preparePatientCoordinate()
            }
        }
        .onDisappear {
            stopLiveTracking()
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
        .sheet(isPresented: $showEditSheet) {
            NewOrderSheet(isPresented: $showEditSheet, existingOrder: order)
        }
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        // Consistent background for light/dark
        CCDesign.background
            .ignoresSafeArea()
        // Subtle unified gradient for depth
        LinearGradient(
            colors: [
                CCDesign.background.opacity(0.95),
                CCDesign.accent.opacity(0.07)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var contentList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                Group {
                    // MARK: - Header Card
                    HeaderCard(order: order)
                        .transition(.opacity.combined(with: .move(edge: .top)))

                    // MARK: - Status Card
                    StatusCard(order: order)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Group {
                    // MARK: - Live Map Card
                    if order.state == .aktuell {
                        LiveMapCard(order: order,
                                    employeeCoordinate: employeeCoordinate,
                                    patientCoordinate: patientCoordinate,
                                    etaText: etaText)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // MARK: - Patient Card
                    if let patient = appState.patients.first(where: { ($0.uid ?? "") == (order.patientId ?? "") }) {
                        PatientCard(patient: patient)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                    }

                    // MARK: - Action Card
                    ActionCard(
                        onEdit: { showEditSheet = true },
                        onComplete: { showCompletionAlert = true },
                        onDelete: { Task { await deleteOrder() } }
                    )
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 32)
            // Keep a single animation to reduce type complexity
            .animation(.easeInOut(duration: 0.35), value: order.state)
        }
        .scrollContentBackground(.hidden)
    }

    private var processingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            ProgressView("Wird aktualisiert …")
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 6)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [CCDesign.accent.opacity(0.23), CCDesign.card.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 74, height: 74)
                        .shadow(color: CCDesign.accent.opacity(0.17), radius: 7, x: 0, y: 3)
                    Image(systemName: "person.text.rectangle.fill")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(CCDesign.accent)
                }
                VStack(alignment: .leading, spacing: 5) {
                    Text(order.patientName ?? "Unbekannter Patient")
                        .font(.title3.bold())
                        .foregroundStyle(CCDesign.textPrimary)
                    Text("Patientenauftrag")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !order.description.isEmpty {
                        let desc = order.description
                        Text(desc)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                }
                Spacer()
            }
            if let notes = order.notes, !notes.isEmpty {
                Text(notes.joined(separator: ", "))
                    .font(.body)
                    .foregroundStyle(CCDesign.textPrimary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(
                            colors: [CCDesign.card.opacity(0.92), CCDesign.accent.opacity(0.09)],
                            startPoint: .top, endPoint: .bottom)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        CCDesign.accent.opacity(0.10),
                        CCDesign.card.opacity(0.96)
                    ],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 18))
                CCDesign.card.opacity(0.92)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.clear],
                    startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.07), radius: 7, x: 0, y: 3)
    }

    // MARK: - Status
    private var statusSection: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(order.state.color.opacity(0.16))
                    .frame(width: 54, height: 54)
                    .shadow(color: order.state.color.opacity(0.24), radius: 10, x: 0, y: 0)
                Image(systemName: icon(for: order.state))
                    .foregroundStyle(order.state.color)
                    .font(.system(size: 28, weight: .semibold))
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Status")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(order.state.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(order.state.color)
            }
            Spacer()
        }
        .padding(16)
        .background(
            ZStack {
                CCDesign.card.opacity(0.93)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                LinearGradient(
                    colors: [order.state.color.opacity(0.07), Color.clear],
                    startPoint: .topLeading, endPoint: .bottomTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: order.state.color.opacity(0.08), radius: 6, x: 0, y: 3)
    }

    // MARK: - Live Map Section
    private var liveMapSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: "location.circle.fill")
                    .foregroundStyle(.blue)
                Text("Mitarbeiter ist unterwegs")
                    .font(.title3.bold())
                    .foregroundStyle(CCDesign.textPrimary)
                Spacer()
                if let etaText {
                    Text(etaText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .transition(.opacity)
                }
            }
            ZStack(alignment: .top) {
                Map(coordinateRegion: $region, annotationItems: mapAnnotations()) { item in
                    MapMarker(coordinate: item.coordinate, tint: item.tint)
                }
                .frame(height: 240)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(CCDesign.accent.opacity(0.10), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.10), radius: 7, x: 0, y: 4)
                LinearGradient(
                    colors: [CCDesign.background.opacity(0.10), Color.clear],
                    startPoint: .top, endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 20))
                if let etaText {
                    Text("Ankunft: \(etaText)")
                        .font(.subheadline.bold())
                        .foregroundStyle(CCDesign.textPrimary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 7)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(12)
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.3), value: etaText)
                }
            }
            HStack {
                Button {
                    if let p = patientCoordinate {
                        let url = URL(string: "http://maps.apple.com/?daddr=\(p.latitude),\(p.longitude)")!
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label("Navigation öffnen", systemImage: "map.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(CCDesign.accent)
                .buttonBorderShape(.roundedRectangle(radius: 16))
            }
        }
        .padding(16)
        .background(
            ZStack {
                CCDesign.card.opacity(0.95)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                LinearGradient(
                    colors: [Color.clear, CCDesign.accent.opacity(0.07)],
                    startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.09), radius: 7, x: 0, y: 4)
    }

    // MARK: - Patientendaten
    private func patientSection(_ patient: Patient) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "person.crop.circle.badge.checkmark")
                    .foregroundStyle(.teal)
                    .font(.system(size: 22, weight: .medium))
                Text("Patientendaten")
                    .font(.title3.bold())
                    .foregroundStyle(CCDesign.textPrimary)
                Spacer()
            }
            .padding(.bottom, 4)
            Divider()
                .padding(.vertical, 6)
            // Name + Alter (modern card design)
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(colors: [CCDesign.accent.opacity(0.25), CCDesign.card.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 56, height: 56)
                        .shadow(color: CCDesign.accent.opacity(0.2), radius: 6, x: 0, y: 3)
                    Image(systemName: "person.fill")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(.white)
                }
                VStack(alignment: .leading, spacing: 4) {
                    Text(patient.name)
                        .font(.title2.bold())
                        .foregroundStyle(CCDesign.textPrimary)
                    if let birthTimestamp = patient.birthDate {
                        let birthDate = birthTimestamp.dateValue()
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.subheadline)
                                .foregroundStyle(CCDesign.accent)
                            Text(birthDate, style: .date)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "clock.badge.checkmark")
                                .font(.subheadline)
                                .foregroundStyle(CCDesign.accent)
                            Text("\(calculateAge(from: birthDate)) Jahre")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(LinearGradient(colors: [CCDesign.card.opacity(0.9), CCDesign.accent.opacity(0.07)], startPoint: .topLeading, endPoint: .bottomTrailing))
            )
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 3)
            .padding(.bottom, 10)
            // Kontakt
            if let phone = patient.phone, !phone.isEmpty {
                Divider().padding(.vertical, 4)
                Button {
                    if let url = URL(string: "tel://" + phone.replacingOccurrences(of: " ", with: "")) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(phone, systemImage: "phone.fill")
                        .font(.body)
                        .foregroundStyle(CCDesign.textPrimary)
                }
                .buttonStyle(.borderedProminent)
                .tint(CCDesign.accent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
            }
            if let email = patient.email, !email.isEmpty {
                Button {
                    if let url = URL(string: "mailto:" + email) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(email, systemImage: "envelope.fill")
                        .font(.body)
                        .foregroundStyle(CCDesign.textPrimary)
                }
                .buttonStyle(.borderedProminent)
                .tint(CCDesign.accent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
            }
            if let addr = addressLine(patient), !addr.isEmpty {
                Button {
                    let encoded = addr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "http://maps.apple.com/?q=" + encoded) {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Label(addr, systemImage: "map.fill")
                        .font(.body)
                        .foregroundStyle(CCDesign.textPrimary)
                        .lineLimit(2)
                }
                .buttonStyle(.borderedProminent)
                .tint(CCDesign.accent)
                .buttonBorderShape(.roundedRectangle(radius: 12))
            }
            // Medikamente
            if let meds = patient.medications, !meds.isEmpty {
                Divider().padding(.vertical, 4)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "pills.fill")
                        .foregroundStyle(.purple)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Medikamente")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCDesign.textPrimary)
                        ForEach(meds) { med in
                            Text("• \(med.name)")
                                .font(.subheadline)
                                .foregroundStyle(CCDesign.textPrimary)
                        }
                    }
                }
            }
            // Allergien
            if let allergies = patient.allergies, !allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Divider().padding(.vertical, 4)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Allergien")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCDesign.textPrimary)
                        Text(allergies)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Vorgeschichte
            if let mh = patient.medicalHistory, !mh.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Divider().padding(.vertical, 4)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "heart.text.square.fill")
                        .foregroundStyle(.red)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Medizinische Vorgeschichte")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCDesign.textPrimary)
                        Text(mh)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Notizen
            if let notes = patient.notes, !notes.isEmpty {
                Divider().padding(.vertical, 4)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "note.text")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Notizen")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCDesign.textPrimary)
                        Text(notes)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            // Historie
            if let history = patient.history, !history.isEmpty {
                Divider().padding(.vertical, 4)
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "clock.arrow.circlepath")
                        .foregroundStyle(.gray)
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Historie")
                            .font(.subheadline.bold())
                            .foregroundStyle(CCDesign.textPrimary)
                        ForEach(history, id: \.self) { entry in
                            Text("• \(entry)")
                                .font(.subheadline)
                                .foregroundStyle(CCDesign.textPrimary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            ZStack {
                LinearGradient(
                    colors: [
                        CCDesign.card.opacity(0.97),
                        CCDesign.accent.opacity(0.09)
                    ],
                    startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                LinearGradient(
                    colors: [Color.clear, CCDesign.accent.opacity(0.05)],
                    startPoint: .top, endPoint: .bottom)
                    .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.07), radius: 6, x: 0, y: 3)
    }

    // MARK: - Aktionen
    private var actionSection: some View {
        VStack(spacing: 14) {
            if order.state == .offen {
                bigButton(title: "Auftrag annehmen", color: CCDesign.accent, icon: "checkmark.circle.fill") {
                    await accept()
                }
                bigButton(title: "Auftrag schließen", color: .red, icon: "xmark.circle.fill") {
                    dismiss()
                }
            } else if order.state == .aktuell {
                bigButton(title: "Auftrag abschließen", color: .green, icon: "checkmark.seal.fill") {
                    showCompletionAlert = true
                }
            } else if order.state == .erledigt {
                Label("Auftrag abgeschlossen", systemImage: "checkmark.seal.fill")
                    .font(.title3.bold())
                    .foregroundStyle(.green)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        ZStack {
                            CCDesign.card.opacity(0.92)
                            LinearGradient(
                                colors: [Color.clear, .green.opacity(0.08)],
                                startPoint: .top, endPoint: .bottom)
                        }
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.green.opacity(0.11), radius: 4, x: 0, y: 2)
                bigButton(title: "Auftrag löschen", color: .red, icon: "trash.fill") {
                    await deleteOrder()
                }
            }
        }
        .padding(16)
        .background(
            CCDesign.card.opacity(0.96)
                .clipShape(RoundedRectangle(cornerRadius: 18))
        )
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
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
                Text(title)
                    .font(.title3.bold())
            }
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .tint(color)
        .buttonBorderShape(.roundedRectangle(radius: 18))
        .shadow(color: color.opacity(0.16), radius: 7, x: 0, y: 3)
        .foregroundStyle(.white)
        .font(.title3.bold())
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
            startLiveTracking()
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

    private func deleteOrder() async {
        guard let id = order.id, !id.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError = true
            errorMessage = "Fehler: Auftrags-ID fehlt oder ist ungültig."
            return
        }

        do {
            try await service.deleteOrder(id: id)
            dismiss()
        } catch {
            showError = true
            errorMessage = "Fehler beim Löschen: \(error.localizedDescription)"
        }
    }

    // MARK: - Statuswechsel auf 'aktuell' bei Ansicht
    private func updateOrderToAktuell() async {
        guard let id = order.id else {
            print("⚠️ Keine Order-ID verfügbar, Statuswechsel nicht möglich.")
            return
        }

        do {
            try await service.updateOrder(id: id, fields: [
                "state": OrderState.aktuell.rawValue,
                "activatedAt": Date()
            ])
            if let index = appState.orders.firstIndex(where: { $0.id == id }) {
                appState.orders[index].state = .aktuell
            }
            startLiveTracking()
            print("✅ Auftrag erfolgreich auf 'aktuell' gesetzt.")
        } catch {
            print("❌ Fehler beim Setzen auf 'aktuell': \(error.localizedDescription)")
        }
    }

    private func icon(for state: OrderState) -> String {
        switch state {
        case .offen: return "tray.full.fill"
        case .aktuell: return "clock.arrow.circlepath"
        case .erledigt: return "checkmark.seal.fill"
        }
    }

    private struct MapPin: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let tint: Color
    }

    private func mapAnnotations() -> [MapPin] {
        var pins: [MapPin] = []
        if let e = employeeCoordinate { pins.append(MapPin(coordinate: e, tint: .blue)) }
        if let p = patientCoordinate { pins.append(MapPin(coordinate: p, tint: .green)) }
        return pins
    }

    private func addressLine(_ patient: Patient) -> String? {
        let addr = [patient.address ?? "", patient.city ?? ""].filter{ !$0.isEmpty }.joined(separator: ", ")
        return addr.isEmpty ? nil : addr
    }

    // MARK: - Live Tracking
    private func startLiveTracking() {
        preparePatientCoordinate()
        guard let employeeId = order.assignedTo,
              !employeeId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("⚠️ Kein gültiger Mitarbeiter für Live-Tracking vorhanden.")
            return
        }

        let db = Firestore.firestore()
        locationListener = db.collection("employeeLocations").document(employeeId).addSnapshotListener { snap, _ in
            guard let data = snap?.data(),
                  let lat = data["lat"] as? CLLocationDegrees,
                  let lon = data["lon"] as? CLLocationDegrees else { return }
            let coord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            employeeCoordinate = coord
            updateRegion()
            updateETA()
        }
    }

    private func stopLiveTracking() {
        locationListener?.remove()
        locationListener = nil
    }

    private func preparePatientCoordinate() {
        guard patientCoordinate == nil else { return }
        if let patient = appState.patients.first(where: { ($0.uid ?? "") == (order.patientId ?? "") }), let line = addressLine(patient) {
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(line) { placemarks, _ in
                if let loc = placemarks?.first?.location?.coordinate {
                    patientCoordinate = loc
                    updateRegion()
                    updateETA()
                }
            }
        }
    }

    private func updateRegion() {
        let coords = [employeeCoordinate, patientCoordinate].compactMap { $0 }
        guard !coords.isEmpty else { return }
        if coords.count == 1 {
            region.center = coords[0]
        } else {
            let lats = coords.map { $0.latitude }
            let lons = coords.map { $0.longitude }
            let mid = CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2.0, longitude: (lons.min()! + lons.max()!) / 2.0)
            region.center = mid
            region.span = MKCoordinateSpan(latitudeDelta: abs(lats.max()! - lats.min()!) + 0.1, longitudeDelta: abs(lons.max()! - lons.min()!) + 0.1)
        }
    }

    private func updateETA() {
        guard let start = employeeCoordinate, let end = patientCoordinate else { return }
        let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: start))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: end))
        req.transportType = .automobile
        let dir = MKDirections(request: req)
        dir.calculateETA { resp, _ in
            if let eta = resp?.expectedArrivalDate {
                let fmt = DateFormatter()
                fmt.dateFormat = "HH:mm"
                let text = fmt.string(from: eta)
                etaText = text
            }
        }
    }
}

private func calculateAge(from birthDate: Date) -> Int {
    let now = Date()
    let calendar = Calendar.current
    let ageComponents = calendar.dateComponents([.year, .month, .day], from: birthDate, to: now)
    return ageComponents.year ?? 0
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

