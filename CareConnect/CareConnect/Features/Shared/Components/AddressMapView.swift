//
//  AddressMapView.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AddressMapView: View {
    /// Adresse
    var address: String?
    /// Titel
    var title: String?
    
    /// Kartenregion
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    /// Kartenmarkierung
    @State private var annotation: IdentifiableAnnotation?
    /// Geokodierung aktiv
    @State private var isGeocoding = false
    
    /// UI-Inhalt
    var body: some View {
        ZStack {
            Map(position: .constant(.region(region))) {
                if let wrapped = annotation {
                    Marker(wrapped.annotation.title ?? "Ort", coordinate: wrapped.annotation.coordinate)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(RoundedRectangle(cornerRadius: 16).strokeBorder(.white.opacity(0.12), lineWidth: 1))
            .task { await geocodeIfNeeded() }
            
            if isGeocoding {
                ProgressView().padding().background(.ultraThinMaterial).clipShape(Capsule())
            }
        }
        .padding(.horizontal)
    }
    
    /// Adresse suchen
    @MainActor
    private func geocodeIfNeeded() async {
        guard let address, !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            let a = MKPointAnnotation()
            a.coordinate = region.center
            a.title = title ?? "Berlin"
            annotation = IdentifiableAnnotation(annotation: a)
            return
        }
        isGeocoding = true
        defer { isGeocoding = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = address
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            if let item = response.mapItems.first {
                let loc = item.location.coordinate
                region.center = loc
                let a = MKPointAnnotation()
                a.coordinate = loc
                a.title = title ?? item.name ?? address
                annotation = IdentifiableAnnotation(annotation: a)
            } else {
                let a = MKPointAnnotation()
                a.coordinate = region.center
                a.title = title ?? "Berlin"
                annotation = IdentifiableAnnotation(annotation: a)
            }
        } catch {
            let a = MKPointAnnotation()
            a.coordinate = region.center
            a.title = title ?? "Berlin"
            annotation = IdentifiableAnnotation(annotation: a)
        }
    }
}

/// Identifizierbare Annotation
struct IdentifiableAnnotation: Identifiable {
    let id = UUID()
    let annotation: MKPointAnnotation
}

#Preview {
    AddressMapView()
}
