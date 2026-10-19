//
//  SmallViews.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Statistik-Kachel auf dem Home-Screen (Offen / Aktuell / Erledigt)
struct StatTile: View {
    let value: Int
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            Text("\(value)")
                .font(.system(size: 26, weight: .black))
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, minHeight: 110)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(LinearGradient(colors: [CCDesign.card, color.opacity(0.18)], startPoint: .top, endPoint: .bottom))
        )
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(color.opacity(0.3)))
    }
}

/// Farbiges Label, z. B. Status eines Auftrags
struct StatusBadge: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(color.opacity(0.15)))
    }
}

/// Kleine Zeile mit Icon, z. B. Fälligkeit in der Auftragskarte
struct SmallInfo: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.caption)
            .foregroundColor(.secondary)
    }
}

#Preview {
    VStack(spacing: 12) {
        HStack {
            StatTile(value: 3, label: "Offen", icon: "clock", color: .orange)
            StatTile(value: 1, label: "Aktuell", icon: "play.circle.fill", color: .blue)
        }
        StatusBadge(text: "Offen", color: .orange)
        SmallInfo(icon: "calendar", text: "Fällig: 24.12.2025, 14:30")
    }
    .padding()
}
