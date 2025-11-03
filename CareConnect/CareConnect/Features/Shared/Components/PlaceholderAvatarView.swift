//
//  PlaceholderAvatarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

struct PlaceholderAvatarView: View {
    /// UI-Inhalt
    var body: some View {
        Circle()
            .fill(.white.opacity(0.18))
            .frame(width: 72, height: 72)
            .overlay(Image(systemName: "person.fill").foregroundColor(.white))
            .accessibilityLabel("Avatar")
    }
}
