//
//  CCDesign.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

enum CCDesign {
    /// Hintergrundfarbe
    static var background: Color { Color(.systemBackground) }
    /// Kartenfarbe
    static var card: Color { Color(.secondarySystemBackground) }
    /// Primärtextfarbe
    static var textPrimary: Color { Color(.label) }
    /// Sekundärtextfarbe
    static var textSecondary: Color { Color(.secondaryLabel) }
    /// Akzentfarbe
    static var accent: Color { Color.accentColor }
    
    /// Kartenstil
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Self.card)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
