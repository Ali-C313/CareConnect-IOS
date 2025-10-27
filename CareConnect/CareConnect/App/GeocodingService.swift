//
//  GeocodingService.swift
//  CareConnect
//
//  Created by Ali Chehab on 27.10.25.
//

import Foundation
import MapKit

final class GeocodingService {
    
    private let geocoder = CLGeocoder()
    
    /// Convert a postal address string to a coordinate for Map display or routing
    func coordinate(for address: String, completion: @escaping (Result<CLLocationCoordinate2D, Error>) -> Void) {
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                return completion(.failure(error))
            }
            guard let location = placemarks?.first?.location else {
                return completion(.failure(NSError(domain: "Geocoding", code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "Adresse nicht gefunden"])))
            }
            completion(.success(location.coordinate))
        }
    }
    
    /// Open Apple Maps with a route to the provided coordinate
    func openRoute(to coordinate: CLLocationCoordinate2D, name: String = "Ziel") {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
