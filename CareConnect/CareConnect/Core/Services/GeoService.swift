//
//  GeoService.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation
import MapKit

/// Adresse → Koordinate und Route mit Fahrzeit, alles über MapKit (kein API-Key nötig)
final class GeoService {
    func coordinate(for address: String) async -> CLLocationCoordinate2D? {
        guard !address.isBlank else { return nil }
        guard let request = MKGeocodingRequest(addressString: address) else { return nil }
        let items = try? await request.mapItems
        return items?.first?.location.coordinate
    }

    /// Erst Apple-Route, sonst grob geschätzt
    func route(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) async -> RouteInfo {
        let request = MKDirections.Request()
        request.source = MKMapItem(location: CLLocation(latitude: start.latitude, longitude: start.longitude), address: nil)
        request.destination = MKMapItem(location: CLLocation(latitude: end.latitude, longitude: end.longitude), address: nil)
        request.transportType = .automobile

        if let route = try? await MKDirections(request: request).calculate().routes.first {
            let polyline = route.polyline
            var points = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: polyline.pointCount)
            polyline.getCoordinates(&points, range: NSRange(location: 0, length: polyline.pointCount))
            return RouteInfo(distanceMeters: route.distance, durationSeconds: route.expectedTravelTime, path: points)
        }
        return estimate(from: start, to: end)
    }

    /// Luftlinie * 1,3 und ca. 30 km/h in der Stadt
    private func estimate(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> RouteInfo {
        let from = CLLocation(latitude: start.latitude, longitude: start.longitude)
        let target = CLLocation(latitude: end.latitude, longitude: end.longitude)
        let meters = from.distance(from: target) * 1.3
        return RouteInfo(distanceMeters: meters, durationSeconds: meters / (30_000 / 3600), path: [start, end])
    }

    /// Route erst neu holen, wenn sich der Mitarbeiter mindestens 80 m bewegt hat
    static func hasMoved(from old: CLLocationCoordinate2D?, to new: CLLocationCoordinate2D?) -> Bool {
        guard let old, let new else { return true }
        let distance = CLLocation(latitude: old.latitude, longitude: old.longitude)
            .distance(from: CLLocation(latitude: new.latitude, longitude: new.longitude))
        return distance >= 80
    }
}
