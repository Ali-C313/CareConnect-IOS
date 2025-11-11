//
//  OrderDisplay.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.11.25.
//

import Foundation
import CoreLocation

extension OrderDisplayModel: Equatable, Hashable {
    static func == (lhs: OrderDisplayModel, rhs: OrderDisplayModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.description == rhs.description &&
            lhs.state == rhs.state &&
            lhs.createdBy == rhs.createdBy &&
            lhs.patientName == rhs.patientName &&
            lhs.createdAt == rhs.createdAt &&
            lhs.dueDate == rhs.dueDate &&
            lhs.patientAddress == rhs.patientAddress &&
            {
                switch (lhs.employeeLocation, rhs.employeeLocation) {
                case (nil, nil):
                    return true
                case let (l?, r?):
                    return l.latitude == r.latitude && l.longitude == r.longitude
                default:
                    return false
                }
            }()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(description)
        hasher.combine(state)
        hasher.combine(createdBy)
        hasher.combine(patientName)
        hasher.combine(createdAt)
        hasher.combine(dueDate)
        hasher.combine(patientAddress)
        if let location = employeeLocation {
            hasher.combine(location.latitude)
            hasher.combine(location.longitude)
        } else {
            hasher.combine(0.0)
            hasher.combine(0.0)
        }
    }
}
