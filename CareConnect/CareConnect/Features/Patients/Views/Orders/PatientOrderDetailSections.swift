//
//  PatientOrderDetailSections.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import CoreLocation

/// Karte mit Mitarbeiter und Ankunftszeit, vorher wird einmal gefragt
struct LiveSection: View {
    let showLiveLocation: Bool?
    let employeeCoordinate: CLLocationCoordinate2D?
    let homeCoordinate: CLLocationCoordinate2D?
    let route: RouteInfo?
    let onAllow: () -> Void
    let onDeny: () -> Void

    private var markers: [MapMarker] {
        var list: [MapMarker] = []
        if let employeeCoordinate {
            list.append(MapMarker(title: tr("Mitarbeiter"), coordinate: employeeCoordinate, isEmployee: true))
        }
        if let homeCoordinate {
            list.append(MapMarker(title: tr("Ankunft"), coordinate: homeCoordinate))
        }
        return list
    }

    var body: some View {
        SectionCard(title: tr("Live-Standort"), icon: "location.fill") {
            if showLiveLocation == true {
                CareMap(markers: markers, route: route?.path ?? [], height: 300, emptyText: tr("Karte wird geladen…"))
                if employeeCoordinate == nil {
                    Text(tr("Der Standort des Mitarbeiters erscheint, sobald er unterwegs ist und das Teilen erlaubt hat."))
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                if let route {
                    let arrival = Date().addingTimeInterval(route.durationSeconds)
                    HStack(spacing: 16) {
                        InfoRow(system: "ruler", title: tr("Entfernung"), value: route.distanceMeters.kmString)
                        InfoRow(system: "car.fill", title: tr("Ankunft"),
                                value: tr("{0} Uhr ({1})", arrival.formattedTime, route.durationSeconds.minutesString))
                    }
                }
            } else {
                Text(tr("Live-Standort anzeigen?")).font(.headline)
                Text(showLiveLocation == false
                     ? tr("Du hast den Live-Standort ausgeschaltet.")
                     : tr("Du siehst auf der Karte, wo dein Mitarbeiter gerade ist und wann er ungefähr ankommt. Dafür wird deine Adresse für die Route verwendet."))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                HStack {
                    Button(tr("Anzeigen"), action: onAllow).buttonStyle(.borderedProminent)
                    if showLiveLocation == nil {
                        Button(tr("Nein danke"), action: onDeny).buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

/// Erstellt → Angenommen → Erledigt
struct StatusTimeline: View {
    let order: Order

    var body: some View {
        SectionCard(title: tr("Status"), icon: "list.bullet.indent") {
            step(title: tr("Erstellt"), subtitle: order.createdAt?.formattedDateTime, done: true)
            step(title: tr("Angenommen"), subtitle: nil, done: order.state != .offen)
            step(title: tr("Erledigt"), subtitle: order.report?.completedAt?.formattedDateTime, done: order.state == .erledigt)
        }
    }

    private func step(title: String, subtitle: String?, done: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: done ? "checkmark.circle.fill" : "circle")
                .foregroundColor(done ? .green : .secondary)
            VStack(alignment: .leading) {
                Text(title)
                    .fontWeight(done ? .semibold : .regular)
                    .foregroundColor(done ? CCDesign.textPrimary : .secondary)
                if let subtitle {
                    Text(subtitle).font(.footnote).foregroundColor(.secondary)
                }
            }
        }
    }
}

/// Zuständiger Mitarbeiter mit Kontakt
struct EmployeeSection: View {
    @Environment(\.openURL) private var openURL
    let employee: Employee?

    var body: some View {
        SectionCard(title: tr("Mitarbeiter"), icon: "person") {
            InfoRow(system: "person", title: tr("Mitarbeiter"),
                    value: (employee?.name ?? "").ifBlank(tr("Unbekannt")))
            // Mitarbeiter haben keine Telefonnummer in Firestore, deshalb E-Mail
            if let email = employee?.email, !email.isBlank {
                InfoButtonRow(system: "envelope", title: tr("Kontakt"), value: email,
                              buttonTitle: tr("Kontaktieren"), buttonIcon: "envelope.fill") {
                    if let url = Links.mail(email) { openURL(url) }
                }
            }
        }
    }
}

/// Leistungsnachweis aus Sicht des Patienten
struct PatientReportCard: View {
    let report: CompletionReport

    private var info: String {
        [report.completedByName.isBlank ? nil : tr("Erledigt von {0}", report.completedByName),
         report.completedAt?.formattedDateTime]
            .compactMap { $0 }
            .joined(separator: " · ")
    }

    var body: some View {
        SectionCard(title: tr("Leistungsnachweis"), icon: "doc.plaintext") {
            if !report.note.isBlank { Text(report.note) }
            if !info.isEmpty {
                Text(info).font(.footnote).foregroundColor(.secondary)
            }
            if !report.signature.isBlank {
                Text(tr("Unterschrift")).font(.caption)
                SignatureView(signature: report.signature)
                if !report.signedBy.isBlank {
                    Text(report.signedBy).font(.footnote)
                }
            }
        }
    }
}
