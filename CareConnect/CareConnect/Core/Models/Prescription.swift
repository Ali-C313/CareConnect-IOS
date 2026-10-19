//
//  Prescription.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation
import FirebaseFirestore

/// Verordnung einer Praxis/Klinik an einen Pflegedienst, liegt bei beiden Organisationen
struct Prescription: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var fromOrgId: String = ""
    var fromOrgName: String = ""
    var toOrgId: String = ""
    var toOrgName: String = ""
    var patientId: String = ""
    var patientName: String = ""
    var title: String = ""
    var details: String = ""
    var frequency: String = ""
    var startDate: Timestamp?
    var createdBy: String = ""
    var createdByName: String = ""
    var createdAt: Timestamp?
    var status: PrescriptionStatus = .offen
    var orderId: String = ""
}
