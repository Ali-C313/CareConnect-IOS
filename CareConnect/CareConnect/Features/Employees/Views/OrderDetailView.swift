//
//  OrderDetailView.swift
//  CareConnect
//
//  Created by Ali Chehab on 21.10.25.
//

import SwiftUI
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

    /// Live-Tracking
    @State private var locationListener: ListenerRegistration?
    @State private var employeeCoordinate: CLLocationCoordinate2D?
    @State private var patientCoordinate: CLLocationCoordinate2D?
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 52.0, longitude: 8.6), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    @State private var etaText: String? = nil

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

                    // MARK: - Live Karte
                    if order.state == .aktuell {
                        liveMapSection
                    }

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
        .onAppear {
            if order.state == .aktuell {
                startLiveTracking()
            } else if order.state == .offen {
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

    // MARK: - Live Map Section
    private var liveMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "location.circle.fill").foregroundColor(.blue)
                Text("Mitarbeiter ist unterwegs")
                    .font(.headline)
                    .foregroundColor(CCDesign.textPrimary)
                Spacer()
                if let etaText { Text(etaText).font(.subheadline).foregroundColor(.secondary) }
            }

            ZStack(alignment: .top) {
                Map(coordinateRegion: $region, annotationItems: mapAnnotations()) { item in
                    MapMarker(coordinate: item.coordinate, tint: item.tint)
                }
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                if let etaText {
                    Text("Ankunft: \(etaText)")
                        .font(.subheadline.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(10)
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
            }
        }
        .padding()
        .background(CCDesign.card)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
    }

    // MARK: - Patientendaten
    private func patientSection(_ patient: Patient) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                        .foregroundColor(.teal)
                        .font(.system(size: 22))
                    Text("Patientendaten")
                        .font(.headline)
                        .foregroundColor(CCDesign.textPrimary)
                    Spacer()
                }

                Divider()

                // Name + Alter
                VStack(alignment: .leading, spacing: 6) {
                    Text(patient.name)
                        .font(.title3.bold())
                    if let age = patient.age { Text("\(age) Jahre").foregroundColor(.secondary) }
                }

                // Kontakt
                VStack(alignment: .leading, spacing: 8) {
                    if let phone = patient.phone, !phone.isEmpty {
                        Button { if let url = URL(string: "tel://" + phone.replacingOccurrences(of: " ", with: "")) { UIApplication.shared.open(url) } } label: {
                            Label(phone, systemImage: "phone.fill")
                        }
                    }
                    if let email = patient.email, !email.isEmpty {
                        Button { if let url = URL(string: "mailto:" + email) { UIApplication.shared.open(url) } } label: {
                            Label(email, systemImage: "envelope.fill")
                        }
                    }
                    if let addr = addressLine(patient), !addr.isEmpty {
                        Button {
                            let encoded = addr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                            if let url = URL(string: "http://maps.apple.com/?q=" + encoded) { UIApplication.shared.open(url) }
                        } label: {
                            Label(addr, systemImage: "map.fill")
                                .lineLimit(2)
                        }
                    }
                }

                // Medikamente
                if let meds = patient.medications, !meds.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Medikamente").font(.subheadline.bold())
                        ForEach(meds) { med in Text("• \(med.name)") }
                    }
                }

                // Allergien
                if let allergies = patient.allergies, !allergies.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Allergien").font(.subheadline.bold())
                        Text(allergies)
                    }
                }

                // Vorgeschichte
                if let mh = patient.medicalHistory, !mh.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Medizinische Vorgeschichte").font(.subheadline.bold())
                        Text(mh)
                    }
                }

                // Notizen
                if let notes = patient.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notizen").font(.subheadline.bold())
                        Text(notes)
                    }
                }

                // Historie
                if let history = patient.history, !history.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Historie").font(.subheadline.bold())
                        ForEach(history, id: \.self) { entry in Text("• \(entry)") }
                    }
                }
            }
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
        guard let employeeId = order.assignedTo else { return }
        let db = Firestore.firestore()
        locationListener = db.collection("employeeLocations").document(employeeId).addSnapshotListener { snap, _ in
            guard let data = snap?.data(), let lat = data["lat"] as? CLLocationDegrees, let lon = data["lon"] as? CLLocationDegrees else { return }
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
        if let patient = appState.patients.first(where: { ($0.uid ?? "") == (order.assignedTo ?? "") }), let line = addressLine(patient) {
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
