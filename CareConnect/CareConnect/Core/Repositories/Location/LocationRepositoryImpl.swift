//
//  LocationRepositoryImpl.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore
import CoreLocation

final class LocationRepositoryImpl: LocationRepository {
    private func ref(_ orgId: String) -> CollectionReference {
        FirebaseManager.shared.database.org(orgId).collection(CollectionNames.employeeLocations)
    }

    func listen(orgId: String, employeeId: String, onChange: @escaping (CLLocationCoordinate2D?) -> Void) -> ListenerHandle {
        let registration = ref(orgId).document(employeeId).addSnapshotListener { snapshot, _ in
            guard let data = snapshot?.data(),
                  let lat = data["lat"] as? Double,
                  let lon = data["lon"] as? Double else {
                onChange(nil)
                return
            }
            onChange(CLLocationCoordinate2D(latitude: lat, longitude: lon))
        }
        return FirestoreListener(registration)
    }

    func upload(_ coordinate: CLLocationCoordinate2D, orgId: String, employeeId: String) async throws {
        try await ref(orgId).document(employeeId).setData([
            "lat": coordinate.latitude,
            "lon": coordinate.longitude,
            "updatedAt": Timestamp()
        ])
    }

    func clear(orgId: String, employeeId: String) async throws {
        try await ref(orgId).document(employeeId).delete()
    }
}
