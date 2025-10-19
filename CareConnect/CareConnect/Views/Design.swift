//
//  Design.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//


import SwiftUI

enum CC {
    static let gradient = LinearGradient(
        colors: [Color(red: 0.05, green: 0.5, blue: 0.35), Color(red: 0.05, green: 0.35, blue: 0.6)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    static func cardBackground() -> some View {
        RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.08))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.1)))
            .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
    }
}
struct GradientBackground: View {
    var body: some View {
        CC.gradient.ignoresSafeArea()
    }
}
#Preview {
    GradientBackground()
}
