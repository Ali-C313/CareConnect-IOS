//
//  PatientsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation
import Combine
import FirebaseFirestore

@MainActor
final class PatientsViewModel: ObservableObject {
    
    @Published var patients: [Patient] = []
    @Published var isLoading = false
    private let service: FirebaseServiceType = FirebaseLiveService()
    
    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            self.patients = try await service.fetchPatients()
        } catch {
            print("❌ Fehler beim Laden der Patienten:", error.localizedDescription)
        }
    }
}
