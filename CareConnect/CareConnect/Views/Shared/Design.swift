//
//  CCDesign.swift
//  CareConnect
//
//  Created by Ali Chehab on 11.10.25.
//

import SwiftUI

enum CCDesign {
    static var background: Color { Color(.systemBackground) }
    static var card: Color { Color(.secondarySystemBackground) }
    static var textPrimary: Color { Color(.label) }
    static var textSecondary: Color { Color(.secondaryLabel) }
    static var accent: Color { Color.accentColor }
    
    static func cardStyle() -> some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Self.card)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
