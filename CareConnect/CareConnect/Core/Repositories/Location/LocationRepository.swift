//
//  LocationRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Live-Standort der Mitarbeiter (employeeLocations/{id})
protocol LocationRepository {
    func listen(orgId: String, employeeId: String, onChange: @escaping (CLLocationCoordinate2D?) -> Void) -> ListenerHandle
    func upload(_ coordinate: CLLocationCoordinate2D, orgId: String, employeeId: String) async throws
    /// Nach dem Einsatz löschen, damit kein alter Standort angezeigt wird
    func clear(orgId: String, employeeId: String) async throws
}
