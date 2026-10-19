//
//  ProfileSection.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Profil-Kopf in den Einstellungen mit Link zum Bearbeiten
struct ProfileSection<Destination: View>: View {
    let name: String
    let email: String
    let imageURL: String?
    @ViewBuilder let destination: Destination

    var body: some View {
        Section(tr("Profil")) {
            NavigationLink {
                destination
            } label: {
                HStack(spacing: 12) {
                    AvatarView(initials: name.initials, imageURL: imageURL, size: 48)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(name).font(.headline)
                        Text(email)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
