//
//  MapModels.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Punkt auf der Karte, Mitarbeiter wird als Auto gezeigt
struct MapMarker: Identifiable, Equatable {
    let title: String
    let coordinate: CLLocationCoordinate2D
    var isEmployee = false

    var id: String { title }

    static func == (lhs: MapMarker, rhs: MapMarker) -> Bool {
        lhs.title == rhs.title &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}

/// Strecke mit Dauer und Entfernung
struct RouteInfo {
    let distanceMeters: Double
    let durationSeconds: Double
    var path: [CLLocationCoordinate2D] = []
}
