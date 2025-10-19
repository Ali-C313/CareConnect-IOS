//
//  AvatarView.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

struct AvatarView: View {
    var initials: String
    var size: CGFloat = 48
    var body: some View {
        ZStack {
            Circle().fill(.white.opacity(0.18))
            Text(initials).font(.system(size: size * 0.4, weight: .semibold)).foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Avatar: " + initials)
    }
}
#Preview {
    AvatarView(initials: "AC")
}
