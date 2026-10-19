//
//  OrganizationType.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import Foundation

/// Art der Organisation
enum OrganizationType: String, Codable, CaseIterable, Identifiable {
    case pflegedienst
    case arztpraxis
    case klinik

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .pflegedienst: return tr("Pflegedienst")
        case .arztpraxis: return tr("Arztpraxis")
        case .klinik: return tr("Klinik")
        }
    }

    init(from decoder: Decoder) throws {
        let value = try decoder.singleValueContainer().decode(String.self)
        self = OrganizationType(rawValue: value) ?? .pflegedienst
    }
}
