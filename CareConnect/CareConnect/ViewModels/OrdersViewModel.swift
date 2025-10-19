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
    private let service: FirebaseServiceType

    init(service: FirebaseServiceType = FirebaseMockService()) {
        self.service = service
    }

    func load() async {
        do { orders = try await service.fetchOrders() }
        catch { print("Fehler Aufträge: \(error)") }
    }

    var filtered: [Order] {
        orders.filter { $0.state == selectedState }
    }
}
