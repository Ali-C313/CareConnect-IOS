//
//  PrimaryButtonStyle.swift
//  CareConnect
//
//  Created by Ali Chehab on 05.11.25.
//

import SwiftUI
import Foundation

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 44)
            .padding(.horizontal, CCDesign.innerSpacing)
            .background(CCDesign.accent.opacity(configuration.isPressed ? 0.7 : 1))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: CCDesign.radius, style: .continuous))
            .shadow(radius: configuration.isPressed ? 2 : 4, y: configuration.isPressed ? 1 : 2)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension View {
    func primaryButton() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
}

#Preview {
    Button("Primary Action") { }
        .primaryButton()
        .padding()
        .background(CCDesign.background)
}