//
//  FirebaseManager.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

/// Zentraler Zugriff auf Auth, Firestore und Storage, nur die Repositories benutzen das
final class FirebaseManager {
    static let shared = FirebaseManager()

    let auth = Auth.auth()
    let database = Firestore.firestore()
    let storage = Storage.storage()

    private init() {}

    var userId: String? {
        auth.currentUser?.uid
    }
}
