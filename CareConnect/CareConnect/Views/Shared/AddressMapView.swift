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
    var address: String?
    var title: String?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var annotation: MKPointAnnotation?
    @State private var isGeocoding = false
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: annotation.map { [$0] } ?? []) { point in
                MapMarker(coordinate: point.coordinate)
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
    
    @MainActor
    private func geocodeIfNeeded() async {
        guard let address, !address.trimmingCharacters(in: .whitespaces).isEmpty else {
            let a = MKPointAnnotation()
            a.coordinate = region.center
            a.title = title ?? "Berlin"
            annotation = a
            return
        }
        isGeocoding = true
        defer { isGeocoding = false }
        
        let geocoder = CLGeocoder()
        do {
            let placemarks = try await geocoder.geocodeAddressString(address)
            if let loc = placemarks.first?.location?.coordinate {
                region.center = loc
                let a = MKPointAnnotation()
                a.coordinate = loc
                a.title = title ?? address
                annotation = a
            }
        } catch {
            let a = MKPointAnnotation()
            a.coordinate = region.center
            a.title = title ?? "Berlin"
            annotation = a
        }
    }
}

extension MKPointAnnotation: Identifiable {
    public var id: String { "\(coordinate.latitude)-\(coordinate.longitude)-\(title ?? "")" }
}

#Preview {
    AddressMapView()
}
