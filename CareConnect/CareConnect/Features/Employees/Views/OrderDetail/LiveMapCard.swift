//
//  LiveMapCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import MapKit

/// Karte mit Mitarbeiter (Auto) und Patient, dazu Ankunftszeit
struct LiveMapCard: View {
    var employeeCoordinate: CLLocationCoordinate2D?
    var patientCoordinate: CLLocationCoordinate2D?
    var route: RouteInfo?

    @Environment(\.openURL) private var openURL

    private var markers: [MapMarker] {
        var list: [MapMarker] = []
        if let patientCoordinate { list.append(MapMarker(title: tr("Patient"), coordinate: patientCoordinate)) }
        if let employeeCoordinate {
            list.append(MapMarker(title: tr("Mitarbeiter"), coordinate: employeeCoordinate, isEmployee: true))
        }
        return list
    }

    var body: some View {
        SectionCard(title: tr("Live Karte"), icon: "map.fill") {
            CareMap(markers: markers, route: route?.path ?? [])

            if let route {
                let arrival = Date().addingTimeInterval(route.durationSeconds)
                InfoRow(
                    system: "car.fill",
                    title: tr("Voraussichtliche Ankunft"),
                    value: tr("{0} Uhr ({1}, {2})", arrival.formattedTime, route.durationSeconds.minutesString,
                              route.distanceMeters.kmString)
                )
            }

            if let patientCoordinate {
                Button {
                    if let url = Links.directions(to: patientCoordinate) { openURL(url) }
                } label: {
                    Label(tr("Navigation öffnen"), systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(CCDesign.accent)
            }
        }
    }
}

#Preview {
    LiveMapCard(
        employeeCoordinate: CLLocationCoordinate2D(latitude: 52.50, longitude: 13.40),
        patientCoordinate: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.42)
    )
    .padding()
}
