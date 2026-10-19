//
//  JoinRequestStatus.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Status einer Beitrittsanfrage
enum JoinRequestStatus: String, Codable, CaseIterable, Identifiable {
    case pending
    case accepted
    case declined

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pending: return tr("Ausstehend")
        case .accepted: return tr("Angenommen")
        case .declined: return tr("Abgelehnt")
        }
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = JoinRequestStatus(rawValue: value) ?? .pending
    }
}
