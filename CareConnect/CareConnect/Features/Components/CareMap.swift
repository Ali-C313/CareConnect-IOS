//
//  CareMap.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI
import MapKit

/// Karte mit abgerundeten Ecken, ohne Marker kommt ein Platzhalter.
/// Mitarbeiter wird als Auto gezeigt, die Route als blaue Linie.
struct CareMap: View {
    let markers: [MapMarker]
    var route: [CLLocationCoordinate2D] = []
    var height: CGFloat = 220
    var emptyText: String = tr("Standort wird abgerufen…")
    var isLoading = true

    @State private var position: MapCameraPosition = .automatic

    var body: some View {
        Group {
            if markers.isEmpty {
                VStack(spacing: 12) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "location.slash").foregroundColor(.secondary)
                    }
                    Text(emptyText)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(CCDesign.field)
            } else {
                map
            }
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var map: some View {
        Map(position: $position) {
            ForEach(markers) { marker in
                if marker.isEmployee {
                    Annotation(marker.title, coordinate: marker.coordinate) {
                        Image(systemName: "car.fill")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Circle().fill(.blue))
                    }
                } else {
                    Marker(marker.title, systemImage: "house.fill", coordinate: marker.coordinate)
                        .tint(.red)
                }
            }
            if route.count >= 2 {
                MapPolyline(coordinates: route)
                    .stroke(.blue, lineWidth: 6)
            }
        }
        // Auto gleitet zur neuen Position
        .animation(.easeInOut(duration: 1.5), value: markers)
        // Neu einpassen, wenn Marker oder Route dazukommen
        .onChange(of: markers.count) { position = .automatic }
        .onChange(of: route.count >= 2) { position = .automatic }
    }
}

#Preview {
    CareMap(markers: [MapMarker(title: "Patient", coordinate: CLLocationCoordinate2D(latitude: 52.52, longitude: 13.40))])
        .padding()
}
