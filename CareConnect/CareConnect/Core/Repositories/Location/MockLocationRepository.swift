//
//  MockLocationRepository.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import CoreLocation

/// Fester Standort in Berlin statt Live-Daten
final class MockLocationRepository: LocationRepository {
    private let berlin = CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050)

    func listen(orgId: String, employeeId: String, onChange: @escaping (CLLocationCoordinate2D?) -> Void) -> ListenerHandle {
        onChange(berlin)
        return MockListener()
    }

    func upload(_ coordinate: CLLocationCoordinate2D, orgId: String, employeeId: String) async throws {}

    func clear(orgId: String, employeeId: String) async throws {}
}
