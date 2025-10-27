//
//  PatientProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class PatientProfileViewModel: ObservableObject {
    @Published var patient: Patient?
    @Published var isLoading = false
    
    @Published var newEmergencyContact = EmergencyContact(
        name: "",
        relation: "",
        phone: "",
        email: "",
        address: "",
        age: nil
    )

    @Published var showAddEmergencyContactSheet = false

    func saveEmergencyContact() async {
        guard let patientId = patient?.id else { return }
        do {
            try await Firestore.firestore()
                .collection("patients")
                .document(patientId)
                .updateData([
                    "emergencyContact": [
                        "name": newEmergencyContact.name,
                        "relation": newEmergencyContact.relation,
                        "phone": newEmergencyContact.phone as Any,
                        "email": newEmergencyContact.email as Any,
                        "address": newEmergencyContact.address as Any,
                        "age": newEmergencyContact.age as Any
                    ]
                ])
            await loadPatient(id: patientId)
        } catch {
            print("❌ Fehler beim Speichern des Notfallkontakts:", error.localizedDescription)
        }
    }
    
    private let service: FirebaseServiceType = FirebaseLiveService()
    
    func loadPatient(id: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            patient = try await service.fetchPatient(by: id)
        } catch {
            print("❌ Fehler beim Laden des Patienten:", error)
        }
    }
}
