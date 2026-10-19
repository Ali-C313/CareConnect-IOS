//
//  OrderNotifier.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Vergleicht neue Listen mit dem letzten Stand und meldet, was sich geändert hat.
/// Der erste Stand gilt als bekannt, gemeldet wird nur, was danach passiert.
final class OrderNotifier {
    private let notifications = NotificationManager.shared

    private var knownOrderIds: Set<String>?
    private var knownPrescriptionIds: Set<String>?
    private var knownMyOrders: [String: Order]?

    /// Beim Logout oder Wechsel der Organisation alles vergessen
    func reset() {
        knownOrderIds = nil
        knownPrescriptionIds = nil
        knownMyOrders = nil
    }

    // MARK: - Mitarbeiter

    /// Neue freie oder mir zugewiesene Aufträge
    func ordersChanged(_ orders: [Order], uid: String, allowed: Bool) {
        let before = knownOrderIds
        if let before, !before.isEmpty, orders.isEmpty { return }
        knownOrderIds = Set(orders.map(\.id))
        guard let before, allowed else { return }

        let fresh = orders.filter { order in
            !before.contains(order.id) &&
                order.createdBy != uid &&
                order.state == .offen &&
                (order.assignedEmployeeId.isEmpty || order.assignedEmployeeId == uid)
        }
        if fresh.count == 1, let order = fresh.first {
            let text = [order.patientName ?? "", order.description].filter { !$0.isBlank }.joined(separator: ": ")
            notifications.show(
                id: "order-\(order.id)",
                title: order.assignedEmployeeId == uid ? tr("Neuer Auftrag für dich") : tr("Neuer Auftrag"),
                text: text.ifBlank(order.displayTitle)
            )
        } else if fresh.count > 1 {
            let names = Set(fresh.compactMap(\.patientName).filter { !$0.isBlank })
            notifications.show(
                id: "orders-\(fresh[0].id)",
                title: tr("{0} neue Aufträge", fresh.count),
                text: names.sorted().joined(separator: ", ")
            )
        }
    }

    /// Neue Verordnungen an unseren Pflegedienst
    func prescriptionsChanged(_ list: [Prescription], orgId: String, allowed: Bool) {
        let incoming = list.filter { $0.toOrgId == orgId && $0.status == .offen }
        let before = knownPrescriptionIds
        knownPrescriptionIds = (before ?? []).union(incoming.compactMap(\.id))
        guard let before, allowed else { return }

        for prescription in incoming where !before.contains(prescription.id ?? "") {
            notifications.show(
                id: "prescription-\(prescription.id ?? "")",
                title: tr("Neue Verordnung von {0}", prescription.fromOrgName),
                text: tr("{0} für {1}", prescription.title, prescription.patientName)
            )
        }
    }

    // MARK: - Patient

    /// Änderungen an den eigenen Aufträgen
    func myOrdersChanged(_ orders: [Order], uid: String, allowed: Bool, employeeName: (String) -> String) {
        let before = knownMyOrders
        if let before, !before.isEmpty, orders.isEmpty { return }
        let now = Dictionary(orders.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        knownMyOrders = now
        guard let before, allowed else { return }

        for order in orders {
            let what = order.description.ifBlank(order.displayTitle)
            guard let old = before[order.id] else {
                if order.createdBy != uid {
                    let date = order.dueDate.map { tr(" am {0}", $0.formattedDateTime) } ?? ""
                    notifications.show(id: "order-\(order.id)", title: tr("Neuer Termin geplant"), text: what + date)
                }
                continue
            }
            if old.state != order.state {
                stateChanged(order, what: what, employeeName: employeeName)
            } else if old.description != order.description || old.dueDate != order.dueDate {
                let date = order.dueDate.map { " – \($0.formattedDateTime)" } ?? ""
                notifications.show(id: "order-\(order.id)-geaendert", title: tr("Auftrag geändert"), text: what + date)
            }
        }
        for (id, old) in before where now[id] == nil && old.state != .erledigt {
            notifications.show(
                id: "order-\(id)-geloescht",
                title: tr("Auftrag abgesagt"),
                text: old.description.ifBlank(old.displayTitle)
            )
        }
    }

    private func stateChanged(_ order: Order, what: String, employeeName: (String) -> String) {
        switch order.state {
        case .aktuell:
            notifications.show(
                id: "order-\(order.id)-aktuell",
                title: tr("Auftrag angenommen"),
                text: tr("{0} kümmert sich um: {1}", employeeName(order.assignedEmployeeId), what)
            )
        case .erledigt:
            notifications.show(id: "order-\(order.id)-erledigt", title: tr("Auftrag erledigt"), text: what)
        case .offen:
            notifications.show(id: "order-\(order.id)-offen", title: tr("Auftrag wieder offen"), text: what)
        }
    }
}
