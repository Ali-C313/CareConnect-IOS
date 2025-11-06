//
//  PatientOrdersViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import Foundation
import FirebaseFirestore
import Combine
import CoreLocation
import SwiftUI

struct PatientOrderDisplayModel: Identifiable {
    let id: String
    let title: String
    let description: String
    let state: String
    let date: Date
    // Zusatzfelder für die Anzeige
    let employeeName: String
    let employeePhone: String
    let employeeLocation: CLLocationCoordinate2D?
    let etaFormatted: String
    let statusText: String
    let statusColor: Color

    var dateFormatted: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

class PatientOrdersViewModel: ObservableObject {
    @Published var activeOrder: PatientOrderDisplayModel?
    @Published var openOrders: [PatientOrderDisplayModel] = []
    @Published var historyOrders: [PatientOrderDisplayModel] = []
    @Published var employeeLocation: CLLocation?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var db = Firestore.firestore()
    private var ordersListener: ListenerRegistration?
    private var employeeLocationListener: ListenerRegistration?

    func loadOrders(for userId: String) {
        isLoading = true
        errorMessage = nil

        ordersListener?.remove()
        ordersListener = db.collection("orders")
            .whereField("patientId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false

                if let error = error {
                    self.errorMessage = "Fehler beim Laden der Aufträge: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents else {
                    self.errorMessage = "Keine Aufträge gefunden."
                    self.activeOrder = nil
                    self.openOrders = []
                    self.historyOrders = []
                    return
                }

                var active: PatientOrderDisplayModel?
                var open: [PatientOrderDisplayModel] = []
                var history: [PatientOrderDisplayModel] = []

                for doc in documents {
                    let data = doc.data()
                    let id = doc.documentID
                    let title = data["title"] as? String ?? "Unbekannter Auftrag"
                    let description = data["description"] as? String ?? ""
                    let state = data["state"] as? String ?? ""
                    let timestamp = data["date"] as? Timestamp
                    let date = timestamp?.dateValue() ?? Date()

                    // Neue Felder aus Firestore oder Fallbacks
                    let employeeName = data["employeeName"] as? String ?? "Unbekannt"
                    let employeePhone = data["employeePhone"] as? String ?? ""
                    var employeeLocation: CLLocationCoordinate2D? = nil
                    if let lat = data["employeeLatitude"] as? CLLocationDegrees,
                       let lon = data["employeeLongitude"] as? CLLocationDegrees {
                        employeeLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                    }
                    let etaFormatted = data["etaFormatted"] as? String ?? ""

                    // Statusanzeige abhängig vom State
                    let statusText: String
                    let statusColor: Color
                    switch state.lowercased() {
                    case "aktuell":
                        statusText = "Aktuell"
                        statusColor = .blue
                    case "offen":
                        statusText = "Offen"
                        statusColor = .orange
                    case "erledigt":
                        statusText = "Erledigt"
                        statusColor = .green
                    default:
                        statusText = state
                        statusColor = .gray
                    }

                    let order = PatientOrderDisplayModel(
                        id: id,
                        title: title,
                        description: description,
                        state: state,
                        date: date,
                        employeeName: employeeName,
                        employeePhone: employeePhone,
                        employeeLocation: employeeLocation,
                        etaFormatted: etaFormatted,
                        statusText: statusText,
                        statusColor: statusColor
                    )

                    switch state.lowercased() {
                    case "aktuell":
                        active = order
                    case "offen":
                        open.append(order)
                    case "erledigt":
                        history.append(order)
                    default:
                        break
                    }
                }

                self.activeOrder = active
                self.openOrders = open.sorted { $0.date > $1.date }
                self.historyOrders = history.sorted { $0.date > $1.date }
            }
    }

    func startEmployeeLocationListener(for employeeId: String) {
        employeeLocationListener?.remove()
        employeeLocationListener = db.collection("employeeLocations").document(employeeId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    self.errorMessage = "Fehler beim Laden der Mitarbeiter-Position: \(error.localizedDescription)"
                    return
                }

                guard let data = snapshot?.data(),
                      let lat = data["latitude"] as? CLLocationDegrees,
                      let lon = data["longitude"] as? CLLocationDegrees else {
                    self.employeeLocation = nil
                    return
                }

                self.employeeLocation = CLLocation(latitude: lat, longitude: lon)
            }
    }

    deinit {
        ordersListener?.remove()
        employeeLocationListener?.remove()
    }
}
