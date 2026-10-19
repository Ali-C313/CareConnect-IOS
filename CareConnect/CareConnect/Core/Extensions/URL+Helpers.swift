//
//  URL+Helpers.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Links für Telefon, Mail und Karten
enum Links {
    static func phone(_ number: String) -> URL? {
        URL(string: "tel:\(number.phoneDigits)")
    }

    static func mail(_ address: String) -> URL? {
        URL(string: "mailto:\(address)")
    }

    /// Adresse in Apple Maps suchen
    static func mapsSearch(_ query: String) -> URL? {
        let text = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        return URL(string: "http://maps.apple.com/?q=\(text)")
    }

    /// Navigation in Apple Maps starten
    static func directions(to coordinate: CLLocationCoordinate2D) -> URL? {
        URL(string: "http://maps.apple.com/?daddr=\(coordinate.latitude),\(coordinate.longitude)")
    }

    /// Tour über mehrere Adressen in Google Maps, Start ist der aktuelle Standort
    static func tour(_ addresses: [String]) -> URL? {
        guard let last = addresses.last else { return nil }
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-_.~")
        let encode = { (value: String) in value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value }
        let waypoints = addresses.dropLast().map(encode).joined(separator: "%7C")
        var url = "https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=\(encode(last))"
        if !waypoints.isEmpty { url += "&waypoints=\(waypoints)" }
        return URL(string: url)
    }
}
