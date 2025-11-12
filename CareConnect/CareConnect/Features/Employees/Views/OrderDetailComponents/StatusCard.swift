//
//  StatusCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 12.11.25.
//

import SwiftUI
import FirebaseFirestore

struct StatusCard: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Status")
                    .font(.headline)
            } icon: {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.accentColor)
            }

            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                Text(statusText)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(statusColor)
            }

            Divider()

            if let createdAt = (order.createdAt as? Date) ?? (order.createdAt as? Timestamp)?.dateValue() {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                    Text("Erstellt am \(createdAt.formatted(date: .abbreviated, time: .shortened))")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }

            if let dueDate = (order.dueDate as? Date) ?? (order.dueDate as? Timestamp)?.dateValue() {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text("Fällig am \(dueDate.formatted(date: .abbreviated, time: .shortened))")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .shadow(radius: 3)
        )
        .padding(.horizontal)
    }

    private var statusText: String {
        switch order.state {
        case .offen: return "Offen"
        case .aktuell: return "Aktuell"
        case .erledigt: return "Erledigt"
        }
    }

    private var statusColor: Color {
        switch order.state {
        case .offen: return .orange
        case .aktuell: return .blue
        case .erledigt: return .green
        }
    }

    private var statusIcon: String {
        switch order.state {
        case .offen: return "clock.badge.questionmark"
        case .aktuell: return "hammer.fill"
        case .erledigt: return "checkmark.seal.fill"
        }
    }
}

#Preview {
    Text("StatusCard Preview")
        .foregroundColor(.secondary)
}
