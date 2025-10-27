//
//  OrdersViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import Foundation
import Combine
import FirebaseCore

@MainActor
final class OrdersViewModel: ObservableObject {
    @Published var orders: [Order] = []
    @Published var selectedState: OrderState = .aktuell
    @Published var errorMessage: String? = nil
    @Published var showError: Bool = false
    private let repository = FirebaseOrderRepository()
    
    // Sichtbare Liste (24h-Regel für erledigte)
    var filtered: [Order] {
        let now = Date()
        return orders
            .filter { o in
                switch selectedState {
                case .aktuell:
                    return o.state == .aktuell
                case .offen:
                    return o.state == .offen
                case .erledigt:
                    return o.state == .erledigt
                }
            }
            .sorted { ($0.createdAt?.dateValue() ?? .distantPast) > ($1.createdAt?.dateValue() ?? .distantPast) }
    }
    
    func filteredOrders(_ state: OrderState) -> [Order] {
        let now = Date()
        return orders
            .filter { o in
                switch state {
                case .aktuell:
                    return o.state == .aktuell
                case .offen:
                    return o.state == .offen
                case .erledigt:
                    return o.state == .erledigt
                }
            }
            .sorted { ($0.createdAt?.dateValue() ?? .distantPast) > ($1.createdAt?.dateValue() ?? .distantPast) }
    }
    
    func count(for state: OrderState) -> Int {
        let now = Date()
        return orders.filter { o in
            switch state {
            case .aktuell:
                return o.state == .aktuell
            case .offen:
                return o.state == .offen
            case .erledigt:
                return o.state == .erledigt
            }
        }.count
    }
    
    // Wird durch Live-Listener ersetzt
    func startListening() {
        repository.listenToAllOrders { [weak self] items in
            DispatchQueue.main.async {
                self?.orders = items
            }
        } onError: { [weak self] err in
            DispatchQueue.main.async {
                self?.errorMessage = err.localizedDescription
                self?.showError = true
            }
        }
    }
    
    func stopListening() {
        repository.stopListening()
    }
    
    // (optional) IDs zu Namen auflösen – hier können später Caches/Lookups rein
    func employeeName(for id: String) -> String { id.replacingOccurrences(of: "_", with: " ") }
    func patientName(for id: String) -> String { id.replacingOccurrences(of: "_", with: " ") }
}
