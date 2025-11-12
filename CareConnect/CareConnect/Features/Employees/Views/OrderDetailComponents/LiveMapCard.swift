//
//  LiveMapCard.swift
//  CareConnect
//
//  Created by Ali Chehab on 12.11.25.
//

import SwiftUI
import MapKit

struct LiveMapCard: View {
    let order: Order
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 50.1109, longitude: 8.6821), // Default: Frankfurt
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    var employeeCoordinate: CLLocationCoordinate2D?
    var patientCoordinate: CLLocationCoordinate2D?
    var etaText: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("Live Karte")
                    .font(.headline)
            } icon: {
                Image(systemName: "map.fill")
                    .foregroundColor(.accentColor)
            }

            ZStack {
                if let patientCoord = patientCoordinate {
                    Map(coordinateRegion: $region, annotationItems: annotationItems) { item in
                        MapMarker(coordinate: item.coordinate, tint: item.color)
                    }
                    .frame(height: 200)
                    .cornerRadius(12)
                    .onAppear {
                        updateRegion(center: patientCoord)
                    }
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Standort wird abgerufen…")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
            }

            if let eta = etaText {
                HStack {
                    Image(systemName: "figure.walk.motion")
                        .foregroundColor(.green)
                    Text("Voraussichtliche Ankunft: \(eta)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 4)
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

    private var annotationItems: [MapAnnotationItem] {
        var items: [MapAnnotationItem] = []
        if let patientCoord = patientCoordinate {
            items.append(MapAnnotationItem(coordinate: patientCoord, color: .red))
        }
        if let employeeCoord = employeeCoordinate {
            items.append(MapAnnotationItem(coordinate: employeeCoord, color: .blue))
        }
        return items
    }

    private func updateRegion(center: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}

private struct MapAnnotationItem: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color: Color
}

#Preview {
    Text("LiveMapCard Preview")
        .foregroundColor(.secondary)
}
