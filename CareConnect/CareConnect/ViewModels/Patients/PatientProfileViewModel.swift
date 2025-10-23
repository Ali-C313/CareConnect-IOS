//
//  PatientProfileViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 20.10.25.
//

import Foundation
import Combine

@MainActor
final class PatientProfileViewModel: ObservableObject {
    @Published var patient: Patient?
    @Published var isLoading = false
    
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
