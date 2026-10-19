//
//  AvatarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Profilbild, sonst Initialen
struct AvatarView: View {
    var initials: String
    var imageURL: String?
    var size: CGFloat = 48
    /// Farbiger Rand, z. B. für den Status
    var borderColor: Color?

    var body: some View {
        content
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                if let borderColor {
                    Circle().stroke(borderColor, lineWidth: 2)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let imageURL, !imageURL.isEmpty, let url = URL(string: imageURL) {
            AsyncImage(url: url) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                initialsView
            }
        } else {
            initialsView
        }
    }

    private var initialsView: some View {
        ZStack {
            Circle().fill(CCDesign.accent.opacity(0.15))
            Text(initials)
                .font(.system(size: size * 0.4, weight: .semibold))
                .foregroundColor(CCDesign.accent)
        }
        .accessibilityLabel(tr("Profilbild"))
    }
}

#Preview {
    HStack {
        AvatarView(initials: "AC")
        AvatarView(initials: "MS", size: 64, borderColor: .green)
    }
}
