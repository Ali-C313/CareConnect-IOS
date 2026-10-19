//
//  AddressSearchViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import MapKit

/// Adressvorschläge über Apple Maps
@MainActor
@Observable
final class AddressSearchViewModel: NSObject, MKLocalSearchCompleterDelegate {
    var queryFragment: String = "" {
        didSet {
            guard !isSelecting else { return }
            if queryFragment.isBlank {
                suggestions = []
            } else {
                completer.queryFragment = queryFragment
            }
        }
    }

    var suggestions: [String] = []

    private let completer = MKLocalSearchCompleter()
    private var isSelecting = false

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        // Deutschland
        completer.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )
    }

    /// Vorschlag übernehmen, ohne neue Suche
    func select(_ suggestion: String) {
        isSelecting = true
        queryFragment = suggestion
        isSelecting = false
        suggestions = []
    }

    /// Vorhandene Adresse setzen (z. B. beim Bearbeiten)
    func prefill(_ address: String?) {
        select(address ?? "")
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        suggestions = completer.results.prefix(5).map {
            $0.subtitle.isEmpty ? $0.title : "\($0.title), \($0.subtitle)"
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Adresssuche:", error.localizedDescription)
    }
}
