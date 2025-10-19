//
//  PatientsViewModel.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation
import Combine

@MainActor
final class PatientsViewModel: ObservableObject {
    
    @Published var patients: [Patient] = []
    private let service: FirebaseServiceType

    init(service: FirebaseServiceType = FirebaseMockService()) {
        self.service = service
    }

    func load() async {
        do { patients = try await service.fetchPatients() }
        catch { print("Fehler Patienten: \(error)") }
    }
}
