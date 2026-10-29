//
//  Design.swift
//  CareConnect
//
//  Created by Ali Chehab on 18.10.26.
//

import SwiftUI

/// Farben und Stil der App an einer Stelle
enum CCDesign {
    // MARK: - Farben (Color Assets im Ordner CC)
    static let background = Color("Background")
    static let card = Color("Card")
    static let accent = Color("Accent")
    static let info = Color("Info")
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
    /// Hintergrund für Eingabefelder und Listenzeilen
    static let field = Color(.secondarySystemBackground)

    // MARK: - Layout
    static let radius: CGFloat = 16

    // MARK: - Kartenstil
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(card)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

/// Gemeinsame Modifier für alle Screens
extension View {
    /// Standard-Hintergrund für alle Screens
    func screenBackground() -> some View {
        background(CCDesign.background.ignoresSafeArea())
    }

    /// Einfacher Hinweis-Dialog, verschwindet beim Tippen auf OK
    func messageAlert(_ title: String, message: Binding<String?>) -> some View {
        alert(title, isPresented: Binding(
            get: { message.wrappedValue != nil },
            set: { if !$0 { message.wrappedValue = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(message.wrappedValue ?? "")
        }
    }
}
