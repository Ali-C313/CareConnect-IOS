//
//  CollectionNames.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Namen der Collections, gleich wie in der Android-App
enum CollectionNames {
    static let organizations = "organizations"
    static let members = "members"
    static let users = "users"
    static let memberships = "memberships"
    static let invites = "invites"
    static let directory = "directory"
    static let joinRequests = "joinRequests"

    // Unter organizations/{orgId}
    static let employees = "employees"
    static let patients = "patients"
    static let orders = "orders"
    static let medicines = "medicines"
    static let appointments = "appointments"
    static let documents = "documents"
    static let employeeLocations = "employeeLocations"
    static let prescriptions = "prescriptions"
}

extension Firestore {
    /// organizations/{orgId}
    func org(_ orgId: String) -> DocumentReference {
        collection(CollectionNames.organizations).document(orgId)
    }
}

/// Neue IDs wie in der Android-App (klein geschrieben)
func newId() -> String {
    UUID().uuidString.lowercased()
}
