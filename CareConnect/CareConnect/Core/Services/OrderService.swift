//
//  OrderService.swift
//  CareConnect
//
//  Created by Ali Chehab on 10.11.25.
//

import Foundation
import FirebaseFirestore
import CoreLocation
import Combine

// MARK: - OrderService
@MainActor
final class OrderService: ObservableObject {
    @Published var orders: [OrderDisplayModel] = []
    private var listener: ListenerRegistration?
    private let db = Firestore.firestore()
    
    init() {
        listenToOrders()
    }
    
    deinit {
        listener?.remove()
    }
    
    // MARK: - Start listening to all orders
    private func listenToOrders() {
        listener = db.collection("orders").addSnapshotListener { [weak self] snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                print("❌ Fehler beim Abrufen der Orders: \(error?.localizedDescription ?? "Unbekannt")")
                return
            }
            
            Task {
                var loadedOrders: [OrderDisplayModel] = []
                for doc in documents {
                    do {
                        let order = try doc.data(as: Order.self)
                        let display = await self?.buildOrderDisplayModel(for: order)
                        if let display = display {
                            loadedOrders.append(display)
                        }
                    } catch {
                        print("⚠️ Fehler beim Dekodieren von Order: \(error.localizedDescription)")
                    }
                }
                self?.orders = loadedOrders.sorted { ($0.dueDate ?? .distantPast) > ($1.dueDate ?? .distantPast) }
            }
        }
    }
    
    // MARK: - Build combined display model with employee/patient data
    private func buildOrderDisplayModel(for order: Order) async -> OrderDisplayModel {
        async let employee = fetchEmployee(by: order.employeeId ?? order.createdBy)
        async let patient = fetchPatient(by: order.assignedTo)
        async let location = fetchEmployeeLocation(for: order.createdBy)
        
        let (emp, pat, loc) = await (employee, patient, location)
        
        return OrderDisplayModel(
            id: order.id ?? UUID().uuidString,
            description: order.description ?? "",
            // order.state is not optional, access .rawValue directly
            state: order.state.rawValue,
            createdBy: emp != nil ? "\(emp!.firstName) \(emp!.lastName)" : "Unbekannt",
            patientName: pat?.firstName != nil ? "\(pat!.firstName!) \(pat!.lastName ?? "")" : (order.patientName ?? "Unbekannt"),
            createdAt: order.createdAt?.dateValue(),
            dueDate: order.dueDate?.dateValue(),
            employeeLocation: loc,
            patientAddress: pat?.address ?? ""
        )
    }
    
    // MARK: - Fetch helpers
    private func fetchEmployee(by uid: String?) async -> Employee? {
        guard let uid else { return nil }
        do {
            let doc = try await db.collection("employees").document(uid).getDocument()
            return try doc.data(as: Employee.self)
        } catch {
            print("⚠️ Fehler beim Laden von Employee: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchPatient(by uid: String?) async -> Patient? {
        guard let uid else { return nil }
        do {
            let doc = try await db.collection("patients").document(uid).getDocument()
            return try doc.data(as: Patient.self)
        } catch {
            print("⚠️ Fehler beim Laden von Patient: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func fetchEmployeeLocation(for uid: String?) async -> CLLocationCoordinate2D? {
        guard let uid else { return nil }
        do {
            let doc = try await db.collection("employeeLocations").document(uid).getDocument()
            if let data = doc.data(),
               let lat = data["lat"] as? Double,
               let lon = data["lon"] as? Double {
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
        } catch {
            print("⚠️ Fehler beim Laden von Standort: \(error.localizedDescription)")
        }
        return nil
    }
}
