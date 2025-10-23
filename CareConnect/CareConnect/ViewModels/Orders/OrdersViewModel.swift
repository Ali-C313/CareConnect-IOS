//
//  OrdersViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import Combine

@MainActor
final class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var selectedState: OrderState = .aktuell
    
    private let service: FirebaseServiceType = FirebaseLiveService()
    
    // Sichtbare Liste (24h-Regel für erledigte)
    var filtered: [Order] {
        let now = Date()
        return orders
            .filter { o in
                if o.state != selectedState { return false }
                if o.state == .erledigt {
                    // nur 24h sichtbar
                    return (o.date.addingTimeInterval(24*60*60) > now)
                }
                return true
            }
            .sorted { $0.date > $1.date }
    }
    
    func count(for state: OrderState) -> Int {
        let now = Date()
        return orders.filter { o in
            if o.state != state { return false }
            if o.state == .erledigt {
                return (o.date.addingTimeInterval(24*60*60) > now)
            }
            return true
        }.count
    }
    
    func load() async {
        do {
            orders = try await service.fetchOrders()
        } catch {
            print("❌ Fehler beim Laden der Aufträge:", error.localizedDescription)
        }
    }
    
    // MARK: - Aktionen
    func acceptOrder(_ order: Order, by employeeId: String) async {
        guard let id = order.id else { return }
        do {
            try await service.updateOrder(id: id, fields: [
                "state": OrderState.aktuell.rawValue,
                "employeeId": employeeId,
                "date": Date()  // Zeitpunkt der Übernahme
            ])
            await load()
        } catch {
            print("❌ Fehler beim Annehmen:", error.localizedDescription)
        }
    }
    
    func completeOrder(_ order: Order) async {
        guard let id = order.id else { return }
        do {
            try await service.updateOrder(id: id, fields: [
                "state": OrderState.erledigt.rawValue,
                "date": Date()  // Zeitpunkt der Fertigstellung (für 24h-Regel)
            ])
            await load()
        } catch {
            print("❌ Fehler beim Abschließen:", error.localizedDescription)
        }
    }
    
    // (optional) IDs zu Namen auflösen – hier können später Caches/Lookups rein
    func employeeName(for id: String) -> String { id.replacingOccurrences(of: "_", with: " ") }
    func patientName(for id: String) -> String { id.replacingOccurrences(of: "_", with: " ") }
}
