//
//  Employee.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import Foundation

struct Employee: Identifiable, Codable {
    
    var id: String = UUID().uuidString
    var name: String
    var age: Int
    var role: String
    var yearsInCompany: Double
    var status: StaffStatus = .available
    var avatarURL: String? = nil
}
